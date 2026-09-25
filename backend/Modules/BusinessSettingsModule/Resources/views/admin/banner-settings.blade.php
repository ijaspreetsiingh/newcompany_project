@extends('adminmodule::layouts.new-master')

@section('title',translate('App_banner_settings'))

@section('content')
    <div class="main-content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <div class="page-title-wrap mb-3">
                        <h2 class="page-title">{{translate('App_banner_settings')}}</h2>
                    </div>

                    @include('businesssettingsmodule::admin.configurations.third-party.banner-settings', [
                        'bannerSettings' => $bannerSettings,
                        'sliderBanners'  => $sliderBanners ?? collect(),
                    ])
                </div>
            </div>
        </div>
    </div>
@endsection
