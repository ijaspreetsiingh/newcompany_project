<?php

namespace Modules\ProviderManagement\Entities;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProviderCategoryRequest extends Model
{
    use HasUuid;

    protected $table = 'provider_category_requests';

    protected $fillable = [
        'provider_id',
        'zone_id',
        'request_type',
        'current_main_category_ids',
        'current_sub_category_ids',
        'requested_sub_category_ids',
        'note',
        'status',
        'admin_note',
    ];

    protected $casts = [
        'current_main_category_ids' => 'array',
        'current_sub_category_ids' => 'array',
        'requested_sub_category_ids' => 'array',
    ];

    public function provider(): BelongsTo
    {
        return $this->belongsTo(Provider::class, 'provider_id');
    }
}
