<!DOCTYPE html>
<html lang="en" dir="{{$site_direction ?? 'ltr'}}">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', translate('ServiceMan_Panel'))</title>
    @php($favIcon = getBusinessSettingsImageFullPath(key: 'business_favicon', settingType: 'business_information', path: 'business/', defaultPath: 'public/assets/admin-module/img/placeholder.png'))
    <link rel="shortcut icon" href="{{ $favIcon }}"/>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,400&display=swap" rel="stylesheet">
    <link href="{{asset('public/assets/serviceman-module')}}/css/material-icons.css" rel="stylesheet"/>
    <link rel="stylesheet" href="{{asset('public/assets/serviceman-module')}}/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="{{asset('public/assets/serviceman-module')}}/plugins/perfect-scrollbar/perfect-scrollbar.min.css"/>
    <link rel="stylesheet" href="{{asset('public/assets/serviceman-module')}}/plugins/apex/apexcharts.css"/>
    <link rel="stylesheet" href="{{asset('public/assets/serviceman-module')}}/css/style.css"/>
    <link rel="stylesheet" href="{{asset('public/assets/serviceman-module')}}/css/toastr.css">
    <link rel="stylesheet" href="{{asset('public/assets/common/css/common.css')}}">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
    @stack('css_or_js')
</head>
<body>
    <div class="offcanvas-overlay"></div>
    <div class="preloader"></div>

    @include('servicemanmodule::layouts.partials._header')
    @include('servicemanmodule::layouts.partials._aside')

    <main class="main-area">
        <div class="main-content">
            @if(session('success'))
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    {{ session('success') }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            @endif
            @if(session('error'))
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    {{ session('error') }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            @endif
            @yield('content')
        </div>
        @include('servicemanmodule::layouts.partials._footer')
    </main>

    <script src="{{asset('public/assets/serviceman-module')}}/js/jquery-3.6.0.min.js"></script>
    <script src="{{asset('public/assets/serviceman-module')}}/js/bootstrap.bundle.min.js"></script>
    <script src="{{asset('public/assets/serviceman-module')}}/plugins/perfect-scrollbar/perfect-scrollbar.min.js"></script>
    <script src="{{asset('public/assets/serviceman-module')}}/js/main.js"></script>
    <script src="{{asset('public/assets/serviceman-module')}}/plugins/apex/apexcharts.min.js"></script>
    <script src="{{asset('public/assets/serviceman-module')}}/js/toastr.js"></script>
    <script src="{{asset('public/assets/serviceman-module')}}/js/sweet_alert.js"></script>
    <script src="{{asset('public/assets/common/js/common.js')}}"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
    {!! Toastr::message() !!}
    @stack('script')
</body>
</html>
