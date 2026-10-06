<?php

namespace Modules\BookingModule\Entities;

use App\Traits\HasUuid;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Modules\ProviderManagement\Entities\Provider;
use Modules\UserManagement\Entities\Serviceman;
use Modules\UserManagement\Entities\User;

class BookingRecheck extends Model
{
    use HasUuid;

    public const STATUS_REQUESTED = 'requested';
    public const STATUS_IN_PROGRESS = 'in_progress';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_EXPIRED = 'expired';

    /** Recheck window — 15 din (request bhi 15 din tak, aur state bhi 15 din tak). */
    public const WINDOW_DAYS = 15;

    protected $fillable = [
        'id',
        'booking_id',
        'customer_id',
        'provider_id',
        'serviceman_id',
        'status',
        'reason',
        'serviceman_note',
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

    /**
     * 15 din ka window cross ho chuka hai to recheck expire.
     */
    public function isOverdue(): bool
    {
        return $this->due_at !== null && $this->due_at->isPast();
    }

    /**
     * Lazy auto-close: deadline nikal gaya aur kaam complete nahi hua.
     */
    public function expireIfNeeded(): bool
    {
        if (in_array($this->status, [self::STATUS_COMPLETED, self::STATUS_EXPIRED], true)) {
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
     * Booking completion ke kitne din baat hai — 15 din ka request window.
     */
    public static function canRequestFor(Booking $booking): bool
    {
        $completedAt = $booking->status_histories()
            ->where('booking_status', 'completed')
            ->latest('created_at')
            ->value('created_at');

        $reference = $completedAt ? Carbon::parse($completedAt) : $booking->updated_at;

        return $reference !== null &&
            $reference->copy()->addDays(self::WINDOW_DAYS)->isFuture();
    }

    /**
     * Booking ke active (non expired/completed) recheck.
     */
    public function scopeActive($query)
    {
        return $query->whereIn('status', [self::STATUS_REQUESTED, self::STATUS_IN_PROGRESS]);
    }
}
