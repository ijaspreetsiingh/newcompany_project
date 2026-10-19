<?php

namespace Modules\UserManagement\Entities;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Modules\BookingModule\Entities\Booking;
use Modules\ProviderManagement\Entities\Provider;

class Serviceman extends Model
{
    use HasFactory;
    use HasUuid, SoftDeletes;

    protected $fillable = [];

    public function users()
    {
        return $this->belongsTo(User::class,'user_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class,'user_id');
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class, 'serviceman_id', 'id');
    }

    public function provider()
    {
        return $this->belongsTo(Provider::class);
    }

    /**
     * Serviceman ki assigned sub-categories (provider ne set ki hain).
     * Table: serviceman_categories (serviceman_id, category_id, sub_category_id)
     */
    public function servicemanCategories(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(\Modules\ServicemanModule\Entities\ServicemanCategory::class, 'serviceman_id');
    }

    /**
     * Convenience: flat list of assigned sub_category_ids
     */
    public function getAssignedSubCategoryIdsAttribute(): array
    {
        return $this->servicemanCategories
            ->whereNotNull('sub_category_id')
            ->pluck('sub_category_id')
            ->toArray();
    }

    public function scopeOfStatus($query, $status)
    {
        $query->where('is_active', '=', $status);
    }

    protected function scopeOfType($query, $type)
    {
        $query->whereIn('user_type', $type);
    }

    public static function boot()
    {
        parent::boot();

        self::creating(function ($model) {
            // ... code here
        });

        self::created(function ($model) {
            // ... code here
        });

        self::updating(function ($model) {
            // ... code here
        });

        self::updated(function ($model) {
            // ... code here
        });

        self::deleting(function ($model) {
            file_remover('serviceman/profile/', $model->user->profile_image);
            foreach ($model->user->identification_image as $image) {
                file_remover('serviceman/identity/', $image);
            }
            $model->user->forceDelete();
        });

        self::deleted(function ($model) {
            // ... code here
        });
    }


}
