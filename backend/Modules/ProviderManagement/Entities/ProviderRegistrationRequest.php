<?php

namespace Modules\ProviderManagement\Entities;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Modules\CategoryManagement\Entities\Category;
use Modules\ZoneManagement\Entities\Zone;

class ProviderRegistrationRequest extends Model
{
    use HasUuid;

    protected $table = 'provider_registration_requests';

    protected $fillable = [
        'contact_person_name',
        'contact_person_phone',
        'contact_person_email',

        'company_name',
        'company_phone',
        'company_email',
        'company_address',
        'logo',

        'account_email',
        'account_phone',
        'password',

        'identity_type',
        'identity_number',
        'identity_images',

        'latitude',
        'longitude',

        'zone_id',
        'main_category_id',
        'sub_category_ids',

        'status',
        'created_provider_id',
        'admin_note',
    ];

    protected $casts = [
        'sub_category_ids' => 'array',
        'identity_images'  => 'array',
        'latitude'         => 'float',
        'longitude'        => 'float',
    ];

    public const STATUSES = [
        'pending'           => 'pending',
        'approved'          => 'approved',           // naya provider ACTIVE ban gaya
        'approved_inactive' => 'approved_inactive',  // Cancel: naya provider bana PAR inactive
        'accepted_existing' => 'accepted_existing',  // Accept: purana (old) provider activate hua
        'declined'          => 'declined',           // reject
    ];

    public function zone(): BelongsTo
    {
        return $this->belongsTo(Zone::class, 'zone_id');
    }

    public function mainCategory(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'main_category_id');
    }

    public function createdProvider(): BelongsTo
    {
        return $this->belongsTo(Provider::class, 'created_provider_id');
    }

    public function scopeOfStatus($query, $status)
    {
        return $query->where('status', '=', $status);
    }

    /**
     * Request me select kiye huye sub categories (empty ho to main ke
     * saare children = complete assignment).
     */
    public function effectiveSubCategoryIds(): array
    {
        if (is_array($this->sub_category_ids) && count(array_filter($this->sub_category_ids)) > 0) {
            return array_values(array_unique(array_filter($this->sub_category_ids)));
        }

        return [];
    }
}
