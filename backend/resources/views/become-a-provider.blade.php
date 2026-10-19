@extends('layouts.landing.app')

@section('title', translate('become_a_provider'))

@section('content')
    <div class="container pt-3 pb-60">
        <section class="page-header bg__img" data-img="{{asset('public/assets/landing')}}/img/page-header.png">
            <h3 class="title">{{translate('become_a_provider')}}</h3>
        </section>
    </div>

    <section class="pb-60 pt-30">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-10 col-12">

                    <div class="alert alert-info mb-4">
                        <i class="las la-info-circle"></i>
                        {{translate('Fill in your details and choose your zone and category. Our team will review your request; after approval your provider ID will be created. Note: in one zone, only the active provider of a category serves customers.')}}
                    </div>

                    <form action="{{route('page.become-a-provider.submit')}}" method="POST" enctype="multipart/form-data">
                        @csrf

                        {{-- ======= Contact person ======= --}}
                        <div class="card mb-4">
                            <div class="card-body">
                                <h5 class="mb-3">{{translate('contact_person_details')}}</h5>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('name')}} *</label>
                                        <input type="text" class="form-control" name="contact_person_name" value="{{old('contact_person_name')}}" placeholder="{{translate('e.g.')}} {{translate('your_full_name')}}">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('phone')}} *</label>
                                        <input type="text" class="form-control" name="contact_person_phone" value="{{old('contact_person_phone')}}" placeholder="+91xxxxxxxxxx">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('email')}}</label>
                                        <input type="email" class="form-control" name="contact_person_email" value="{{old('contact_person_email')}}" placeholder="example@mail.com">
                                    </div>
                                </div>
                            </div>
                        </div>

                        {{-- ======= Business / company ======= --}}
                        <div class="card mb-4">
                            <div class="card-body">
                                <h5 class="mb-3">{{translate('business_details')}}</h5>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('business_name')}} *</label>
                                        <input type="text" class="form-control" name="company_name" value="{{old('company_name')}}">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('business_phone')}} *</label>
                                        <input type="text" class="form-control" name="company_phone" value="{{old('company_phone')}}">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('business_email')}} *</label>
                                        <input type="email" class="form-control" name="company_email" value="{{old('company_email')}}">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('business_address')}} *</label>
                                        <input type="text" class="form-control" name="company_address" value="{{old('company_address')}}">
                                    </div>
                                    <div class="col-md-12">
                                        <label class="form-label d-block">{{translate('business_logo')}} *</label>
                                        <input type="file" class="form-control" name="logo" accept="image/*">
                                    </div>
                                </div>
                            </div>
                        </div>

                        {{-- ======= Login credentials (provider ID ke liye) ======= --}}
                        <div class="card mb-4">
                            <div class="card-body">
                                <h5 class="mb-3">{{translate('login_credentials')}}</h5>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('login_email')}} *</label>
                                        <input type="email" class="form-control" name="account_email" value="{{old('account_email')}}">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('login_phone')}} *</label>
                                        <input type="text" class="form-control" name="account_phone" value="{{old('account_phone')}}" placeholder="+91xxxxxxxxxx">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('password')}} *</label>
                                        <input type="password" class="form-control" name="password">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('confirm_password')}} *</label>
                                        <input type="password" class="form-control" name="confirm_password">
                                    </div>
                                </div>
                            </div>
                        </div>

                        {{-- ======= Identity verification ======= --}}
                        <div class="card mb-4">
                            <div class="card-body">
                                <h5 class="mb-3">{{translate('identity_verification')}}</h5>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('identity_type')}} *</label>
                                        <select class="form-select" name="identity_type">
                                            <option value="passport">{{translate('passport')}}</option>
                                            <option value="driving_license">{{translate('driving_license')}}</option>
                                            <option value="nid">{{translate('nid')}}</option>
                                            <option value="trade_license">{{translate('trade_license')}}</option>
                                            <option value="company_id">{{translate('company_id')}}</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('identity_number')}} *</label>
                                        <input type="text" class="form-control" name="identity_number" value="{{old('identity_number')}}">
                                    </div>
                                    <div class="col-md-12">
                                        <label class="form-label d-block">{{translate('identity_images')}}</label>
                                        <input type="file" class="form-control" name="identity_images[]" multiple accept="image/*">
                                    </div>
                                </div>
                            </div>
                        </div>

                        {{-- ======= Zone + Category ======= --}}
                        <div class="card mb-4">
                            <div class="card-body">
                                <h5 class="mb-3">{{translate('service_area_and_category')}}</h5>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('zone')}} *</label>
                                        <select class="form-select" name="zone_id" id="zone-select">
                                            <option value="">{{translate('select_zone')}}</option>
                                            @foreach($zones as $zone)
                                                <option value="{{$zone->id}}" {{old('zone_id') == $zone->id ? 'selected' : ''}}>{{$zone->name}}</option>
                                            @endforeach
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('category')}} *</label>
                                        <select class="form-select" name="main_category_id" id="main-category-select">
                                            <option value="">{{translate('select_category')}}</option>
                                            @foreach($mainCategories as $category)
                                                <option value="{{$category->id}}" {{old('main_category_id') == $category->id ? 'selected' : ''}}>{{$category->name}}</option>
                                            @endforeach
                                        </select>
                                        <small class="text-muted fz-12">{{translate('Selecting only a category means service of all sub-services will be taken over. Choose specific services below to narrow down.')}}</small>
                                    </div>

                                    <div class="col-md-12">
                                        <label class="form-label d-block">{{translate('services_you_want_to_provide')}}</label>
                                        <div id="sub-cat-box" class="row g-2 px-2" style="display:none;">
                                            @foreach($subCategories as $subCategory)
                                                <div class="col-md-4 d-none sub-item" data-parent="{{$subCategory->parent_id}}">
                                                    <label class="d-flex align-items-center gap-2" style="cursor:pointer;">
                                                        <input type="checkbox" class="sub-cat-check"
                                                               name="sub_category_ids[]" value="{{$subCategory->id}}"
                                                               {{in_array($subCategory->id, (array) old('sub_category_ids', [])) ? 'checked' : ''}}>
                                                        <span>{{$subCategory->name}}</span>
                                                    </label>
                                                </div>
                                            @endforeach
                                            <div class="col-12 d-none" id="sub-cat-empty">
                                                <small class="text-muted">{{translate('No services found under this category.')}}</small>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('latitude') ?? 'Latitude'}}</label>
                                        <input type="number" step="any" class="form-control" name="latitude" value="{{old('latitude')}}" placeholder="28.6139">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{translate('longitude') ?? 'Longitude'}}</label>
                                        <input type="number" step="any" class="form-control" name="longitude" value="{{old('longitude')}}" placeholder="77.2090">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="text-center">
                            <button type="submit" class="btn btn--primary px-5">{{translate('submit_request')}}</button>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    </section>

    <script>
        (function () {
            var mainSelect = document.getElementById('main-category-select');
            var subBox = document.getElementById('sub-cat-box');
            if (!mainSelect || !subBox) return;

            function toggleSubBox() {
                var mainCatId = mainSelect.value;
                var any = false;
                subBox.querySelectorAll('.sub-item').forEach(function (item) {
                    var match = item.getAttribute('data-parent') === mainCatId && mainCatId !== '';
                    item.classList.toggle('d-none', !match);
                    if (match) any = true;
                });
                subBox.style.display = mainCatId ? 'block' : 'none';
                document.getElementById('sub-cat-empty').classList.toggle('d-none', any);
            }

            mainSelect.addEventListener('change', toggleSubBox);
            toggleSubBox();
        })();
    </script>
@endsection
