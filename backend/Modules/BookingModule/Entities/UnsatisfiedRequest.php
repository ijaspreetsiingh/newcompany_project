<?php

namespace Modules\BookingModule\Entities;

use App\Traits\HasUuid;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Modules\ProviderManagement\Entities\Provider;
use Modules\UserManagement\Entities\Serviceman;
use Modules\UserManagement\Entities\User;

class UnsatisfiedRequest extends Model
{
    use HasUuid;

    public const STATUS_REQUESTED = 'requested';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_EXPIRED = 'expired';

    /** Fallback window — provider ki setting (unsatisfied_window_days) priority hai. */
    public const DEFAULT_WINDOW_DAYS = 7;

    protected $fillable = [
        'id',
        'booking_id',
        'customer_id',
        'provider_id',
        'serviceman_id',
        'reservice_booking_id',
        'status',
        'reason',
        'requested_at',
        'due_at',
        'completed_at',
    ];

    protected $casts = [
        'requested_at' => 'datetime',
        'due_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    public function booking(): BelongsTo
    {
        return $this->belongsTo(Booking::class, 'booking_id');
    }

    public function reserviceBooking(): BelongsTo
    {
        return $this->belongsTo(Booking::class, 'reservice_booking_id');
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function provider(): BelongsTo
    {
        return $this->belongsTo(Provider::class, 'provider_id');
    }

    public function serviceman(): BelongsTo
    {
        return $this->belongsTo(Serviceman::class, 'serviceman_id');
    }

    public function isOverdue(): bool
    {
        return $this->due_at !== null && $this->due_at->isPast();
    }

    /**
     * Lazy auto-close: window nikal gaya aur request band nahi hui.
     */
    public function expireIfNeeded(): bool
    {
        if ($this->status === self::STATUS_COMPLETED || $this->status === self::STATUS_EXPIRED) {
            return false;
        }

        if ($this->isOverdue()) {
            $this->status = self::STATUS_EXPIRED;
            $this->save();

            return true;
        }

        return false;
    }

    /**
     * Booking completion ke baad provider ke window-days andar request allowed hai?
     */
    public static function windowDaysFor(?Provider $provider): int
    {
        $days = $provider?->unsatisfied_window_days;

        return is_numeric($days) ? max(0, (int) $days) : self::DEFAULT_WINDOW_DAYS;
    }

    public static function canRequestFor(Booking $booking, int $windowDays): bool
    {
        if ($windowDays <= 0) {
            return false;
        }

        $completedAt = $booking->status_histories()
            ->where('booking_status', 'completed')
            ->latest('created_at')
            ->value('created_at');

        $reference = $completedAt ? Carbon::parse($completedAt) : $booking->updated_at;

        return $reference !== null &&
            $reference->copy()->addDays($windowDays)->isFuture();
    }

    public function scopeActive($query)
    {
        return $query->where('status', self::STATUS_REQUESTED);
    }
}
