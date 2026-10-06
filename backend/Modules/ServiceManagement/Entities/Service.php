<?php

namespace Modules\ServiceManagement\Entities;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Str;
use Modules\BookingModule\Entities\BookingDetail;
use Modules\BusinessSettingsModule\Entities\Storage;
use Modules\BusinessSettingsModule\Entities\Translation;
use Modules\CategoryManagement\Entities\Category;
use Modules\PromotionManagement\Entities\DiscountType;
use Modules\ReviewModule\Entities\Review;
use Illuminate\Database\Eloquent\SoftDeletes;

class Service extends Model
{
    use HasFactory;
    use HasUuid;
    use SoftDeletes;

    protected $casts = [
        'tax' => 'float',
        'order_count' => 'float',
        'is_active' => 'integer',
        'is_single_provider' => 'integer',
        'rating_count' => 'integer',
        'avg_rating' => 'float',
        'slug'      => 'string',
        'gallery'   => 'array',
    ];

    protected $fillable = ['slug'];

    protected $appends = ['thumbnail_full_path', 'cover_image_full_path', 'gallery_full_paths'];

    public function variations(): HasMany
    {
        return $this->hasMany(Variation::class, 'service_id', 'id');
    }

    public function favorites(): HasMany
    {
        return $this->hasMany(FavoriteService::class, 'service_id', 'id');
    }

    public function bookings(): HasMany
    {
        return $this->hasMany(BookingDetail::class, 'service_id', 'id');
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'category_id', 'id')->withoutGlobalScopes();
    }

    public function singleProvider(): BelongsTo
    {
        return $this->belongsTo(\Modules\ProviderManagement\Entities\Provider::class, 'single_provider_id', 'id');
    }

    public function parentService(): BelongsTo
    {
        return $this->belongsTo(self::class, 'parent_service_id', 'id')->withoutGlobalScopes();
    }

    public function ownerProvider(): BelongsTo
    {
        return $this->belongsTo(\Modules\ProviderManagement\Entities\Provider::class, 'provider_id', 'id');
    }

    public function providerClones(): HasMany
    {
        return $this->hasMany(self::class, 'parent_service_id', 'id')->withoutGlobalScopes();
    }

    public function subCategory(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'sub_category_id', 'id')->withoutGlobalScopes();
    }

    /**
     * Customer visibility: service tabhi dikhegi jab uski sub-category current zone me
     * serviceable provider ko assigned ho.
     * Rule: subcategory assignment ki priority > category assignment (complete) fallback.
     * Zone header na ho to filter skip (splash/fresh-install safe).
     */
    public function scopeVisibleInCurrentZone($query)
    {
        $zoneId = Config::get('zone_id');
        if (empty($zoneId) && search_geo_context() === null) {
            return $query;
        }

        $eligible = subscribed_assignment_query($zoneId);

        return $query->where(function ($q) use ($eligible) {
            // 1) Priority: sub-category assignment (eligible provider ke saath)
            //    Note: sub-level rows me category_id parent ka hota hai — isliye
            //    sub_category_id wala sub_category_assignments relation use hota hai.
            $q->whereHas('subCategory.sub_category_assignments', $eligible)
                // 2) Fallback: sub-category ka koi active assignment hi nahi
                //    → category-level (complete main category) assignment chalega
                ->orWhere(function ($q2) use ($eligible) {
                    $q2->whereDoesntHave('subCategory.sub_category_assignments', function ($subQuery) {
                            $subQuery->ofStatus(1);
                        })
                        ->whereHas('category.subscribed_services', function ($catQuery) use ($eligible) {
                            $eligible($catQuery);
                            $catQuery->where('assign_type', 'complete');
                        });
                });
        });
    }

    public function service_discount(): HasMany
    {
        return $this->hasMany(DiscountType::class, 'type_wise_id')
            ->whereHas('discount', function ($query) {
                $query->whereIn('discount_type', ['service', 'mixed'])
                    ->where('promotion_type', 'discount')
                    ->whereDate('start_date', '<=', now())
                    ->whereDate('end_date', '>=', now())
                    ->where('is_active', 1);
            })->whereHas('discount.discount_types', function ($query) {
                if (request()->is('api/*/provider?*') || request()->is('api/*/provider/*')) {
                    $query->where(['discount_type' => 'zone', 'type_wise_id' => request()->user()->provider->zone_id]);
                } elseif (request()->is('api/*/customer?*') || request()->is('api/*/customer/*')) {
                    $query->where(['discount_type' => 'zone', 'type_wise_id' => config('zone_id')]);
                }
            })->with(['discount'])->latest();
    }

    public function campaign_discount(): HasMany
    {
        return $this->hasMany(DiscountType::class, 'type_wise_id')
            ->whereHas('discount', function ($query) {
                $query->where('promotion_type', 'campaign')
                    ->whereDate('start_date', '<=', now())
                    ->whereDate('end_date', '>=', now())
                    ->where('is_active', 1);
            })->whereHas('discount.discount_types', function ($query) {
                if (request()->is('api/*/provider?*') || request()->is('api/*/provider/*')) {
                    $query->where(['discount_type' => 'zone', 'type_wise_id' => request()->user()->provider->zone_id]);
                } elseif (request()->is('api/*/customer?*') || request()->is('api/*/customer/*')) {
                    $query->where(['discount_type' => 'zone', 'type_wise_id' => config('zone_id')]);
                }
            })->with(['discount'])->latest();
    }

    public function scopeActive($query)
    {
        $query->where(['is_active' => 1])
            ->whereHas('category', function ($query) {
                $query->where('is_active', 1);
            })
            ->whereHas('subCategory', function ($query) {
                $query->where('is_active', 1);
            });
    }

    public function scopeInActive($query)
    {
        $query->where(['is_active' => 0]);
    }

    public function scopeOfStatus($query, $status)
    {
        if($status == 1) {
            $query->where(['is_active' => 1])
                ->whereHas('category', function ($query) {
                    $query->where('is_active', 1);
                })
                ->whereHas('subCategory', function ($query) {
                    $query->where('is_active', 1);
                });

        } else if($status = 0) {
            $query->where(['is_active' => 0]);
        }
    }

    public function faqs(): HasMany
    {
        return $this->hasMany(Faq::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class);
    }

    public function translations(): MorphMany
    {
        return $this->morphMany(Translation::class, 'translationable');
    }

    public function storage_cover_image()
    {
        return $this->hasOne(Storage::class, 'model_id')->where('model_column', 'cover_image');
    }

    public function storage_thumbnail()
    {
        return $this->hasOne(Storage::class, 'model_id')->where('model_column', 'thumbnail');
    }

    public function getNameAttribute($value){
        if (count($this->translations) > 0) {
            foreach ($this->translations as $translation) {
                if ($translation['key'] == 'name') {
                    return $translation['value'];
                }
            }
        }

        return $value;
    }

    public function getDescriptionAttribute($value){
        if (count($this->translations) > 0) {
            foreach ($this->translations as $translation) {
                if ($translation['key'] == 'description') {
                    return $translation['value'];
                }
            }
        }

        return $value;
    }

    public function getShortDescriptionAttribute($value){
        if (count($this->translations) > 0) {
            foreach ($this->translations as $translation) {
                if ($translation['key'] == 'short_description') {
                    return $translation['value'];
                }
            }
        }

        return $value;
    }

    public function getThumbnailFullPathAttribute()
    {
        $image = $this->thumbnail;
        $defaultPath = request()->is('*/edit/*') ? asset('public/assets/admin-module/img/media/upload-file.png') : asset('public/assets/admin-module/img/placeholder.png');

        if (!$image) {
            if (request()->is('api/*')) {
                $defaultPath = null;
            }
            return $defaultPath;
        }

        $s3Storage = $this->storage_thumbnail;
        $path = 'service/';
        $imagePath = $path . $image;

        return getSingleImageFullPath(imagePath: $imagePath, s3Storage: $s3Storage, defaultPath: $defaultPath);
    }

    public function getCoverImageFullPathAttribute()
    {
        $image = $this->cover_image;
        $defaultPath = asset('public/assets/admin-module/img/placeholder.png');

        if (!$image) {
            if (request()->is('api/*')) {
                $defaultPath = null;
            }
            return $defaultPath;
        }
        if (request()->is('*/detail/*')) {
            $defaultPath = asset('public/assets/admin-module/img/placeholder.png');
        }

        $s3Storage = $this->storage_cover_image;
        $path = 'service/';
        $imagePath = $path . $image;

        return getSingleImageFullPath(imagePath: $imagePath, s3Storage: $s3Storage, defaultPath: $defaultPath);
    }

    /**
     * Gallery images full paths - admin panel "Gallery Image" block se
     * Array of images stored in JSON column `gallery`
     */
    public function getGalleryFullPathsAttribute(): array
    {
        $gallery = $this->attributes['gallery'] ?? null;
        $gallery = is_array($gallery) ? $gallery : (array) json_decode($gallery ?? '[]', true);

        if (empty($gallery)) {
            return [];
        }

        $paths = [];
        $s3Storage = $this->storage_cover_image;
        foreach ($gallery as $image) {
            if (empty($image)) {
                continue;
            }
            $fullPath = getSingleImageFullPath(imagePath: 'service/' . $image, s3Storage: $s3Storage, defaultPath: null);
            if ($fullPath) {
                $paths[] = $fullPath;
            }
        }
        return $paths;
    }

    public static function generateUniqueSlug($name, $ignoreId = null)
    {
        $slug = Str::slug($name);
        $original = $slug;
        $count = 1;

        while (
        static::where('slug', $slug)
            ->when($ignoreId, fn ($q) => $q->where('id', '!=', $ignoreId))
            ->exists()
        ) {
            $slug = $original . '-' . $count++;
        }

        return $slug;
    }

    protected static function booted()
    {
        static::addGlobalScope('zone_wise_data', function (Builder $builder) {
            if (request()->is('api/*/customer?*') || request()->is('api/*/customer/*')) {
                $builder->whereHas('category.zones', function ($query) {
                    $query->where('zone_id', Config::get('zone_id'));
                })->with(['service_discount', 'campaign_discount']);
            } elseif (request()->is('api/*/provider?*') || request()->is('api/*/provider/*')) {
                if (auth()->check() && request()->user()->provider != null) {
                    $providerId = request()->user()->provider->id;
                    $builder->whereHas('category.zones', function ($query) {
                        $query->where('zone_id', request()->user()->provider->zone_id);
                    })
                        // Single-provider exclusive services: sirf locked provider ko dikhao
                        ->where(function ($query) use ($providerId) {
                            $query->where('is_single_provider', 0)
                                ->orWhereNull('single_provider_id')
                                ->orWhere('single_provider_id', $providerId);
                        })
                        ->with(['service_discount', 'campaign_discount']);
                }
            }
        });

        /*
         * Provider managed services:
         *  - services.provider_id IS NULL          -> admin ka service (sab zones)
         *  - services.provider_id = X              -> provider X ka apna banaya service (sirf uski zone me)
         *  - services.parent_service_id = <base>    -> provider ka edited clone (sirf uski zone me)
         * Customer: base tab tak dikhta hai jab tak us zone me approved clone na ho.
         * Provider: apna clone ho toh base nahi dikhta (duplicate avoid).
         */
        static::addGlobalScope('provider_service_visibility', function (Builder $builder) {
            $zoneId = Config::get('zone_id');

            if (request()->is('api/*/client*') || request()->is('api/*/customer*')) {
                $builder->where(function (Builder $query) use ($zoneId) {
                    $query->where(function (Builder $q) use ($zoneId) {
                        $q->whereNull('services.provider_id');
                        if ($zoneId) {
                            $q->whereNotExists(function ($q2) use ($zoneId) {
                                $q2->selectRaw('1')
                                    ->from('services as provider_service_clones')
                                    ->whereColumn('provider_service_clones.parent_service_id', 'services.id')
                                    ->whereNull('provider_service_clones.deleted_at')
                                    ->where('provider_service_clones.zone_id', $zoneId)
                                    ->where('provider_service_clones.approval_status', 'approved');
                            });
                        }
                    })->orWhere(function (Builder $q) use ($zoneId) {
                        $q->whereNotNull('services.provider_id')
                            ->where('services.approval_status', 'approved')
                            ->where('services.zone_id', $zoneId);
                    });
                });
            } elseif (request()->is('api/*/partner*') || request()->is('api/*/provider*')) {
                if (auth()->check() && request()->user()?->provider) {
                    $providerId = request()->user()->provider->id;
                    $providerZoneId = request()->user()->provider->zone_id;
                    $builder->where(function (Builder $query) use ($providerId, $providerZoneId) {
                        $query->whereNull('services.provider_id')
                            ->when($providerZoneId, function ($q) use ($providerId, $providerZoneId) {
                                $q->whereNotExists(function ($q2) use ($providerId, $providerZoneId) {
                                    $q2->selectRaw('1')
                                        ->from('services as my_service_clones')
                                        ->whereColumn('my_service_clones.parent_service_id', 'services.id')
                                        ->whereNull('my_service_clones.deleted_at')
                                        ->where('my_service_clones.provider_id', $providerId)
                                        ->where('my_service_clones.zone_id', $providerZoneId);
                                });
                            })
                            ->orWhere('services.provider_id', $providerId);
                    });
                }
            }
        });

        static::saved(function ($model) {
            $storageType = getDisk();
            if($model->isDirty('thumbnail') && $storageType != 'public'){
                saveSingleImageDataToStorage(model: $model, modelColumn : 'thumbnail', storageType : $storageType);
            }
            if($model->isDirty('cover_image') && $storageType != 'public'){
                saveSingleImageDataToStorage(model: $model, modelColumn : 'cover_image', storageType : $storageType);
            }
        });

        static::addGlobalScope('translate', function (Builder $builder) {
            $builder->with(['translations' => function ($query) {
                return $query->where('locale', app()->getLocale());
            }]);
        });

        static::creating(function ($category) {
            if (empty($category->slug)) {
                $category->slug = static::generateUniqueSlug($category->name);
            }
        });

        static::updating(function ($category) {
            if ($category->isDirty('name') || empty($category->slug)) {
                $category->slug = static::generateUniqueSlug($category->name, $category->id);
            }
        });
    }
}
