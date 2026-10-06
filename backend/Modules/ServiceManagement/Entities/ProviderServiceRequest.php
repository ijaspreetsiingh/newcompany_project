<?php

namespace Modules\ServiceManagement\Entities;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProviderServiceRequest extends Model
{
    use HasUuid;

    protected $table = 'provider_service_requests';

    protected $fillable = [
        'provider_id',
        'service_id',
        'zone_id',
        'request_type',
        'previous_values',
        'status',
        'admin_note',
    ];

    public function service(): BelongsTo
    {
        return $this->belongsTo(Service::class, 'service_id');
    }

    public function provider(): BelongsTo
    {
        return $this->belongsTo(\Modules\ProviderManagement\Entities\Provider::class, 'provider_id');
    }
}
