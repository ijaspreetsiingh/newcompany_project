<?php

namespace Modules\BookingModule\Entities;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Modules\UserManagement\Entities\Serviceman;

class BookingExtraService extends Model
{
    use HasUuid;

    protected $fillable = [
        'id',
        'booking_id',
        'serviceman_id',
        'name',
        'price',
        'quantity',
        'type',
    ];

    protected $casts = [
        'price' => 'float',
        'quantity' => 'integer',
    ];

    public function booking(): BelongsTo
    {
        return $this->belongsTo(Booking::class);
    }

    public function serviceman(): BelongsTo
    {
        return $this->belongsTo(Serviceman::class);
    }
}
