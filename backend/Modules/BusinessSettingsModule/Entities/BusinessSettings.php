<?php

namespace Modules\BusinessSettingsModule\Entities;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\MorphMany;

class BusinessSettings extends Model
{
    use HasFactory;
    use HasUuid;

    protected $casts = [
        'live_values'=>'array',
        'test_values'=>'array',
        'is_active'=>'integer',
    ];

    protected $fillable = ['key_name', 'live_values', 'test_values', 'settings_type', 'mode', 'is_active'];

    protected static function booted(): void
    {
        static::saved(function (BusinessSettings $model) {
            \Illuminate\Support\Facades\Cache::forget("bc_{$model->settings_type}_{$model->key_name}");
            \Illuminate\Support\Facades\Cache::forget('bc_general_config_currency_code');
            \Illuminate\Support\Facades\Cache::forget('bc_business_information_currency_code');
            \Illuminate\Support\Facades\Cache::forget('bc_business_information_currency_symbol_position');
            \Illuminate\Support\Facades\Cache::forget('bc_business_information_currency_decimal_point');
        });
    }

    protected static function newFactory()
    {
        return \Modules\BusinessSettingsModule\Database\factories\BusinessSettingsFactory::new();
    }

    public function translations(): MorphMany
    {
        return $this->morphMany(Translation::class, 'translationable');
    }

    public function storage()
    {
        return $this->hasOne(Storage::class, 'model_id');
    }
}
