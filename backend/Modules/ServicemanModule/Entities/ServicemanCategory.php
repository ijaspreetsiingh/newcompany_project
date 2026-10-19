<?php

namespace Modules\ServicemanModule\Entities;

use Illuminate\Database\Eloquent\Model;
use Modules\CategoryManagement\Entities\Category;
use Modules\UserManagement\Entities\Serviceman;

class ServicemanCategory extends Model
{
    protected $table = 'serviceman_categories';

    protected $fillable = [
        'serviceman_id',
        'category_id',
        'sub_category_id',
    ];

    public function serviceman(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Serviceman::class);
    }

    public function subCategory(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Category::class, 'sub_category_id');
    }

    public function mainCategory(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Category::class, 'category_id');
    }
}
