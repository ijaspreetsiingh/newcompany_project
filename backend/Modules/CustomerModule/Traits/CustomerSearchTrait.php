<?php

namespace Modules\CustomerModule\Traits;

use Illuminate\Support\Facades\Config;
use Modules\CustomerModule\Entities\SearchedData;

trait CustomerSearchTrait
{

    protected function Searched_data_log($user_id, $attribute, $attribute_id, $response_data_count)
    {
        // Guest user ya bina zone (address) ke search karne par zone_id null
        // aata tha aur NOT NULL violation se poori search request 500 ho jaati
        // thi (app me "Internal Server Error" toast). Logging fail-safe hai —
        // search response hamesha jaana chahiye.
        $zoneId = Config::get('zone_id');
        if (!$zoneId || !$user_id) {
            return;
        }
        try {
            $searched_data = SearchedData::firstOrNew(['user_id' => $user_id, 'attribute_id' =>  $attribute_id]);
            $searched_data->zone_id = $zoneId;
            $searched_data->attribute = $attribute;
            $searched_data->response_data_count = ($searched_data->response_data_count ?? 0) + ($response_data_count ?? 0);
            $searched_data->volume = ($searched_data->volume ?? 0) + 1;
            $searched_data->save();
        } catch (\Throwable $e) {
            report($e);
        }
    }

    protected function search_log_volume_update($user_id, $attribute_id)
    {
        SearchedData::where(['user_id' => $user_id, 'attribute_id' =>  $attribute_id])->increment('volume', 1);
    }
}
