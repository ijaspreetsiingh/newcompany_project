@extends('adminmodule::layouts.master')

@section('title',translate('update_provider'))

@push('css_or_js')
    <link rel="stylesheet" href="{{asset('public/assets/admin-module/plugins/swiper/swiper-bundle.min.css')}}">
@endpush

@section('content')
    <div class="main-content">
        <div class="container-fluid">

            <form action="{{route('admin.provider.update', [$provider->id])}}" method="POST" id="create-provider-form"
                  enctype="multipart/form-data">
                @csrf
                @method('PUT')
                <h3>{{translate('Step 1')}}</h3>
                <section>
                    <div class="page-title-wrap mb-3">
                        <h2 class="page-title">{{translate('update_Provider')}}</h2>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex flex-wrap gap-4 create-provider-item mb-4">
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{ translate('Basic info') }}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="icon-2">2</span>
                                    {{ translate('Set Business Plan') }}
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6" id="register-form-p-0">
                                    <h4 class="c1 mb-20">{{translate('General_Information')}}</h4>
                                    <div class="form-floating form-floating__icon mb-30">
                                        <input type="text" class="form-control"
                                               value="{{$provider->company_name}}"
                                               name="company_name" required maxlength="191"
                                               placeholder="{{translate('Company_/_Individual_Name')}}">
                                        <label>{{translate('Company_/_Individual_Name')}}</label>
                                        <span class="material-icons">store</span>
                                    </div>
                                    <div class="form-floating form-floting-fix mb-30">
                                        <label for="company_phone">
                                            {{translate('Phone')}}
                                        </label>
                                        <input type="tel" class="form-control"
                                               id="company_phone"
                                               name="company_phone" value="{{$provider->company_phone}}"
                                               placeholder="{{translate('Phone')}}" required>
                                    </div>
                                    <div class="form-floating form-floating__icon mb-30">
                                        <input type="email" class="form-control"
                                               name="company_email" value="{{$provider->company_email}}"
                                               placeholder="{{translate('Email')}}" required>
                                        <label>{{translate('Email')}}</label>
                                        <span class="material-icons">mail</span>
                                    </div>
                                    <div class="form-floating mb-30">
                                        <select class="select-identity theme-input-style w-100" name="zone_id"
                                                required>
                                            <option disabled selected>{{translate('Select_Zone')}}</option>
                                            @foreach($zones as $zone)
                                                <option value="{{$zone->id}}"
                                                    {{$provider->zone_id == $zone->id ? 'selected': ''}}>
                                                    {{$zone->name}}</option>
                                            @endforeach
                                        </select>
                                    </div>
                                    <div class="form-floating mb-30">
                                                <textarea class="form-control resize-none" placeholder="{{translate('Address')}}"
                                                          name="company_address"
                                                          required>{{$provider->company_address}}</textarea>
                                                <label>{{translate('Address')}}</label>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="d-flex flex-column align-items-center gap-3">
                                                <h3 class="mb-0">{{translate('Company_Logo')}}</h3>
                                                <div>
                                                    <div class="upload-file">
                                                        <input type="file" class="upload-file__input" name="logo"
                                                               accept=".{{ implode(',.', array_column(IMAGEEXTENSION, 'key')) }}, |image/*"
                                                               data-maxFileSize="{{ readableUploadMaxFileSize('image') }}">
                                                        <div class="upload-file__img">
                                                            <img src="{{ $provider->logo_full_path }}" alt="{{translate('image')}}">
                                                        </div>
                                                        <span class="upload-file__edit">
                                                            <span class="material-icons">edit</span>
                                                        </span>
                                            </div>
                                        </div>
                                                <p class="opacity-75 max-w220">
                                                    {{ translate('Image format -')}} {{ implode(', ', array_column(IMAGEEXTENSION, 'key')) }}
                                                    {{ translate("Image Size") }} - {{ translate('maximum size') }} {{ readableUploadMaxFileSize('image') }}
                                                    {{ translate('Image Ratio') }} - 1:1
                                                </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row gx-2 mt-2">
                        <div class="col-md-6">
                            <div class="card h-100">
                                <div class="card-body">
                                    <h4 class="c1 mb-20">{{translate('Business Information')}}</h4>
                                    <div class="mb-30">
                                        <select class="select-identity theme-input-style w-100"
                                                name="identity_type" required>
                                            <option selected
                                                    disabled>{{translate('Select_Identity_Type')}}</option>
                                            <option value="passport"
                                                {{$provider->owner->identification_type == 'passport' ? 'selected': ''}}>
                                                {{translate('Passport')}}</option>
                                            <option value="driving_license"
                                                {{$provider->owner->identification_type == 'driving_license' ? 'selected': ''}}>
                                                {{translate('Driving_License')}}</option>
                                            <option value="nid"
                                                {{$provider->owner->identification_type == 'nid' ? 'selected': ''}}>
                                                {{translate('nid')}}</option>
                                            <option value="trade_license"
                                                {{$provider->owner->identification_type == 'trade_license' ? 'selected': ''}}>
                                                {{translate('Trade_License')}}</option>
                                        </select>
                                    </div>
                                    <div class="form-floating form-floating__icon mb-30">
                                        <input type="text" class="form-control" name="identity_number"
                                               value="{{$provider->owner->identification_number}}"
                                               placeholder="{{translate('Identity_Number')}}" required>
                                        <label>{{translate('Identity_Number')}}</label>
                                        <span class="material-icons">badge</span>
                                    </div>

                                            <div class="upload-file w-100">
                                                <h3 class="mb-3">{{translate('Identification_Image')}}</h3>
                                                <div id="multi_image_picker">
                                                    @foreach($provider->owner->identification_image_full_path as $image)
                                                        <img class="p-1" height="150" src="{{ $image }}" alt="{{translate('image')}}">
                                                    @endforeach
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="card h-100">
                                        <div class="card-body">
                                            <div class="d-flex flex-wrap justify-content-between gap-3 mb-20">
                                                <h4 class="c1">{{translate('Contact_Person')}}</h4>
                                            </div>
                                            <div class="form-floating form-floating__icon mb-30">
                                                <input type="text" class="form-control" name="contact_person_name"
                                                       value="{{$provider->contact_person_name}}" placeholder="name"
                                                       maxlength="191" required>
                                                <label>{{translate('Name')}}</label>
                                                <span class="material-icons">account_circle</span>
                                            </div>
                                            <div class="row gx-2">
                                                <div class="col-lg-6">
                                                    <div class="form-floating form-floting-fix mb-30">
                                                        <label for="contact_person_phone">{{translate('Phone')}}</label>
                                                        <input type="tel" class="form-control"
                                                               name="contact_person_phone"
                                                               id="contact_person_phone"
                                                               value="{{$provider->contact_person_phone}}"
                                                               placeholder="{{translate('Phone')}}"
                                                               required>
                                                    </div>
                                                </div>
                                                <div class="col-lg-6">
                                                    <div class="form-floating form-floating__icon mb-30">
                                                        <input type="email" class="form-control"
                                                               name="contact_person_email"
                                                               value="{{$provider->contact_person_email}}"
                                                               placeholder="{{translate('Email')}}"
                                                               required>
                                                        <label>{{translate('Email')}}</label>
                                                        <span class="material-icons">mail</span>
                                                    </div>
                                                </div>
                                            </div>

                                    <h4 class="c1 mb-20">{{translate('Account_Information')}}</h4>
                                    <div class="form-floating form-floating__icon mb-30">
                                        <input type="email" class="form-control"
                                               name="company_email" value="{{$provider->owner->email}}" readonly
                                               placeholder="{{translate('Email')}}" required>
                                        <label>{{translate('Email')}}</label>
                                        <span class="material-icons">mail</span>
                                    </div>
                                    <div class="form-floating form-floting-fix mb-30">
                                        <label for="account_phone">{{translate('Phone')}}</label>
                                        <input type="tel" class="form-control"
                                                name="account_phone"
                                                id="account_phone"
                                                value="{{$provider->owner->phone}}"
                                                placeholder="{{translate('Phone')}}"
                                               readonly
                                                required >
                                    </div>
                                    <div class="row gx-2">
                                        <div class="col-lg-6">
                                            <div class="form-floating form-floating__icon mb-30">
                                                <input type="password" class="form-control" name="password"
                                                       placeholder="{{translate('Password')}}">
                                                <label>{{translate('Password')}}</label>
                                                <span class="material-icons">lock</span>
                                                <span class="material-icons togglePassword __right-eye">visibility_off</span>
                                            </div>
                                        </div>
                                        <div class="col-lg-6">
                                            <div class="form-floating form-floating__icon mb-30">
                                                <input type="password" class="form-control"
                                                       name="confirm_password"
                                                       placeholder="{{translate('Confirm_Password')}}">
                                                <label>{{translate('Confirm_Password')}}</label>
                                                <span class="material-icons togglePassword __right-eye">visibility_off</span>
                                                <span class="material-icons">lock</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 mt-4">
                        <div class="card h-100">
                            <div class="card-body">
                                <div class="d-flex flex-wrap justify-content-between gap-3 mb-20">
                                    <h4 class="c1">{{translate('Select Address from Map')}}</h4>
                                </div>
                                <div class="row gx-2">
                                    <div class="col-md-6 col-12">
                                        <div class="mb-30">
                                            <div class="form-floating form-floating__icon">
                                                <input type="text" class="form-control" name="latitude"
                                                       id="latitude"
                                                       placeholder="{{translate('latitude')}} *"
                                                       value="{{$provider->coordinates['latitude'] ?? null}}"
                                                       required readonly
                                                       data-bs-toggle="tooltip" data-bs-placement="top"
                                                       title="{{translate('Select from map')}}">
                                                <label>{{translate('latitude')}} *</label>
                                                <span class="material-icons">location_on</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6 col-12">
                                        <div class="mb-30">
                                            <div class="form-floating form-floating__icon">
                                                <input type="text" class="form-control" name="longitude"
                                                       id="longitude"
                                                       placeholder="{{translate('longitude')}} *"
                                                       value="{{$provider->coordinates['longitude'] ?? null}}"
                                                       required readonly
                                                       data-bs-toggle="tooltip" data-bs-placement="top"
                                                       title="{{translate('Select from map')}}">
                                                <label>{{translate('longitude')}} *</label>
                                                <span class="material-icons">location_on</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-12">
                                        <div id="location_map_div" class="location_map_class">
                                            <input id="pac-input" class="form-control w-auto"
                                                   data-toggle="tooltip"
                                                   data-placement="right"
                                                   data-original-title="{{ translate('search_your_location_here') }}"
                                                   type="text" placeholder="{{ translate('search_here') }}"/>
                                            <div id="location_map_canvas"
                                                 class="overflow-hidden rounded canvas_class"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <h3>{{translate('Step 2')}}</h3>
                <section id="business-plan-section">
                    <div class="page-title-wrap mb-3">
                        <h2 class="page-title mb-2">{{translate('Update Provider')}}</h2>
                        <p class="page-title-text">{{translate('Setup Provider information and business plan from here')}} </p>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex flex-wrap gap-4 create-provider-item mb-4">
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{translate('Basic info')}}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{translate('Set Business Plan')}}
                                </div>
                            </div>

                            <h4>{{translate('Choose Business Plan')}}</h4>
                            <div class="col-sm-10 col-md-5 pt-1 pb-1">
                                <div class="border-bottom mt-3 mb-4"></div>
                            </div>
                            <div class="row g-4">
                                @if($commission)
                                    <div class="col-sm-6">
                                        <label class="input-radio-item">
                                            <input type="radio" class="subscription-type" name="plan_type" value="commission_based" {{ !$packageSubscription ? 'checked' : '' }}>
                                            <div class="inner">
                                                <div class="w-0 flex-grow-1">
                                                    <h5>{{translate('Commission Base')}}</h5>
                                                    <p>
                                                        {{translate('You have to give a certain percentage of commission to admin for every booking request')}}
                                                    </p>
                                                </div>
                                            </div>
                                        </label>
                                    </div>
                                @endif
                                @if($subscription)
                                    <div class="col-sm-6">
                                        <label class="input-radio-item">
                                            <input type="radio" class="subscription-type" name="plan_type" value="subscription_based"  {{ $packageSubscription ? 'checked' : '' }}>
                                            <div class="inner">
                                                <div class="w-0 flex-grow-1">
                                                    <h5>{{translate('Subscription Base')}}</h5>
                                                    <p>
                                                        {{translate('You have to pay a certain amount in every month / year to admin as subscription fee')}}
                                                    </p>
                                                </div>
                                            </div>
                                        </label>
                                    </div>
                                @endif
                            </div>
                            <div id="subscription-based-plan" class="collapse">
                                <div class="pt-4">
                                    <div class="py-3">

                                        @if($subscription)
                                            <div class="priceBoxSwiper-wrap">
                                                <h3 class="font-bold text-center mb-4">Select Plan</h3>
                                                <div class="w-100">
                                                    <input type="hidden" name="selected_package_id" id="selected-package-input" value="">
                                                    <div dir="ltr" class="swiper price-box-slider">
                                                        <div class="swiper-wrapper">
                                                            @foreach($formattedPackages as $index => $package)
                                                                <div class="swiper-slide h-auto">
                                                                    <label class="d-block plan-item">
                                                                        <input type="radio" name="plan" id="{{ $package->id }}" {{ $packageSubscription?->subscription_package_id ==  $package->id ? 'checked' : '' }} class="package-option" data-id="{{ $package->id }}">
                                                                        <div class="plan-item-inner">
                                                                            <div class="name">
                                                                                <div class="circle"></div>
                                                                                <span class="name-content">{{ $package->name }}</span>
                                                                            </div>
                                                                            <div class="price">{{ with_currency_symbol($package->price) }}</div>
                                                                            <span>{{ $package->duration }} {{translate('Days')}}</span>
                                                                            <ul class="info">
                                                                                @foreach($package->feature_list as $feature)
                                                                                    <li>{{ $feature }}</li>
                                                                                @endforeach
                                                                            </ul>
                                                                        </div>
                                                                    </label>
                                                                </div>
                                                            @endforeach
                                                        </div>
                                                        <div class="swiper-button-next"></div>
                                                        <div class="swiper-button-prev"></div>
                                                    </div>
                                                </div>
                                            </div>
                                        @endif
                                    </div>
                                </div>
                            </div>
                            <div class="modal fade" id="paymentModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header border-0 pb-0">
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body pt-0">
                                            <div class="text-center px-xl-4 pb-4">
                                                <img src="{{asset('/public/assets/admin-module/img/provider-create.png')}}" alt="">
                                                <h4 class="mb-4 pb-3">{{translate('Select Payment Option')}}</h4>
                                                <div class="row g-3">
                                                    <div class="col-sm-12">
                                                        <label class="input-radio-item">
                                                            <input type="radio" name="plan_price" value="received_money" checked>
                                                            <div class="inner">
                                                                <div class="w-0 flex-grow-1">
                                                                    <h4 class="m-0 text-start">{{translate('Received Money Manually')}}</h4>
                                                                </div>
                                                            </div>
                                                        </label>
                                                    </div>
                                                    @if($freeTrialStatus)
                                                        <div class="col-sm-12">
                                                            <label class="input-radio-item">
                                                                <input type="radio" name="plan_price" value="free_trial">
                                                                <div class="inner">
                                                                    <div class="w-0 flex-grow-1">
                                                                        <h4 class="m-0 text-start">{{translate('Continue with Free Trial')}} {{ $duration }} {{translate('days')}}</h4>
                                                                    </div>
                                                                </div>
                                                            </label>
                                                        </div>
                                                    @endif
                                                </div>
                                                <div class="d-flex gap-4 flex-wrap justify-content-center mt-4 pt-2">
                                                    <button type="button" class="btn btn--secondary" data-bs-dismiss="modal">{{translate('Cancel')}}</button>
                                                    <button type="button" class="btn btn--primary pay_complete_btn">{{translate('Complete')}}</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <h3>{{translate('Step 3')}} : {{translate('Provider Subscribe')}}</h3>
                <section>
                    <div class="page-title-wrap mb-3">
                        <h2 class="page-title mb-2">{{translate('Provider Subscribe')}}</h2>
                        <p class="page-title-text">{{translate('Turn ON to give the provider permanent access — no subscription needed, business plan stays off until you turn this OFF. Turn OFF for the normal subscription flow.')}}</p>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex flex-wrap gap-4 create-provider-item mb-4">
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{translate('Basic info')}}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{translate('Set Business Plan')}}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{translate('Provider Subscribe')}}
                                </div>
                            </div>

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="mb-2 text-dark">{{translate('Permanent Access')}}</label>
                                    <p class="fz-12 mb-10">{{translate('ON = provider gets permanent access: subscription + business plan stay OFF for him until you turn this off. OFF = normal flow, provider must subscribe via Business Plan.')}}</p>
                                    <div class="border p-12 rounded d-flex justify-content-between bg-white">
                                        <span class="text-dark fz-14">{{translate('Provider Subscribe')}}</span>
                                        <label class="switcher">
                                            <input class="switcher_input" type="checkbox"
                                                   id="subscription_required"
                                                   name="subscription_required"
                                                   value="1"
                                                   onchange="toggleBusinessPlanSection()"
                                                {{ old('subscription_required', ($provider->subscription_required ?? 1) == 0) ? 'checked' : '' }}>
                                            <span class="switcher_control"></span>
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <h3>{{translate('Step 4')}} : {{translate('Independent Commission')}}</h3>
                <section>
                    <div class="page-title-wrap mb-3">
                        <h2 class="page-title mb-2">{{translate('Independent Commission')}}</h2>
                        <p class="page-title-text">{{translate('ON = provider runs on independent commission: admin gets Admin %, provider gets Provider % and the rest goes to his servicemen from every booking payment. OFF = existing commission/subscription flow continues.')}}</p>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex flex-wrap gap-4 create-provider-item mb-4">
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{translate('Basic info')}}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{translate('Set Business Plan')}}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{translate('Provider Subscribe')}}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="icon-4">4</span>
                                    {{translate('Independent Commission')}}
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="mb-2 text-dark">{{translate('Allow Independent Commission')}}</label>
                                        <p class="fz-12 mb-10">{{translate('ON = set Admin %, Provider %, payment fee, tax, customer booking fee and allowed payment gateways below for this provider. OFF = nothing changes, existing flow keeps working.')}}</p>
                                    <div class="border p-12 rounded d-flex justify-content-between bg-white">
                                        <span class="text-dark fz-14">{{translate('Independent Commission')}}</span>
                                        <label class="switcher">
                                            <input class="switcher_input" type="checkbox"
                                                   id="independent_mode"
                                                   name="independent_mode"
                                                   value="1"
                                                {{ old('independent_mode', $provider->independent_mode ?? 0) ? 'checked' : '' }}>
                                            <span class="switcher_control"></span>
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <div id="independent-commission-fields" class="row g-3" style="{{ old('independent_mode', $provider->independent_mode ?? 0) ? '' : 'display:none;' }}">
                                <div class="col-md-6">
                                    <label class="mb-2 text-dark">{{translate('Admin / System Commission (%)')}}</label>
                                    <p class="fz-12 mb-10">{{translate('Example: 2 = admin receives 2% from every booking payment of this provider.')}}</p>
                                    <div class="form-floating form-floating__icon">
                                        <input type="number" class="form-control" name="admin_commission_percent"
                                               id="admin_commission_percent" min="0" max="100" step="0.01"
                                               placeholder="{{translate('Admin Commission (%)')}}"
                                               value="{{ old('admin_commission_percent', $provider->admin_commission_percent ?? 0) }}">
                                        <label>{{translate('Admin Commission (%)')}} *</label>
                                        <span class="material-icons">percent</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="mb-2 text-dark">{{translate('Provider Commission (%)')}}</label>
                                    <p class="fz-12 mb-10">{{translate('Example: 8 = provider receives 8% from every booking payment. Rest goes to his servicemen.')}}</p>
                                    <div class="form-floating form-floating__icon">
                                        <input type="number" class="form-control" name="provider_commission_percent"
                                               id="provider_commission_percent" min="0" max="100" step="0.01"
                                               placeholder="{{translate('Provider Commission (%)')}}"
                                               value="{{ old('provider_commission_percent', $provider->provider_commission_percent ?? 0) }}">
                                        <label>{{translate('Provider Commission (%)')}} *</label>
                                        <span class="material-icons">percent</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="mb-2 text-dark">{{translate('Payment Fee Amount')}}</label>
                                    <p class="fz-12 mb-10">{{translate('Flat fee deducted from this provider payment on every booking. Customer price does not change.')}}</p>
                                    <div class="form-floating form-floating__icon">
                                        <input type="number" class="form-control" name="platform_fee_amount"
                                               id="platform_fee_amount" min="0" step="0.01"
                                               placeholder="{{translate('Payment Fee Amount')}}"
                                               value="{{ old('platform_fee_amount', $provider->platform_fee_amount ?? 0) }}">
                                        <label>{{translate('Payment Fee Amount')}}</label>
                                        <span class="material-icons">payments</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="mb-2 text-dark">{{translate('Payment Fee Label (text)')}}</label>
                                    <p class="fz-12 mb-10">{{translate('Text shown for the fee, e.g. Platform Fee / Convenience Fee.')}}</p>
                                    <div class="form-floating form-floating__icon">
                                        <input type="text" class="form-control" name="platform_fee_label"
                                               id="platform_fee_label" maxlength="191"
                                               placeholder="{{translate('Payment Fee Label')}}"
                                               value="{{ old('platform_fee_label', $provider->platform_fee_label ?? '') }}">
                                        <label>{{translate('Payment Fee Label')}}</label>
                                        <span class="material-icons">label</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="mb-2 text-dark">{{translate('Tax (%) for this provider')}}</label>
                                    <p class="fz-12 mb-10">{{translate('Tax applied on this provider services at checkout. Leave empty = each service own tax is used.')}}</p>
                                    <div class="form-floating form-floating__icon">
                                        <input type="number" class="form-control" name="tax_percent"
                                               id="tax_percent" min="0" max="100" step="0.01"
                                               placeholder="{{translate('Tax (%)')}}"
                                               value="{{ old('tax_percent', $provider->tax_percent ?? '') }}">
                                        <label>{{translate('Tax (%)')}}</label>
                                        <span class="material-icons">percent</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="mb-2 text-dark">{{translate('Customer Booking Fee')}}</label>
                                    <p class="fz-12 mb-10">{{translate('Flat booking fee charged to the customer for this provider. 0 = global booking fee applies.')}}</p>
                                    <div class="form-floating form-floating__icon">
                                        <input type="number" class="form-control" name="booking_fee"
                                               id="booking_fee" min="0" step="0.01"
                                               placeholder="{{translate('Booking Fee')}}"
                                               value="{{ old('booking_fee', $provider->booking_fee ?? 0) }}">
                                        <label>{{translate('Booking Fee')}}</label>
                                        <span class="material-icons">receipt_long</span>
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <label class="mb-2 text-dark">{{translate('Allowed Payment Gateways')}}</label>
                                    <p class="fz-12 mb-10">{{translate('Customer checkout par sirf ticked payment options dikhenge aur chalenge. None ticked = all options allowed.')}}</p>
                                    @php
                                        $selectedPaymentMethods = providerAllowedPaymentMethods($provider) ?? [];
                                        $paymentGatewayOptions = paymentGatewayOptions();
                                    @endphp
                                    <div class="border rounded p-12 bg-white">
                                        <div class="row g-2">
                                            @foreach ($paymentGatewayOptions as $gatewayOption)
                                                <div class="col-md-4 col-sm-6">
                                                    <label class="d-flex align-items-center gap-2 border rounded p-2 bg-light h-100">
                                                        <input type="checkbox" class="form-check-input m-0"
                                                               name="allowed_payment_methods[]"
                                                               value="{{ $gatewayOption['key'] }}"
                                                               @checked(in_array($gatewayOption['key'], $selectedPaymentMethods, true))>
                                                        <span class="fz-14 text-dark">{{ $gatewayOption['label'] }}</span>
                                                    </label>
                                                </div>
                                            @endforeach
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <style>
                        #independent-commission-fields { display: none !important; }
                        body:has(#independent_mode:checked) #independent-commission-fields { display: flex !important; }
                    </style>
                    <script>
                        (function () {
                            function syncIndependentFields() {
                                var box = document.getElementById('independent_mode');
                                var fields = document.getElementById('independent-commission-fields');
                                if (!box || !fields) return;
                                fields.style.setProperty('display', box.checked ? 'flex' : 'none', 'important');
                            }
                            document.addEventListener('change', function (e) {
                                if (e.target && e.target.id === 'independent_mode') syncIndependentFields();
                            }, true);
                            document.addEventListener('click', function (e) {
                                var t = e.target;
                                if (t && t.id === 'independent_mode') syncIndependentFields();
                            }, true);
                            if (document.readyState === 'loading') {
                                document.addEventListener('DOMContentLoaded', syncIndependentFields);
                            }
                            syncIndependentFields();
                        })();
                    </script>
                </section>
                <h3>{{translate('Step 5')}} : {{translate('Category Assignment')}}</h3>
                <section id="step5-category-assignment">
                    <div class="page-title-wrap mb-3">
                        <h2 class="page-title mb-2">{{translate('Category Assignment')}}</h2>
                        <p class="page-title-text">{{translate('Assign main category or sub-categories to provider. Same zone + same category/sub-category = only one provider allowed.')}}</p>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex flex-wrap gap-4 create-provider-item mb-4">
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{translate('Basic info')}}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{translate('Set Business Plan')}}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{translate('Provider Subscribe')}}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{translate('Independent Commission')}}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="icon-5">5</span>
                                    {{translate('Category Assignment')}}
                                </div>
                            </div>

                            @php
                                $assignedRows = $provider->subscribed_services()->where('zone_id', $provider->zone_id)->get();

                                $oldComplete = old('complete_main_category_ids');
                                $prefillComplete = is_array($oldComplete)
                                    ? array_values(array_unique($oldComplete))
                                    : $assignedRows->where('assign_type', 'complete')->pluck('category_id')->unique()->values()->all();

                                $oldSpecific = old('sub_category_ids');
                                $prefillSpecific = is_array($oldSpecific)
                                    ? array_values(array_unique($oldSpecific))
                                    : $assignedRows->where('assign_type', 'specific')->pluck('sub_category_id')->unique()->values()->all();

                                $mainName = [];
                                $subCount = [];
                                foreach ($mainCategories as $mainCat) {
                                    $mainName[$mainCat->id] = $mainCat->name;
                                    $subCount[$mainCat->id] = $subCategories->where('parent_id', $mainCat->id)->count();
                                }

                                $subParentId = [];
                                $subParentName = [];
                                foreach ($subCategories as $subCat) {
                                    $subParentId[$subCat->id] = $subCat->parent_id;
                                    $subParentName[$subCat->id] = $mainName[$subCat->parent_id] ?? '';
                                }

                                $cascadeParent = '';
                                foreach ($prefillSpecific as $subId) {
                                    if (isset($subParentId[$subId]) && ($subCount[$subParentId[$subId]] ?? 0) > 0) {
                                        $cascadeParent = $subParentId[$subId];
                                        break;
                                    }
                                }
                                if ($cascadeParent === '') {
                                    foreach ($subCount as $mainId => $cnt) {
                                        if ($cnt > 0) { $cascadeParent = $mainId; break; }
                                    }
                                }
                            @endphp

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="mb-2 text-dark">{{translate('Switch 1 - Give complete main categories')}}</label>
                                    <p class="fz-12 mb-10">{{translate('ON = one field appears below. Tick any main category - this provider gets that main category plus all of its sub-categories. No other provider in the same zone can take any of them. You can tick more than one.')}}</p>
                                    <div class="border p-12 rounded d-flex justify-content-between bg-white">
                                        <span class="text-dark fz-14">{{translate('Complete main category')}}</span>
                                        <label class="switcher">
                                            <input class="switcher_input" type="checkbox" id="complete_mode"
                                                {{ count($prefillComplete) ? 'checked' : '' }}>
                                            <span class="switcher_control"></span>
                                        </label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="mb-2 text-dark">{{translate('Switch 2 - Give specific sub-categories')}}</label>
                                    <p class="fz-12 mb-10">{{translate('ON = two fields appear below. First pick a main category, then tick only its sub-categories. This switch can stay ON together with Switch 1.')}}</p>
                                    <div class="border p-12 rounded d-flex justify-content-between bg-white">
                                        <span class="text-dark fz-14">{{translate('Specific sub-category')}}</span>
                                        <label class="switcher">
                                            <input class="switcher_input" type="checkbox" id="specific_mode"
                                                {{ (count($prefillSpecific) || !count($prefillComplete)) ? 'checked' : '' }}>
                                            <span class="switcher_control"></span>
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <!-- Switch 1 : one field - tick main categories -->
                            <div id="complete-main-category-fields" class="row g-3">
                                <div class="col-md-12">
                                    <label class="mb-2 text-dark d-block">1. Tick the main categories to give</label>
                                    <p class="fz-12 mb-10">{{translate('Every ticked main category gives this provider that main category plus all of its sub-categories. Untick to remove it.')}}</p>
                                    <div class="option-list" id="complete-list">
                                        @foreach($mainCategories as $mainCat)
                                            <label class="option-item">
                                                <input type="checkbox" name="complete_main_category_ids[]" class="opt-input"
                                                       value="{{ $mainCat->id }}"
                                                       data-subs="{{ $subCount[$mainCat->id] }}"
                                                       data-name="{{ $mainCat->name }}"
                                                    {{ in_array($mainCat->id, $prefillComplete) ? 'checked' : '' }}>
                                                <span class="option-text">{{ $mainCat->name }}</span>
                                                <span class="option-meta">{{ $subCount[$mainCat->id] }} sub-categories</span>
                                            </label>
                                        @endforeach
                                    </div>
                                </div>
                            </div>

                            <!-- Switch 2 : two fields - pick main, then its subs -->
                            <div id="sub-category-only-fields" class="row g-3">
                                <div class="col-md-12">
                                    <label class="mb-2 text-dark d-block">1. Pick a main category</label>
                                    <p class="fz-12 mb-10">{{translate('Only the sub-categories of this main category are listed in the next field.')}}</p>
                                    <div class="form-floating">
                                        <select class="select-identity theme-input-style w-100" id="sub_parent_id">
                                            @foreach($mainCategories as $mainCat)
                                                @if(($subCount[$mainCat->id] ?? 0) > 0)
                                                    <option value="{{ $mainCat->id }}" {{ $cascadeParent == $mainCat->id ? 'selected' : '' }}>
                                                        {{ $mainCat->name }}
                                                    </option>
                                                @endif
                                            @endforeach
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <label class="mb-2 text-dark d-block">2. Tick its sub-categories</label>
                                    <p class="fz-12 mb-10">{{translate('Sub-categories ticked earlier from another main category stay selected - they always show in the list below.')}}</p>
                                    <div class="option-list" id="sub-list">
                                        @foreach($subCategories as $subCat)
                                            <label class="option-item" data-parent="{{ $subParentId[$subCat->id] }}">
                                                <input type="checkbox" name="sub_category_ids[]" class="opt-input"
                                                       value="{{ $subCat->id }}"
                                                       data-parent="{{ $subParentId[$subCat->id] }}"
                                                       data-parent-name="{{ $subParentName[$subCat->id] }}"
                                                       data-name="{{ $subCat->name }}"
                                                    {{ in_array($subCat->id, $prefillSpecific) ? 'checked' : '' }}>
                                                <span class="option-text">{{ $subCat->name }}</span>
                                                <span class="option-meta">{{ $subParentName[$subCat->id] }}</span>
                                            </label>
                                        @endforeach
                                    </div>
                                </div>
                            </div>

                            <!-- Selected for this provider -->
                            <div class="mt-4">
                                <label class="mb-1 text-dark d-block">Selected for this provider</label>
                                <p class="fz-12 mb-10 opacity-75">{{translate('Everything below is saved when you press Update. Click X to remove one.')}}</p>
                                <div id="category-chips" class="d-flex flex-wrap gap-2"></div>
                                <p class="fz-12 mt-2 opacity-75 mb-0 d-none" id="chips-empty">
                                    {{translate('Nothing selected yet. Tick at least one main category or sub-category above.')}}
                                </p>
                            </div>
                        </div>
                    </div>
                    <style>
                        #complete-main-category-fields, #sub-category-only-fields { display: none !important; }

                        .option-list {
                            border: 1px solid var(--bs-border-color, #d9dee5);
                            border-radius: 10px;
                            background: var(--bs-body-bg, #fff);
                            max-height: 340px; overflow: auto; padding: 6px;
                        }
                        .option-item {
                            display: flex; align-items: center; gap: 10px;
                            padding: 10px 12px; border-radius: 8px; cursor: pointer;
                            font-size: 14px; color: var(--bs-body-color, #2b3440);
                        }
                        .option-item:hover { background: rgba(128, 138, 148, .14); }
                        .option-item input { flex: 0 0 auto; width: 16px; height: 16px; cursor: pointer; accent-color: var(--bs-primary, #0d6efd); }
                        .option-text { flex: 1 1 auto; font-weight: 500; }
                        .option-meta {
                            flex: 0 0 auto; font-size: 11px;
                            color: var(--bs-secondary-color, #5b6470);
                            background: rgba(128, 138, 148, .16);
                            border-radius: 6px; padding: 3px 9px; white-space: nowrap;
                        }
                        .option-item:has(input:checked) {
                            background: rgba(var(--bs-primary-rgb, 13, 110, 253), .14);
                            box-shadow: inset 3px 0 0 var(--bs-primary, #0d6efd);
                        }
                        .option-item:has(input:checked) .option-text {
                            font-weight: 700; color: var(--bs-primary, #0d6efd);
                        }

                        #category-chips .chip-badge {
                            display: inline-flex; align-items: center; gap: 8px;
                            border: 1px solid var(--bs-border-color, #d9dee5);
                            background: var(--bs-body-bg, #fff);
                            color: var(--bs-body-color, #2b3440);
                            border-radius: 999px; padding: 7px 14px; font-size: 12px; line-height: 1.4;
                        }
                        #category-chips .chip-badge.chip-complete {
                            border-color: var(--bs-primary, #0d6efd);
                            background: rgba(var(--bs-primary-rgb, 13, 110, 253), .14);
                        }
                        #category-chips .chip-badge.chip-specific {
                            border-color: var(--bs-success, #198754);
                            background: rgba(var(--bs-success-rgb, 25, 135, 84), .14);
                        }
                        #category-chips .chip-x {
                            border: 0; background: transparent; color: var(--bs-danger, #dc3545);
                            font-size: 16px; line-height: 1; cursor: pointer; padding: 0 0 0 2px;
                        }
                        #category-chips .chip-x:hover { opacity: .75; }

                        /* ---------- dark theme ---------- */
                        body[data-bs-theme="dark"] .option-list { background: var(--bs-body-bg); border-color: var(--bs-border-color); }
                        body[data-bs-theme="dark"] .option-item { color: var(--bs-body-color); }
                        body[data-bs-theme="dark"] .option-item:hover { background: rgba(255, 255, 255, .07); }
                        body[data-bs-theme="dark"] .option-meta { background: rgba(255, 255, 255, .10); color: var(--bs-secondary-color); }
                        body[data-bs-theme="dark"] .option-item:has(input:checked) { background: rgba(var(--bs-primary-rgb, 13, 110, 253), .24); }
                        body[data-bs-theme="dark"] .option-item:has(input:checked) .option-text { color: #7fb2ff; }
                        body[data-bs-theme="dark"] #category-chips .chip-badge { background: var(--bs-body-bg); border-color: var(--bs-border-color); color: var(--bs-body-color); }
                        body[data-bs-theme="dark"] #category-chips .chip-badge.chip-complete { background: rgba(var(--bs-primary-rgb, 13, 110, 253), .24); border-color: #3b82f6; }
                        body[data-bs-theme="dark"] #category-chips .chip-badge.chip-specific { background: rgba(var(--bs-success-rgb, 25, 135, 84), .24); border-color: #20c997; }

                        /* ---------- this section only: follow theme ---------- */
                        #step5-category-assignment .text-dark { color: var(--bs-body-color); }
                        #step5-category-assignment .bg-white { background-color: var(--bs-body-bg); border-color: var(--bs-border-color); }
                        #step5-category-assignment .opacity-75 { opacity: .75; }
                        body[data-bs-theme="dark"] #step5-category-assignment .option-list,
                        body[data-bs-theme="dark"] #step5-category-assignment .bg-white { border-color: var(--bs-border-color); }
                    </style>
                    <script>
                        (function () {
                            var completeMode = document.getElementById('complete_mode');
                            var specificMode = document.getElementById('specific_mode');
                            var completeList = document.getElementById('complete-list');
                            var subList = document.getElementById('sub-list');
                            var parentSel = document.getElementById('sub_parent_id');
                            var chipsBox = document.getElementById('category-chips');
                            var emptyHint = document.getElementById('chips-empty');

                            if (!completeMode || !specificMode || !completeList || !subList || !parentSel || !chipsBox) return;

                            function toArray(nodeList) { return Array.prototype.slice.call(nodeList); }
                            function boxes(list) { return toArray(list.querySelectorAll('input.opt-input')); }
                            function ticked(list) { return boxes(list).filter(function (b) { return b.checked; }); }

                            function setArea(id, show) {
                                var el = document.getElementById(id);
                                if (el) el.style.setProperty('display', show ? 'flex' : 'none', 'important');
                            }

                            function applyCascade() {
                                var pid = parentSel.value;
                                toArray(subList.querySelectorAll('.option-item')).forEach(function (item) {
                                    item.style.display = (item.getAttribute('data-parent') === pid) ? '' : 'none';
                                });
                            }

                            function makeChip(label, meta, kind, onRemove) {
                                var wrap = document.createElement('span');
                                wrap.className = 'chip-badge ' + (kind === 'complete' ? 'chip-complete' : 'chip-specific');

                                var txt = document.createElement('span');
                                txt.textContent = label + (meta ? ' \u00b7 ' + meta : '');

                                var btn = document.createElement('button');
                                btn.type = 'button';
                                btn.className = 'chip-x';
                                btn.innerHTML = '&times;';
                                btn.title = 'Remove';
                                btn.addEventListener('click', function (e) {
                                    e.preventDefault();
                                    onRemove();
                                });

                                wrap.appendChild(txt);
                                wrap.appendChild(btn);
                                return wrap;
                            }

                            function renderChips() {
                                chipsBox.innerHTML = '';
                                var total = 0;

                                if (completeMode.checked) {
                                    ticked(completeList).forEach(function (box) {
                                        total++;
                                        chipsBox.appendChild(makeChip(
                                            box.getAttribute('data-name'),
                                            'complete (all ' + (box.getAttribute('data-subs') || '0') + ' sub-categories)',
                                            'complete',
                                            function () { box.checked = false; renderChips(); }
                                        ));
                                    });
                                }

                                if (specificMode.checked) {
                                    ticked(subList).forEach(function (box) {
                                        total++;
                                        chipsBox.appendChild(makeChip(
                                            (box.getAttribute('data-parent-name') || '') + ' \u2192 ' + box.getAttribute('data-name'),
                                            'specific',
                                            'specific',
                                            function () { box.checked = false; applyCascade(); renderChips(); }
                                        ));
                                    });
                                }

                                if (emptyHint) emptyHint.classList.toggle('d-none', total > 0);
                            }

                            function sync() {
                                var cOn = completeMode.checked;
                                var sOn = specificMode.checked;

                                setArea('complete-main-category-fields', cOn);
                                setArea('sub-category-only-fields', sOn);

                                boxes(completeList).forEach(function (b) { b.disabled = !cOn; });
                                boxes(subList).forEach(function (b) { b.disabled = !sOn; });
                                parentSel.disabled = !sOn;

                                if (sOn) applyCascade();
                                renderChips();
                            }

                            function hasAnySelection() {
                                return (completeMode.checked && ticked(completeList).length > 0)
                                    || (specificMode.checked && ticked(subList).length > 0);
                            }

                            document.addEventListener('change', function (e) {
                                var t = e.target;
                                if (!t) return;
                                if (t.id === 'complete_mode' || t.id === 'specific_mode') sync();
                                else if (t.id === 'sub_parent_id') { applyCascade(); renderChips(); }
                                else if (t.className === 'opt-input') renderChips();
                            }, true);

                            document.addEventListener('submit', function (e) {
                                if (!hasAnySelection()) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    alert('Tick at least one main category or sub-category before saving.');
                                    return false;
                                }
                            }, true);

                            if (document.readyState === 'loading') {
                                document.addEventListener('DOMContentLoaded', sync);
                            }
                            sync();
                        })();
                    </script>
                </section>

                <h3>{{translate('Step 6')}} : {{translate('Service Permission')}}</h3>
                <section id="step6-service-permission">
                    <div class="page-title-wrap mb-3">
                        <h2 class="page-title mb-2">{{translate('Service Permission')}}</h2>
                        <p class="page-title-text">{{translate('Decide what the provider can do with services inside his own zone. Toggles OFF = provider can only view the services of the categories you assigned.')}}</p>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <div class="d-flex flex-wrap gap-4 create-provider-item mb-4">
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{ translate('Basic info') }}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{ translate('Set Business Plan') }}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{ translate('Provider Subscribe') }}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{ translate('Independent Commission') }}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="material-symbols-outlined icon-1">check</span>
                                    {{ translate('Category Assignment') }}
                                </div>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <span class="icon-6">6</span>
                                    {{ translate('Service Permission') }}
                                </div>
                            </div>

                            <div class="d-flex flex-wrap gap-4">
                                <div class="col-md-6">
                                    <div class="card h-100">
                                        <div class="card-body">
                                            <div class="d-flex justify-content-between align-items-start gap-3 mb-3">
                                                <div>
                                                    <h4 class="c1 mb-2">{{translate('Add new service')}}</h4>
                                                    <p class="mb-0 opacity-75 fs-12">
                                                        {{translate('Provider can create his own services for the categories assigned to him, inside his zone. Every new service goes live only after admin approval.')}}
                                                    </p>
                                                </div>
                                                <label class="switcher flex-shrink-0">
                                                    <input type="checkbox"
                                                           class="switcher_input"
                                                           name="allow_service_create"
                                                           value="1"
                                                           {{$provider->allow_service_create == 1 ? 'checked' : ''}}>
                                                    <span class="switcher_control"></span>
                                                </label>
                                            </div>
                                            <div class="p-12 rounded bg-primary bg-opacity-10 fs-12">
                                                {{translate('ON = provider app me "My Services" se naya service add kar sakta hai. OFF = sirf dekh sakta hai.')}}
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <div class="card h-100">
                                        <div class="card-body">
                                            <div class="d-flex justify-content-between align-items-start gap-3 mb-3">
                                                <div>
                                                    <h4 class="c1 mb-2">{{translate('Edit admin service')}}</h4>
                                                    <p class="mb-0 opacity-75 fs-12">
                                                        {{translate('Provider can update the admin created services of his zone - short description, price and cover image. The change stays inside his zone only.')}}
                                                    </p>
                                                </div>
                                                <label class="switcher flex-shrink-0">
                                                    <input type="checkbox"
                                                           class="switcher_input"
                                                           name="allow_service_edit"
                                                           value="1"
                                                           {{$provider->allow_service_edit == 1 ? 'checked' : ''}}>
                                                    <span class="switcher_control"></span>
                                                </label>
                                            </div>
                                            <div class="p-12 rounded bg-primary bg-opacity-10 fs-12">
                                                {{translate('ON = admin ki service ka price / description / image edit kar sakta hai. OFF = read only.')}}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex flex-wrap gap-4 mt-3">
                                <div class="col-12">
                                    <div class="card h-100">
                                        <div class="card-body">
                                            <div class="d-flex justify-content-between align-items-start gap-3 mb-3">
                                                <div>
                                                    <h4 class="c1 mb-2">{{translate('Approval required for service changes')}}</h4>
                                                    <p class="mb-0 opacity-75 fs-12">
                                                        {{translate('When ON, every new service created by this provider and every update he makes to an admin created service first goes to the approval queue. Admin sees it in two tabs - New Services and Service Updates - and publishes it only after approving.')}}
                                                    </p>
                                                </div>
                                                <label class="switcher flex-shrink-0">
                                                    <input type="checkbox"
                                                           class="switcher_input"
                                                           name="service_approval_required"
                                                           value="1"
                                                           {{$provider->service_approval_required == 1 ? 'checked' : ''}}>
                                                    <span class="switcher_control"></span>
                                                </label>
                                            </div>
                                            <div class="p-12 rounded bg-primary bg-opacity-10 fs-12">
                                                <b>ON =</b> {{translate('provider ki new service aur admin service ki update approve hone tak live nahi hogi (2 tabs me dikhegi).')}}
                                                <br>
                                                <b>OFF =</b> {{translate('admin ki bina approve ke hi create / update turant publish ho jayega.')}}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="alert alert-info mt-3 mb-0 fs-12" role="alert">
                                <span class="material-symbols-outlined me-1 fz-14 align-text-bottom">info</span>
                                {{translate('Both toggles OFF means the My Services screen becomes view-only: provider can see how many main categories and sub-categories you assigned, and the services inside them, but cannot add or edit anything.')}}
                            </div>
                        </div>
                    </div>
                </section>
            </form>
        </div>
    </div>
@endsection

@push('script')

    <script src="{{asset('public/assets/provider-module')}}/js//tags-input.min.js"></script>
    <script src="{{asset('public/assets/provider-module')}}/js/spartan-multi-image-picker.js"></script>
    <script src="{{asset('public/assets/admin-module/plugins/swiper/swiper-bundle.min.js')}}"></script>

    <script src="{{asset('public/assets/provider-module')}}/plugins/jquery-steps/jquery.steps.min.js"></script>
    <script src="{{asset('public/assets/provider-module')}}/plugins/jquery-validation/jquery.validate.min.js"></script>


    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

    <script>
        "use strict";

        function updateSelectedPackage() {
            const selectedPackage = document.querySelector('input[name="plan"]:checked');
            if (selectedPackage) {
                document.getElementById('selected-package-input').value = selectedPackage.id;
            }
        }

        updateSelectedPackage();

        $(document).ready(function () {
            let formWizard = $("#create-provider-form");

            formWizard.validate({
                errorPlacement: function (error, element) {
                    element.parents('.form-floating, .form-error-wrap').after(error);
                },
            });

            let initialPackageId = $('input[name="plan"]:checked').attr('data-id');

            document.querySelectorAll('input[type="tel"]').forEach(function(input) {
                const itiInstance = window.intlTelInputGlobals.getInstance(input);
                const nextInput = input.nextElementSibling;
                if (nextInput && nextInput.tagName.toLowerCase() === 'input') {
                    const nameAttr = nextInput.getAttribute('name');
                    input.setAttribute('name', nameAttr);
                }
                if (itiInstance) itiInstance.destroy();
                input.removeAttribute('data-intl-initialized');
            });

            formWizard.steps({
                headerTag: "h3",
                bodyTag: "section",
                transitionEffect: "fade",
                stepsOrientation: "vertical",
                autoFocus: true,
                labels: {
                    finish: "Submit",
                    next: "Proceed",
                    previous: "Back"
                },
                onInit: function (event, currentIndex) {
                   //
                },
                onStepChanging: function (event, currentIndex, newIndex) {

                    if (newIndex < currentIndex) {
                        return true;
                    }

                    formWizard.validate().settings.ignore = ":disabled,:hidden";
                    let multiImg = $('.spartan_image_input');

                    if (multiImg.length < 2 && $('.spartan_item_wrapper_error_msg').length === 0) {
                        multiImg.closest('.spartan_item_wrapper > div').after('<div class="spartan_item_wrapper_error_msg error text-danger mt-2 fs-12">This field is required.</div>');
                    }

                    document.querySelectorAll('input[name="plan"]').forEach(function (input) {
                        input.addEventListener('change', updateSelectedPackage);
                    });


                    return formWizard.valid();
                },
                onFinished: function (event, currentIndex) {
                    const myModalAlternative = new bootstrap.Modal('#paymentModal', {});

                    let selectedPackageId = $('input[name="plan"]:checked').attr('data-id');

                    if ($('.subscription-type:checked').val() === 'subscription_based' && initialPackageId !== selectedPackageId) {
                        myModalAlternative.show();

                        $('.pay_complete_btn').on('click', function () {
                            formWizard.submit();
                        });
                    } else {
                        formWizard.submit();
                    }
                }
            });

            $('.subscription-type').on('change', function () {
                if ($(this).is(':checked')) {
                    if ($(this).val() == 'commission_based') {
                        $('#subscription-based-plan').collapse('hide');
                    } else {
                        $('#subscription-based-plan').collapse('show');
                    }
                }
            });

            $(window).on('load', function () {
                $('.subscription-type').each(function () {
                    if ($(this).is(':checked')) {
                        if ($(this).val() == 'commission_based') {
                            $('#subscription-based-plan').collapse('hide');
                        } else {
                            $('#subscription-based-plan').collapse('show');
                        }
                    }
                });
            });

            let swiper = new Swiper(".price-box-slider", {
                slidesPerView: "auto",
                spaceBetween: 24,
                initialSlide: 0,
                autoWidth: true,
                loop: false,
                navigation: {
                    nextEl: ".swiper-button-next",
                    prevEl: ".swiper-button-prev",
                },
            });
        });

        function toggleBusinessPlanSection() {
            const subscriptionRequired = document.getElementById('subscription_required');
            const businessPlanSection = document.getElementById('business-plan-section');
            if (subscriptionRequired && businessPlanSection) {
                if (subscriptionRequired.checked) {
                    businessPlanSection.style.display = 'none';
                } else {
                    businessPlanSection.style.display = 'block';
                }
            }
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            toggleBusinessPlanSection();
        });

        $(document).ready(function () {
            $("#company_email").on("change keyup paste", function () {
                $('#account_email').val($(this).val());
            });
            // $("#company_phone").on("change keyup paste", function () {
            //     const countryCode = $('#register-form-p-0').find('.iti__selected-dial-code').text();
            //     $('#account_phone').val(`${countryCode} ${$(this).val()}`);
            // });

            setInterval(() => {
                // const countryCode = $('#register-form-p-0').find('.iti__selected-dial-code').text();
                // $('#account_phone').val(`${countryCode} ${$("#company_phone").val()}`);
                $('#account_email').val($('#company_email').val());
            }, 2000);
        });

        $(document).ready(function () {
            let imageCount = 0;
            let maxSizeReadable = "{{ readableUploadMaxFileSize('image') }}"; // "2MB"
            let maxFileSize = 2 * 1024 * 1024; // default 2MB

            if (maxSizeReadable.toLowerCase().includes('mb')) {
                maxFileSize = parseFloat(maxSizeReadable) * 1024 * 1024;
            } else if (maxSizeReadable.toLowerCase().includes('kb')) {
                maxFileSize = parseFloat(maxSizeReadable) * 1024;
            }

            function setAcceptForAllInputs() {
                const allowedExtensions = ".{{ implode(',.', array_column(IMAGEEXTENSION, 'key')) }},"

                $('#multi_image_picker input[type=file]').each(function() {
                    $(this).attr('accept', allowedExtensions);
                });
            }

            setAcceptForAllInputs();

            $("#multi_image_picker").spartanMultiImagePicker({
                fieldName: 'identity_images[]',
                maxCount: 2,
                allowedExt: 'png|jpg|jpeg|webp|gif',
                rowHeight: 'auto',
                groupClassName: 'item',
                maxFileSize: maxFileSize,
                dropFileLabel: "{{translate('Drop_here')}}",
                placeholderImage: {
                    image: '{{asset('public/assets/admin-module')}}/img/media/banner-upload-file.png',
                    width: '100%',
                },

                onRenderedPreview: function (index) {
                    toastr.success('{{translate('Image_added')}}', {
                        CloseButton: true,
                        ProgressBar: true
                    });
                },
                onAddRow: function (index) {
                    setAcceptForAllInputs()
                    $('.spartan_item_wrapper_error_msg').remove();
                    imageCount++;
                },
                onRemoveRow: function (index) {
                    imageCount--;
                    if(imageCount == 1){
                        $('.spartan_item_wrapper > div').after('<div class="spartan_item_wrapper_error_msg error text-danger mt-2 fs-12">This field is required.</div>');
                    }
                },
                onExtensionErr: function (index, file) {
                    toastr.error('{{ translate("Please only input png|jpg|jpeg|gif|webp type file") }}', {
                        CloseButton: true,
                        ProgressBar: true
                    });
                },
                onSizeErr: function () {
                    toastr.error('File size must be less than ' + maxSizeReadable);
                }

            });

            function readURL(input) {
                if (input.files && input.files[0]) {
                    var reader = new FileReader();

                    reader.onload = function (e) {
                        $('#viewer').attr('src', e.target.result);
                    }

                    reader.readAsDataURL(input.files[0]);
                }
            }

            $("#customFileEg1").change(function () {
                readURL(this);
            });


            $(document).ready(function () {
                function initAutocomplete() {
                    var myLatLng = {

                        lat:{{$provider->coordinates['latitude'] ?? 23.811842872190343}},
                        lng:{{$provider->coordinates['longitude'] ?? 90.356331}}
                    };
                    const map = L.map("location_map_canvas").setView(myLatLng, 13);
                    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                        attribution: '&copy; OpenStreetMap contributors'
                    }).addTo(map);

                    var marker = L.marker(myLatLng).addTo(map);

                    map.on('click', function (e) {
                        var latlng = e.latlng;
                        marker.setLatLng(latlng);
                        map.panTo(latlng);

                        document.getElementById('latitude').value = latlng.lat;
                        document.getElementById('longitude').value = latlng.lng;

                        fetch('https://nominatim.openstreetmap.org/reverse?format=json&lat=' + latlng.lat + '&lon=' + latlng.lng)
                            .then(function(response) { return response.json(); })
                            .then(function(data) {
                                if (data && data.display_name) {
                                    document.getElementById('address').value = data.display_name;
                                }
                            });
                    });

                    const input = document.getElementById("pac-input");
                    let searchMarkers = [];
                    input.addEventListener('keyup', function(e) {
                        if (e.key === 'Enter') {
                            var query = input.value;
                            fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(query))
                                .then(function(response) { return response.json(); })
                                .then(function(data) {
                                    searchMarkers.forEach(function(m) { map.removeLayer(m); });
                                    searchMarkers = [];
                                    if (data && data.length > 0) {
                                        data.forEach(function(place) {
                                            var mrkr = L.marker([parseFloat(place.lat), parseFloat(place.lon)]).addTo(map);
                                            mrkr.bindPopup(place.display_name);
                                            mrkr.on('click', function () {
                                                document.getElementById('latitude').value = place.lat;
                                                document.getElementById('longitude').value = place.lon;
                                            });
                                            searchMarkers.push(mrkr);
                                        });
                                        map.fitBounds(searchMarkers.map(function(m) { return m.getLatLng(); }));
                                    }
                                });
                        }
                    });
                };
                initAutocomplete();
            });


            $('.__right-eye').on('click', function () {
                const input = $(this).siblings('input');
                const isVisible = input.attr('type') === 'text';

                if (isVisible) {
                    input.attr('type', 'password');
                    $(this).text('visibility_off');
                } else {
                    input.attr('type', 'text');
                    $(this).text('visibility');
                }
            });
        });

    </script>

@endpush
