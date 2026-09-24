<!DOCTYPE html>
<html lang="en">
<head>
    <title>{{translate('ServiceMan_Login')}}</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    @php($favIcon = getBusinessSettingsImageFullPath(key: 'business_favicon', settingType: 'business_information', path: 'business/', defaultPath: 'public/assets/admin-module/img/placeholder.png'))
    <link rel="shortcut icon" href="{{ $favIcon }}"/>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,400&display=swap" rel="stylesheet"/>
    <link href="{{asset('public/assets/provider-module')}}/css/material-icons.css" rel="stylesheet"/>
    <link rel="stylesheet" href="{{asset('public/assets/provider-module')}}/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="{{asset('public/assets/provider-module')}}/plugins/perfect-scrollbar/perfect-scrollbar.min.css"/>
    <link rel="stylesheet" href="{{asset('public/assets/provider-module')}}/css/style.css"/>
    <link rel="stylesheet" href="{{asset('public/assets/provider-module')}}/css/toastr.css">
    <style>
        .login-left { background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%) !important; }
        .btn--primary { background: #1a73e8 !important; }
        .btn--primary:hover { background: #1557b0 !important; }
        .c1 { color: #1a73e8 !important; }
    </style>
</head>
<body>
<div class="preloader"></div>
<?php $logo = getBusinessSettingsImageFullPath(key: 'business_logo', settingType: 'business_information', path: 'business/', defaultPath: 'public/assets/admin-module/img/placeholder.png'); ?>
<div>
    <form action="{{route('serviceman.auth.login')}}" enctype="multipart/form-data" method="POST" id="login-form">
        @csrf
        <div class="login-wrap">
            <div class="login-left d-flex justify-content-center align-items-center bg-center" data-bg-img="{{asset('public/assets/provider-module')}}/img/media/login-bg.png">
                <div class="tf-box d-flex flex-column gap-3 align-items-center justify-content-center p-5 mx-4 mx-sm-5 h-75">
                    <img class="login-logo mb-2" src="{{ $logo }}" alt="{{ translate('logo') }}">
                    <h2 class="text-center text-white px-xl-5">Service Man <strong class="text-warning"><br>Panel</strong></h2>
                    <p class="text-white-50 text-center">Manage your assigned bookings and services</p>
                </div>
            </div>
            <div class="login-right-wrap bg-white">
                <div class="login-right w-100 m-auto p-3">
                    <div class="d-flex justify-content-between align-items-start gap-2 mb-5 mt-3">
                        <div class="d-flex flex-column gap-2">
                            <h2 class="c1 fw-medium">{{translate('ServiceMan_Sign_In')}}</h2>
                            <p>{{translate('sign_in_to_stay_connected')}}</p>
                        </div>
                        <span class="badge badge-primary fz-12 opacity-75">
                            {{translate('Software_Version')}} : {{ env('SOFTWARE_VERSION') }}
                        </span>
                    </div>

                    <div class="mb-4">
                        <div class="mb-5">
                            <div class="form-floating form-floating__icon">
                                <input type="email" name="email_or_phone" class="form-control" value="{{ request()->cookie('serviceman_remember_email') }}"
                                        placeholder="{{translate('email')}}" required="" id="email">
                                <label>{{translate('email_or_phone')}}</label>
                                <span class="material-icons">mail</span>
                            </div>
                        </div>
                        <div class="mb-3">
                            <div class="form-floating form-floating__icon">
                                <input type="password" name="password" class="form-control" value="{{ request()->cookie('serviceman_remember_password') }}"
                                        placeholder="{{translate('password')}}" required="" id="password">
                                <label>{{translate('password')}}</label>
                                <span class="material-icons togglePassword">visibility_off</span>
                                <span class="material-icons">lock</span>
                            </div>
                        </div>
                        <div class="d-flex justify-content-between">
                            <div class="d-flex gap-1 align-items-center">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="remember" value="1" id="rememberMeCheckbox" {{ request()->cookie('serviceman_remember_checked') ? 'checked' : '' }}>
                                    <label class="form-check-label" for="rememberMeCheckbox">{{translate('Remember me?')}}</label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex mb-4">
                        <button class="btn flex-grow-1 btn--primary text-capitalize" type="submit">{{translate('login')}}</button>
                    </div>

                    <div class="text-center fz-12 pb-4">
                        <a href="{{route('provider.auth.login')}}" class="c1">{{translate('Provider? Login here')}}</a>
                        <span class="mx-2">|</span>
                        <a href="{{route('admin.auth.login')}}" class="c1">{{translate('Admin? Login here')}}</a>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<script src="{{asset('public/assets/provider-module')}}/js/jquery-3.6.0.min.js"></script>
<script src="{{asset('public/assets/provider-module')}}/js/bootstrap.bundle.min.js"></script>
<script src="{{asset('public/assets/provider-module')}}/plugins/perfect-scrollbar/perfect-scrollbar.min.js"></script>
<script src="{{asset('public/assets/provider-module')}}/js/main.js"></script>
<script src="{{asset('public/assets/provider-module')}}/js/sweet_alert.js"></script>
<script src="{{asset('public/assets/provider-module')}}/js/toastr.js"></script>
{!! Toastr::message() !!}

<script>
    "use strict";
    @if ($errors->any())
        @foreach($errors->all() as $error)
            toastr.error('{{$error}}', 'Error', { CloseButton: true, ProgressBar: true });
        @endforeach
    @endif
</script>
</body>
</html>
