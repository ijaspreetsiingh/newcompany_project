<?php

namespace Modules\ChattingModule\Http\Controllers\Api\V1;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Validator;
use Modules\ChattingModule\Entities\Call;
use Modules\ChattingModule\Entities\ChannelList;
use Modules\ChattingModule\Entities\ChannelUser;
use Modules\ChattingModule\Lib\AgoraToken;
use Modules\ChattingModule\Traits\ChattingTrait;
use Modules\UserManagement\Entities\User;

class CallController extends Controller
{
    use ChattingTrait;

    protected ChannelList $channelList;
    protected ChannelUser $channelUser;
    protected Call $call;

    private const RING_TIMEOUT_SECONDS = 45;
    private const TOKEN_TTL_SECONDS = 3600;

    public function __construct(ChannelList $channelList, ChannelUser $channelUser, Call $call)
    {
        $this->channelList = $channelList;
        $this->channelUser = $channelUser;
        $this->call = $call;
    }

    /**
     * POST call/initiate — naya voice/video call shuru karo (ringing).
     */
    public function initiate(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'callee_id' => 'required|uuid',
            'call_type' => 'required|in:voice,video',
            'booking_id' => 'nullable|string|max:64',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $caller = $request->user();

        if (!in_array($caller->user_type, ['customer', 'provider-admin', 'provider-serviceman'])) {
            return $this->error(translate('You are not allowed to start a call'), 403);
        }

        if (!$this->agoraCredentials()) {
            return $this->error(translate('In-app calling is not configured yet'), 403);
        }

        if ($request->callee_id === $caller->id) {
            return $this->error(translate('You can not call yourself'), 400);
        }

        $callee = User::find($request->callee_id);

        if (!$callee || (int)$callee->is_active !== 1) {
            return $this->error(translate('The user is unavailable'), 404);
        }

        // Admin toggle gate: caller + callee dono ke involved providers ke liye
        // providers.calling_enabled ON hona chahiye (Agora config ke saath).
        $involvedProviders = array_values(array_unique(array_filter([
            $this->resolveProviderId($caller),
            $this->resolveProviderId($callee),
        ])));

        if (empty($involvedProviders) || !$this->allProvidersCallingEnabled($involvedProviders)) {
            return $this->error(translate('In-app calling is not enabled for this provider'), 403);
        }

        if ($this->hasActiveCall([$caller->id, $callee->id])) {
            return $this->error(translate('The user is busy on another call'), 409);
        }

        $channel = $this->createNewChannel(
            fromUser: $caller->id,
            toUser: $callee->id,
            referenceId: $request->booking_id ?: '',
            referenceType: $request->booking_id ? 'booking_id' : 'support',
        );

        $call = $this->call;
        $call->caller_id = $caller->id;
        $call->callee_id = $callee->id;
        $call->channel_id = $channel->id;
        $call->booking_id = $request->booking_id ?: null;
        $call->call_type = $request->call_type;
        $call->status = 'ringing';
        $call->ring_expires_at = now()->addSeconds(self::RING_TIMEOUT_SECONDS);
        $call->save();

        if ($callee->fcm_token) {
            device_notification_for_calling(
                fcm_token: $callee->fcm_token,
                title: $request->call_type === 'video' ? translate('Incoming video call') : translate('Incoming call'),
                description: trim($caller->first_name . ' ' . $caller->last_name),
                call_id: $call->id,
                call_type: $call->call_type,
                user_name: trim($caller->first_name . ' ' . $caller->last_name),
                user_image: $caller->profile_image_full_path,
                user_phone: $caller->phone,
                user_type: $caller->user_type,
                booking_id: $call->booking_id,
                channel_id: $call->channel_id,
                type: 'call_invite',
            );
        }

        return response()->json(response_formatter(DEFAULT_200, [
            'call' => $this->formatCall($call, $caller),
        ]), 200);
    }

    /**
     * POST call/respond — callee accept / reject karega.
     */
    public function respond(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'call_id' => 'required|uuid',
            'action' => 'required|in:accept,reject',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $me = $request->user();
        $call = $this->findCall($request->call_id);

        if (!$call) {
            return $this->error(translate('Call not found'), 404);
        }

        if ($call->callee_id !== $me->id) {
            return $this->error(translate('You can not respond to this call'), 403);
        }

        $call = $this->normalizeCall($call);

        if ($call->status !== 'ringing') {
            return $this->error(translate('This call is no longer available'), 400);
        }

        $caller = User::find($call->caller_id);

        if ($request->action === 'accept') {
            $call->status = 'answered';
            $call->answered_at = now();
            $call->save();
        } else {
            $call->status = 'rejected';
            $call->ended_at = now();
            $call->save();
        }

        if ($caller && $caller->fcm_token) {
            device_notification_for_calling(
                fcm_token: $caller->fcm_token,
                title: $request->action === 'accept' ? translate('Call accepted') : translate('Call rejected'),
                description: trim($me->first_name . ' ' . $me->last_name),
                call_id: $call->id,
                call_type: $call->call_type,
                user_name: trim($me->first_name . ' ' . $me->last_name),
                user_image: $me->profile_image_full_path,
                user_phone: $me->phone,
                user_type: $me->user_type,
                booking_id: $call->booking_id,
                channel_id: $call->channel_id,
                type: 'call_response',
            );
        }

        return response()->json(response_formatter(DEFAULT_200, [
            'call' => $this->formatCall($call, $me, withToken: true),
        ]), 200);
    }

    /**
     * POST call/end — participant call end kare (answered → duration save).
     */
    public function end(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'call_id' => 'required|uuid',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $me = $request->user();
        $call = $this->findCall($request->call_id);

        if (!$call) {
            return $this->error(translate('Call not found'), 404);
        }

        if ($call->caller_id !== $me->id && $call->callee_id !== $me->id) {
            return $this->error(translate('You can not end this call'), 403);
        }

        $call = $this->normalizeCall($call);

        if (in_array($call->status, ['ended', 'rejected', 'cancelled', 'missed'])) {
            return response()->json(response_formatter(DEFAULT_200, [
                'call' => $this->formatCall($call, $me),
            ]), 200);
        }

        $call->ended_at = now();

        if ($call->status === 'answered') {
            $call->status = 'ended';
            $call->duration = max(0, (int)$call->answered_at->diffInSeconds(now()));
        } elseif ($call->status === 'ringing') {
            $call->status = $call->caller_id === $me->id ? 'cancelled' : 'rejected';
        }

        $call->save();

        $otherUserId = $call->caller_id === $me->id ? $call->callee_id : $call->caller_id;
        $otherUser = User::find($otherUserId);

        if ($otherUser && $otherUser->fcm_token) {
            device_notification_for_calling(
                fcm_token: $otherUser->fcm_token,
                title: translate('Call ended'),
                description: trim($me->first_name . ' ' . $me->last_name),
                call_id: $call->id,
                call_type: $call->call_type,
                user_name: trim($me->first_name . ' ' . $me->last_name),
                user_image: $me->profile_image_full_path,
                user_phone: $me->phone,
                user_type: $me->user_type,
                booking_id: $call->booking_id,
                channel_id: $call->channel_id,
                type: 'call_ended',
            );
        }

        return response()->json(response_formatter(DEFAULT_200, [
            'call' => $this->formatCall($call, $me),
        ]), 200);
    }

    /**
     * GET call/active — app foreground/start par live (ringing/answered) call.
     * Callee ke liye recovery path: FCM ring invite miss ho to yahan se mil jaye.
     */
    public function active(Request $request): JsonResponse
    {
        $me = $request->user();

        $call = $this->call
            ->with(['caller', 'callee'])
            ->where(function ($query) use ($me) {
                $query->where('caller_id', $me->id)->orWhere('callee_id', $me->id);
            })
            ->where(function ($query) {
                $query->where('status', 'answered')
                    ->orWhere(function ($query2) {
                        $query2->where('status', 'ringing')->where('ring_expires_at', '>', now());
                    });
            })
            ->latest('created_at')
            ->first();

        if ($call) {
            $call = $this->normalizeCall($call);
        }

        return response()->json(response_formatter(DEFAULT_200, [
            'call' => $call ? $this->formatCall($call, $me, withToken: $call->status === 'answered') : null,
        ]), 200);
    }

    /**
     * GET call/status?call_id= — caller ring-answer-missed progress ke liye poll.
     */
    public function status(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'call_id' => 'required|uuid',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $me = $request->user();
        $call = $this->findCall($request->call_id);

        if (!$call) {
            return $this->error(translate('Call not found'), 404);
        }

        if ($call->caller_id !== $me->id && $call->callee_id !== $me->id) {
            return $this->error(translate('You can not see this call'), 403);
        }

        $call = $this->normalizeCall($call);

        return response()->json(response_formatter(DEFAULT_200, [
            'call' => $this->formatCall($call, $me, withToken: $call->status === 'answered'),
        ]), 200);
    }

    /**
     * GET call/token?call_id= — (re)join ke liye Agora RTC credentials.
     */
    public function token(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'call_id' => 'required|uuid',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $me = $request->user();
        $call = $this->findCall($request->call_id);

        if (!$call) {
            return $this->error(translate('Call not found'), 404);
        }

        if ($call->caller_id !== $me->id && $call->callee_id !== $me->id) {
            return $this->error(translate('You can not join this call'), 403);
        }

        $call = $this->normalizeCall($call);

        if ($call->status !== 'answered') {
            return $this->error(translate('This call is not active'), 400);
        }

        return response()->json(response_formatter(DEFAULT_200, [
            'call' => $this->formatCall($call, $me, withToken: true),
        ]), 200);
    }

    /**
     * GET call/history — inbox "Calls" tab (kis-kis ko call hua, kisne ki).
     */
    public function history(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'limit' => 'required|numeric|min:1|max:200',
            'offset' => 'required|numeric|min:1|max:100000',
            'search' => 'nullable|string',
            'call_status' => 'nullable|in:answered,missed,rejected,cancelled,ended',
            'call_type' => 'nullable|in:voice,video',
        ]);

        if ($validator->fails()) {
            return response()->json(response_formatter(DEFAULT_400, null, error_processor($validator)), 400);
        }

        $me = $request->user();

        $calls = $this->call
            ->with(['caller', 'callee'])
            ->where(function ($query) use ($me) {
                $query->where('caller_id', $me->id)->orWhere('callee_id', $me->id);
            })
            ->when($request->filled('call_status'), function ($query) use ($request) {
                $query->where('status', $request->call_status);
            })
            ->when($request->filled('call_type'), function ($query) use ($request) {
                $query->where('call_type', $request->call_type);
            })
            ->when($request->filled('search'), function ($query) use ($request, $me) {
                $keyword = $request->search;
                $query->where(function ($query) use ($keyword, $me) {
                    $query->whereHas('caller', function ($q) use ($keyword) {
                        $q->where('first_name', 'LIKE', '%' . $keyword . '%')
                            ->orWhere('last_name', 'LIKE', '%' . $keyword . '%');
                    })->orWhereHas('callee', function ($q) use ($keyword) {
                        $q->where('first_name', 'LIKE', '%' . $keyword . '%')
                            ->orWhere('last_name', 'LIKE', '%' . $keyword . '%');
                    });
                });
            })
            ->orderBy('created_at', 'DESC')
            ->paginate($request->limit, ['*'], 'offset', $request->offset)
            ->withPath('');

        $calls->getCollection()->transform(function ($call) use ($me) {
            $call = $this->normalizeCall($call);
            return $this->formatCall($call, $me);
        });

        return response()->json(response_formatter(DEFAULT_200, [
            'callHistory' => $calls,
        ]), 200);
    }

    /* ------------------------------------------------------------------ */
    /* helpers                                                             */
    /* ------------------------------------------------------------------ */

    private function error(string $message, int $code = 400): JsonResponse
    {
        return response()->json([
            'response_code' => 'call_' . $code,
            'message' => $message,
        ], $code);
    }

    private function findCall(string $callId): ?Call
    {
        return $this->call->with(['caller', 'callee'])->find($callId);
    }

    /**
     * Ring timeout lazy-mark: 45s baad bina response ke call missed.
     */
    private function normalizeCall(Call $call): Call
    {
        if ($call->status === 'ringing' && $call->ring_expires_at && $call->ring_expires_at->isPast()) {
            $call->status = 'missed';
            $call->ended_at = $call->ended_at ?? now();
            $call->save();
        }

        return $call;
    }

    /**
     * User ka provider (provider-admin → users.provider_id,
     * serviceman → servicemen.provider_id). Customer ke liye null.
     */
    private function resolveProviderId(User $user): ?string
    {
        if ($user->provider) {
            return $user->provider->id;
        }

        if ($user->serviceman) {
            return $user->serviceman->provider_id;
        }

        return null;
    }

    private function allProvidersCallingEnabled(array $providerIds): bool
    {
        $enabledCount = \Modules\ProviderManagement\Entities\Provider::whereIn('id', $providerIds)
            ->where('calling_enabled', 1)
            ->count();

        return $enabledCount === count($providerIds);
    }

    private function hasActiveCall(array $userIds): bool
    {
        return $this->call
            ->where(function ($query) use ($userIds) {
                foreach ($userIds as $userId) {
                    $query->orWhere('caller_id', $userId)->orWhere('callee_id', $userId);
                }
            })
            ->where(function ($query) {
                $query->where('status', 'answered')
                    ->orWhere(function ($query2) {
                        $query2->where('status', 'ringing')->where('ring_expires_at', '>', now());
                    });
            })
            ->exists();
    }

    /**
     * Business Settings > 3rd Party > Agora credentials (admin configured).
     */
    private function agoraCredentials(): ?array
    {
        $config = business_config('agora', 'third_party');

        if (!$config || (int)$config->is_active !== 1) {
            return null;
        }

        $values = $config->live_values ?? [];

        if (empty($values['agora_app_id']) || empty($values['agora_app_certificate'])) {
            return null;
        }

        return [
            'app_id' => trim($values['agora_app_id']),
            'certificate' => trim($values['agora_app_certificate']),
        ];
    }

    private function agoraJoinPayload(Call $call, User $user): ?array
    {
        $agora = $this->agoraCredentials();

        if (!$agora) {
            return null;
        }

        $uid = AgoraToken::uidFromUserId($user->id);

        return [
            'agora_app_id' => $agora['app_id'],
            'channel_name' => $call->id,
            'rtc_uid' => $uid,
            'rtc_token' => AgoraToken::build(
                $agora['app_id'],
                $agora['certificate'],
                $call->id,
                $uid,
                self::TOKEN_TTL_SECONDS
            ),
            'token_expire_in' => self::TOKEN_TTL_SECONDS,
        ];
    }

    private function formatCall(Call $call, User $me, bool $withToken = false): array
    {
        $otherUser = $call->caller_id === $me->id ? $call->callee : $call->caller;

        $payload = [
            'id' => $call->id,
            'call_type' => $call->call_type,
            'status' => $call->status,
            'direction' => $call->caller_id === $me->id ? 'out' : 'in',
            'duration' => (int)$call->duration,
            'created_at' => $call->created_at,
            'answered_at' => $call->answered_at,
            'ended_at' => $call->ended_at,
            'booking_id' => $call->booking_id,
            'channel_id' => $call->channel_id,
            'other_user' => [
                'id' => $otherUser?->id,
                'name' => trim(($otherUser?->first_name ?? '') . ' ' . ($otherUser?->last_name ?? '')),
                'image' => $otherUser?->profile_image_full_path,
                'phone' => $otherUser?->phone,
                'user_type' => $otherUser?->user_type,
            ],
        ];

        if ($withToken) {
            $payload += $this->agoraJoinPayload($call, $me) ?? [];
        }

        return $payload;
    }
}
