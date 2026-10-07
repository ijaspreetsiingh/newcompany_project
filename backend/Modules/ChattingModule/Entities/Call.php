<?php

namespace Modules\ChattingModule\Entities;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Modules\UserManagement\Entities\User;

class Call extends Model
{
    use HasFactory, HasUuid;

    protected $fillable = [
        'caller_id',
        'callee_id',
        'channel_id',
        'booking_id',
        'call_type',
        'status',
        'ring_expires_at',
        'answered_at',
        'ended_at',
        'duration',
    ];

    protected $casts = [
        'ring_expires_at' => 'datetime',
        'answered_at' => 'datetime',
        'ended_at' => 'datetime',
        'duration' => 'integer',
    ];

    public function caller(): BelongsTo
    {
        return $this->belongsTo(User::class, 'caller_id', 'id');
    }

    public function callee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'callee_id', 'id');
    }
}
