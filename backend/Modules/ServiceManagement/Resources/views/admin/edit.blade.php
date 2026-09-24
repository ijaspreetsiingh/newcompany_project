@extends('adminmodule::layouts.master')

@section('title',translate('service_update'))

@push('css_or_js')
    <link rel="stylesheet" href="{{asset('public/assets/admin-module')}}/plugins/select2/select2.min.css"/>
    <link rel="stylesheet" href="{{asset('public/assets/admin-module')}}/plugins/dataTables/jquery.dataTables.min.css"/>
    <link rel="stylesheet" href="{{asset('public/assets/admin-module')}}/plugins/dataTables/select.dataTables.min.css"/>
    <link rel="stylesheet" href="{{asset('public/assets/admin-module')}}/plugins/wysiwyg-editor/froala_editor.min.css"/>
    <link rel="stylesheet" href="{{asset('public/assets/admin-module')}}/css/tags-input.min.css"/>
    <link rel="stylesheet" href="{{asset('public/assets/admin-module')}}/plugins/cropper/cropper.min.css"/>

    {{--AI--}}
    <link rel="stylesheet" href="{{asset('public/assets/admin-module/css/ai-sidebar.css') }}"/>

@endpush

@section('content')
    <div class="main-content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <div class="page-title-wrap mb-3">
                        <h2 class="page-title">{{translate('update_service')}}</h2>
                    </div>

                    <div class="card-wrap">
                        <div class="card-body-inner">
                            <form action="{{route('admin.service.update',[$service->id])}}" method="post"
                                  enctype="multipart/form-data"
                                  id="service-add-form">
                                @csrf
                                @method('PUT')

                                <div id="form-wizard">
                                    <h3>{{translate('service_information')}}</h3>
                                    <section class="">
                                        <div class="row service-description-wrapper">
                                            <div class="col-xxl-9 col-lg-8 mb-5 mb-lg-0">
                                                <div class="card h-100">
                                                    <div class="card-body">
                                                        <div class="mb-20">
                                                            <h3 class="mb-1 text-dark">{{ translate('Basic Setup') }}</h3>
                                                            <p class="fs-12 text-color">{{ translate('Provide essential service details') }}</p>
                                                        </div>
                                                        <div class="bg-light p-xxl-20 p-12px rounded">
                                                            @php($language= Modules\BusinessSettingsModule\Entities\BusinessSettings::where('key_name','system_language')->first())
                                                            @php($default_lang = str_replace('_', '-', app()->getLocale()))
                                                            @if($language)
                                                                <ul class="nav nav--tabs border-color-primary mb-5 flex-nowrap text-nowrap overflow-auto">
                                                                    <li class="nav-item">
                                                                        <a class="nav-link lang_link active"
                                                                        href="#"
                                                                        id="default-link">{{translate('default')}}</a>
                                                                    </li>
                                                                    @foreach ($language?->live_values as $lang)
                                                                        <li class="nav-item">
                                                                            <a class="nav-link lang_link"
                                                                            href="#"
                                                                            id="{{ $lang['code'] }}-link">{{ get_language_name($lang['code']) }}</a>
                                                                        </li>
                                                                    @endforeach
                                                                </ul>
                                                            @endif
                                                            <!-- Language End -->
                                                            @if($language)
                                                                <div class="mb-30 lang-form" id="default-form">
                                                                    <button type="button" class="btn bg-white text-primary bg-transparent shadow-none border-0 opacity-1 generate_btn_wrapper p-0 auto_fill_title title-btn-wrapper"
                                                                            id="title-default-action-btn"
                                                                            data-lang="default"
                                                                            data-item='@json(["name" => $service?->getRawOriginal('name') ?? ''])'
                                                                            data-route="{{ route('admin.product.title-auto-fill') }}">
                                                                        <div class="btn-svg-wrapper">
                                                                            <img width="18" height="18" class="" src="{{ asset(path: 'public/assets/admin-module/img/ai/blink-right-small.svg') }}" alt="">
                                                                        </div>
                                                                        <span class="ai-text-animation d-none" role="status">{{ translate('Just_a_second') }}</span>
                                                                        <span class="btn-text">{{ translate('Generate') }}</span>
                                                                    </button>
                                                                    <div class="form-floating form-floating__icon outline-wrapper title-container-default">
                                                                        <input type="text" name="name[]" id="default_name" class="form-control default-name"
                                                                               placeholder="{{translate('service_name')}}"
                                                                               value="{{$service?->getRawOriginal('name')}}" required>
                                                                        <label>{{translate('service_name')}} ({{ translate('default') }})</label>
                                                                        <span class="material-icons">subtitles</span>
                                                                    </div>
                                                                </div>
                                                            <input type="hidden" name="lang[]" value="default">
                                                            @foreach ($language?->live_values as $lang)
                                                                    <?php
                                                                    if (count($service['translations'])) {
                                                                        $translate = [];
                                                                        foreach ($service['translations'] as $t) {
                                                                            if ($t->locale == $lang['code'] && $t->key == "name") {
                                                                                $translate[$lang['code']]['name'] = $t->value;
                                                                            }
                                                                        }
                                                                    }
                                                                    ?>

                                                                    <div class="mb-30 d-none lang-form" id="{{$lang['code']}}-form">
                                                                        <button type="button" class="btn bg-white text-primary bg-transparent shadow-none border-0 opacity-1 generate_btn_wrapper p-0 auto_fill_title title-btn-wrapper"
                                                                                id="title-{{ $lang['code'] }}-action-btn"
                                                                                data-route="{{ route('admin.product.title-auto-fill') }}"
                                                                                data-lang="{{ $lang['code'] }}"
                                                                                data-item='@json(["name" => $translate[$lang['code']]['name'] ?? ''])'
                                                                        >
                                                                            <div class="btn-svg-wrapper">
                                                                                <img width="18" height="18" class="" src="{{ asset(path: 'public/assets/admin-module/img/ai/blink-right-small.svg') }}" alt="">
                                                                            </div>
                                                                            <span class="ai-text-animation d-none" role="status">{{ translate('Just_a_second') }}</span>
                                                                            <span class="btn-text">{{ translate('Generate') }}</span>
                                                                        </button>
                                                                        <div class="form-floating form-floating__icon outline-wrapper title-container-{{$lang['code']}}">
                                                                            <input type="text" name="name[]" id="{{$lang['code']}}_name"
                                                                                   class="form-control"
                                                                                   placeholder="{{translate('service_name')}}"
                                                                                   value="{{$translate[$lang['code']]['name']??''}}">
                                                                            <label>{{translate('service_name')}}({{strtoupper($lang['code'])}})</label>
                                                                            <span class="material-icons">subtitles</span>
                                                                        </div>
                                                                    </div>
                                                                <input type="hidden" name="lang[]" value="{{$lang['code']}}">
                                                            @endforeach
                                                            @else
                                                                <div class="lang-form">
                                                                    <div class="mb-30">
                                                                        <div class="form-floating form-floating__icon">
                                                                            <input type="text" class="form-control" name="name[]"
                                                                                placeholder="{{translate('service_name')}} *"
                                                                                required value="{{$service->name}}">
                                                                            <label>{{translate('service_name')}} *</label>
                                                                            <span class="material-icons">subtitles</span>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <input type="hidden" name="lang[]" value="default">
                                                                <button type="button" class="btn bg-white text-primary bg-transparent shadow-none border-0 opacity-1 generate_btn_wrapper p-0 auto_fill_title title-btn-wrapper"
                                                                        id="title-en-action-btn"
                                                                        data-lang="en"
                                                                        data-route="{{ route('admin.product.title-auto-fill') }}">
                                                                    <div class="btn-svg-wrapper">
                                                                        <img width="18" height="18" class="" src="{{ asset(path: 'public/assets/admin-module/img/ai/blink-right-small.svg') }}" alt="">
                                                                    </div>
                                                                    <span class="ai-text-animation d-none" role="status">{{ translate('Just_a_second') }}</span>
                                                                    <span class="btn-text">{{ translate('Generate') }}</span>
                                                                </button>
                                                            @endif
                                                            <!-- Service Name End -->

                                                            @if($language)
                                                            <div class="lang-form2" id="default-form2">
                                                                <div class="mb-30">
                                                                    <div class="d-flex align-items-center justify-content-between gap-1 flex-wrap mb-3">
                                                                        <label class="m-0 lh-1">{{translate('short_description')}}({{translate('default')}}) *</label>
                                                                        <button type="button" class="btn bg-white mb-0 text-primary bg-transparent shadow-none border-0 opacity-1 generate_btn_wrapper p-0 auto_fill_short_description short-description-btn-wrapper"
                                                                                id="short-description-default-action-btn"
                                                                                data-lang="default"
                                                                                data-item='@json(["short_description" => $service?->getRawOriginal('short_description') ?? ''])'
                                                                                data-route="{{ route('admin.product.short-description-auto-fill') }}">
                                                                            <div class="btn-svg-wrapper">
                                                                                <img width="18" height="18" class=""
                                                                                     src="{{ asset(path: 'public/assets/admin-module/img/ai/blink-right-small.svg') }}" alt="">
                                                                            </div>
                                                                            <span class="ai-text-animation d-none" role="status">{{ translate('Just_a_second') }}</span>
                                                                            <span class="btn-text">{{ translate('Generate') }}</span>
                                                                        </button>
                                                                    </div>
                                                                    <div class="outline-wrapper">
                                                                        <textarea type="text" class="form-control default_short_description" required name="short_description[]">{{$service?->getRawOriginal('short_description')}}</textarea>
                                                                    </div>
                                                                </div>

                                                                <div class="mb-30">
                                                                    <div class="form-error-wrap">
                                                                        <div class="d-flex align-items-end justify-content-between flex-wrap gap-1 mb-3">
                                                                            <label for="editor" class="mb-0 lh-1 fs-14">{{translate('long_Description')}}({{translate('default')}})<span class="text-danger">*</span></label>
                                                                            <button type="button" class="btn bg-white mb-0 text-primary bg-transparent shadow-none border-0 opacity-1 generate_btn_wrapper p-0 auto_fill_description description-btn-wrapper"
                                                                                    id="description-default-action-btn"
                                                                                    data-lang="default"
                                                                                    data-item='@json(["description" => $service?->getRawOriginal("description") ?? ""])'
                                                                                    data-route="{{ route('admin.product.description-auto-fill') }}">
                                                                                <div class="btn-svg-wrapper">
                                                                                    <img width="18" height="18" class=""
                                                                                         src="{{ asset(path: 'public/assets/admin-module/img/ai/blink-right-small.svg') }}" alt="">
                                                                                </div>
                                                                                <span class="ai-text-animation d-none" role="status">{{ translate('Just_a_second') }}</span>
                                                                                <span class="btn-text">{{ translate('Generate') }} </span>
                                                                            </button>
                                                                        </div>
                                                                        <section id="editor" class="dark-support dark-support-02 outline-wrapper header-light body-customize-editor rounded-10">
                                                                            <textarea class="ckeditor default_description" name="description[]" id="default_description" required>{!! $service?->getRawOriginal('description') !!}</textarea>
                                                                        </section>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            @foreach ($language?->live_values as $lang)
                                                                    <?php
                                                                    if (count($service['translations'])) {
                                                                        $translate = [];
                                                                        foreach ($service['translations'] as $t) {
                                                                            if ($t->locale == $lang['code'] && $t->key == "short_description") {
                                                                                $translate[$lang['code']]['short_description'] = $t->value;
                                                                            }

                                                                            if ($t->locale == $lang['code'] && $t->key == "description") {
                                                                                $translate[$lang['code']]['description'] = $t->value;
                                                                            }
                                                                        }
                                                                    }
                                                                    ?>
                                                                <div class="d-none lang-form2" id="{{$lang['code']}}-form2">
                                                                    <div class="col-lg-12 mt-5">
                                                                        <div class="mb-30">
                                                                            <div class="d-flex align-items-center justify-content-between gap-1 flex-wrap mb-3">
                                                                                <label class="m-0">{{translate('short_description')}}({{strtoupper($lang['code'])}}) *</label>
                                                                                <button type="button" class="btn bg-white text-primary bg-transparent shadow-none border-0 mb-0 opacity-1 generate_btn_wrapper p-0 auto_fill_short_description short-description-btn-wrapper"
                                                                                        id="short-description-{{ $lang['code'] }}-action-btn"
                                                                                        data-lang="{{ $lang['code'] }}"
                                                                                        data-item='@json(["description" => $translate[$lang['code']]['description'] ?? $service?->getRawOriginal('description') ?? ""])'
                                                                                        data-route="{{ route('admin.product.short-description-auto-fill') }}">
                                                                                    <div class="btn-svg-wrapper">
                                                                                        <img width="18" height="18" class=""
                                                                                             src="{{ asset(path: 'public/assets/admin-module/img/ai/blink-right-small.svg') }}" alt="">
                                                                                    </div>
                                                                                    <span class="ai-text-animation d-none" role="status">{{ translate('Just_a_second') }}</span>
                                                                                    <span class="btn-text">{{ translate('Generate') }}</span>
                                                                                </button>
                                                                            </div>

                                                                            <div class="form-floating outline-wrapper">
                                                                                <textarea type="text" class="form-control {{ $lang['code'] }}_short_description" name="short_description[]">{{$translate[$lang['code']]['short_description']??''}}</textarea>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    <div class="col-12 mt-4">
                                                                        <div class="form-error-wrap">
                                                                            <div class="d-flex align-items-end justify-content-between flex-wrap gap-1 mb-3">
                                                                                <label for="editor" class="mb-0">{{translate('long_Description')}}({{strtoupper($lang['code'])}})<span class="text-danger">*</span></label>
                                                                                <button type="button" class="btn bg-white text-primary bg-transparent shadow-none border-0 mb-0 opacity-1 generate_btn_wrapper p-0 auto_fill_description description-btn-wrapper"
                                                                                        id="description-{{ $lang['code'] }}-action-btn"  data-lang="{{ $lang['code'] }}"
                                                                                        data-item='@json(["description" => $translate[$lang['code']]['description'] ?? ''])'
                                                                                        data-route="{{ route('admin.product.description-auto-fill') }}">
                                                                                    <div class="btn-svg-wrapper">
                                                                                        <img width="18" height="18" class="" src="{{ asset(path: 'public/assets/admin-module/img/ai/blink-right-small.svg') }}" alt="">
                                                                                    </div>
                                                                                    <span class="ai-text-animation d-none" role="status">{{ translate('Just_a_second') }}</span>
                                                                                    <span class="btn-text">{{ translate('Generate') }}</span>
                                                                                </button>
                                                                            </div>

                                                                            <section id="editor" class="dark-support dark-support-02 outline-wrapper header-light body-customize-editor rounded-10">
                                                                                <textarea class="ckeditor {{ $lang['code'] }}_description" name="description[]" id="{{ $lang['code'] }}_description">{!! $translate[$lang['code']]['description']??'' !!}</textarea>
                                                                            </section>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            @endforeach
                                                            @else
                                                            <div class="normal-form">
                                                                <div class="col-lg-12 mt-5">
                                                                    <div class="mb-30">
                                                                        <div class="form-floating">
                                                                            <textarea type="text" class="form-control" required
                                                                                    name="short_description[]">{{old('short_description')}}</textarea>
                                                                            <label>{{translate('short_description')}} *</label>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <button type="button" class="btn bg-white text-primary bg-transparent shadow-none border-0 opacity-1 generate_btn_wrapper p-0 auto_fill_short_description short-description-btn-wrapper"
                                                                        id="short-description-en-action-btn"  data-lang="en"
                                                                        data-route="{{ route('admin.product.short-description-auto-fill') }}">
                                                                    <div class="btn-svg-wrapper">
                                                                        <img width="18" height="18" class=""
                                                                             src="{{ asset(path: 'public/assets/admin-module/img/ai/blink-right-small.svg') }}" alt="">
                                                                    </div>
                                                                    <span class="ai-text-animation d-none" role="status">{{ translate('Just_a_second') }}</span>
                                                                    <span class="btn-text">{{ translate('Generate') }}</span>
                                                                </button>

                                                                <div class="col-12 mt-4">
                                                                    <label for="editor"
                                                                        class="mb-2">{{translate('long_Description')}}
                                                                        <span class="text-danger">*</span></label>
                                                                    <section id="editor" class="dark-support body-customize-editor">
                                                                        <textarea class="ckeditor" required
                                                                                name="description[]">{{old('description')}}</textarea>
                                                                    </section>
                                                                </div>
                                                                <button type="button" class="btn bg-white text-primary bg-transparent shadow-none border-0 opacity-1 generate_btn_wrapper p-0 auto_fill_description description-btn-wrapper"
                                                                        id="description-en-action-btn"  data-lang="en"
                                                                        data-route="{{ route('admin.product.description-auto-fill') }}">
                                                                    <div class="btn-svg-wrapper">
                                                                        <img width="18" height="18" class=""
                                                                             src="{{ asset(path: 'public/assets/admin-module/img/ai/blink-right-small.svg') }}" alt="">
                                                                    </div>
                                                                    <span class="ai-text-animation d-none" role="status">{{ translate('Just_a_second') }}</span>
                                                                    <span class="btn-text">{{ translate('Generate') }}</span>
                                                                </button>
                                                            </div>
                                                            @endif
                                                            <!-- ShotDescription End -->
                                                        </div>
                                                    </div>
                                                </div>


                                            </div>
                                            <div class="col-xxl-3 col-lg-4 mb-5 mb-sm-0">
                                                <div class="card">
                                                    <div class="card-body">
                                                        <div class="bg-light rounded w-100 mb-30">
                                                            <div class="d-flex flex-column align-items-center gap-0 text-center px-2 py-5">
                                                                <div class="mb-30">
                                                                    <h5 class="mb-1 fs-14 font-semibold text-dark">{{translate('thumbnail_image')}}</h5>
                                                                    <span class="fs-12 text-color">{{ translate('Upload your thumbnail Image') }}</span>
                                                                </div>
                                                                <div class="mb-30">
                                                                    <div class="upload-file ratio-1 w-100px">
                                                                        <input type="file" class="upload-file__input"
                                                                               name="thumbnail"
                                                                               accept=".{{ implode(',.', array_column(IMAGEEXTENSION, 'key')) }}, |image/*"
                                                                               data-maxFileSize="{{ readableUploadMaxFileSize('image') }}">
                                                                        <div class="upload-file__img border-dashed-1-gray rounded">
                                                                            <img src="{{$service->thumbnail_full_path}}"
                                                                                alt="{{translate('image')}}" class="w-100">
                                                                        </div>
                                                                        <span class="upload-file__edit">
                                                                            <span class="material-icons">edit</span>
                                                                        </span>
                                                                    </div>
                                                                </div>
                                                                <p class="text-center fs-10 text-color mb-0">
                                                                    {{ translate('Image format')}} - {{ implode(', ', array_column(IMAGEEXTENSION, 'key')) }}
                                                                    {{ translate("Image Size") }} - {{ translate('maximum size') }} {{ readableUploadMaxFileSize('image') }}
                                                                    {{ translate('Image Ratio') }} - 1:1
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="bg-light rounded w-100">
                                                            <div class="d-flex flex-column align-items-center gap-0 text-center px-2 py-5">
                                                                 <div class="mb-30">
                                                                    <p class="mb-1 fs-14 font-semibold text-dark">{{translate('cover_image')}}</p>
                                                                    <span class="fs-12 text-color">{{ translate('Upload your cover Image') }}</span>
                                                                </div>
                                                                <div class="mb-30">
                                                                    <div class="upload-file h-100px">
                                                                        <input type="file" class="upload-file__input"
                                                                               name="cover_image"
                                                                               accept=".{{ implode(',.', array_column(IMAGEEXTENSION, 'key')) }}, |image/*"
                                                                               data-maxFileSize="{{ readableUploadMaxFileSize('image') }}">
                                                                        <div class="upload-file__img h-100px  border-dashed-1-gray rounded upload-file__img_banner">
                                                                            <img alt="{{ translate('cover-image') }}"
                                                                                src="{{$service->cover_image_full_path}}" class="w-100 h-100">
                                                                        </div>
                                                                        <span class="upload-file__edit">
                                                                            <span class="material-icons">edit</span>
                                                                        </span>
                                                                    </div>
                                                                </div>
                                                                <p class="text-center fs-10 text-color mb-0">
                                                                    {{ translate('Image format')}} - {{ implode(', ', array_column(IMAGEEXTENSION, 'key')) }}
                                                                    {{ translate("Image Size") }} - {{ translate('maximum size') }} {{ readableUploadMaxFileSize('image') }}
                                                                    {{ translate('Image Ratio') }} - 3:1
                                                                </p>
                                                            </div>
                                                        </div>


                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Gallery Images Section - Full Width -->
                                        <div class="general_wrapper mt-4 mb-4">
                                            <div class="outline-wrapper">
                                                <div class="card bg-animate">
                                                    <div class="card-body">
                                                        <div class="mb-20">
                                                            <h3 class="mb-1 text-dark">{{translate('gallery_image')}}</h3>
                                                            <p class="fs-12 text-color">{{ translate('Upload gallery images (multiple)') }}</p>
                                                        </div>

                                                        <div class="row g-2 mb-3" id="galleryPreviewWrap">
                                                            @if($service->gallery && is_array($service->gallery) && count($service->gallery))
                                                                @foreach($service->gallery as $galleryImage)
                                                                    <div class="col-md-2 col-4 gallery-item position-relative">
                                                                        <img src="{{ asset('storage/' . $galleryImage) }}" class="w-100 rounded border" style="height:120px;object-fit:cover" alt="gallery">
                                                                        <input type="hidden" name="existing_gallery[]" value="{{ $galleryImage }}">
                                                                        <button type="button" class="btn btn-sm btn-danger position-absolute" style="top:4px;right:4px;padding:0 6px;line-height:1.4"
                                                                                onclick="this.closest('.gallery-item').remove();">&times;</button>
                                                                    </div>
                                                                @endforeach
                                                            @endif
                                                        </div>

                                                        <div id="galleryNewPreview" class="row g-2 mb-3"></div>

                                                        <div class="bg-light rounded p-4 text-center" onclick="document.getElementById('galleryInput').click();" style="cursor:pointer;border:2px dashed #dee2e6;border-radius:8px;">
                                                            <span class="material-icons mb-1" style="font-size:36px;color:#999">add_photo_alternate</span>
                                                            <p class="mb-0 fs-12 text-color">{{ translate('Click to select multiple images') }}</p>
                                                            <p class="mb-0 fs-10 text-color">{{ implode(', ', array_column(IMAGEEXTENSION, 'key')) }} | Max {{ readableUploadMaxFileSize('image') }}</p>
                                                        </div>
                                                        <input type="file" class="d-none"
                                                               name="gallery[]"
                                                               id="galleryInput"
                                                               multiple
                                                               accept=".{{ implode(',.', array_column(IMAGEEXTENSION, 'key')) }}, |image/*"
                                                               data-maxFileSize="{{ readableUploadMaxFileSize('image') }}">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="general_wrapper mt-4">
                                            <div class="outline-wrapper">
                                                <div class="card bg-animate">
                                                    <div class="card-body">
                                                        <button type="button"
                                                                class="btn bg-white text-primary mt-0 mb-md-0 mb-2 bg-transparent shadow-none border-0 opacity-1 generate_btn_wrapper p-0 general_setup_auto_fill"
                                                                id="general_setup_auto_fill"
                                                                data-route="{{ route('admin.product.general-setup-auto-fill') }}"  data-lang="default">
                                                            <div class="btn-svg-wrapper">
                                                                <img width="18" height="18" class=""
                                                                     src="{{ asset(path: 'public/assets/admin-module/img/ai//blink-right-small.svg') }}" alt="">
                                                            </div>
                                                            <span class="ai-text-animation d-none" role="status">{{ translate('Just_a_second') }}</span>
                                                            <span class="btn-text">{{ translate('Generate') }}</span>
                                                        </button>
                                                        <div class="mb-20 max-w-500">
                                                            <h3 class="mb-1 text-dark">{{ translate('General Setup') }}</h3>
                                                            <p class="fs-12 text-color m-0">{{ translate('Here you can set up the foundational details required for service creation.') }}</p>
                                                        </div>
                                                        <div class="bg-light rounded p-xxl-20 p-12px">
                                                            <div class="row g-lg-4 g-3">
                                                                <div class="col-lg-4 col-md-6">
                                                                    <select class="js-select theme-input-style w-100" name="category_id"
                                                                            id="category-id">
                                                                        <option value="0" selected
                                                                                disabled>{{translate('choose_category')}}</option>
                                                                        @foreach($categories as $category)
                                                                            <option
                                                                                value="{{$category->id}}" {{$category->id==$service->category_id?'selected':''}}>
                                                                                {{$category->name}}
                                                                            </option>
                                                                        @endforeach
                                                                    </select>
                                                                </div>
                                                                <div class="col-lg-4 col-md-6">
                                                                    <div class="m-0" id="sub-category-selector">
                                                                        <select class="js-select theme-input-style w-100"
                                                                                name="sub_category_id"></select>
                                                                    </div>
                                                                </div>
                                                                <div class="col-lg-4 col-md-6">
                                                                    <div class="form-floating form-floating__icon">
                                                                        <input type="text" class="form-control" name="tax" min="0"
                                                                               max="100" step="0.01"
                                                                               placeholder="{{translate('add_tax_percentage')}} *"
                                                                               required="" value="{{$service->tax}}">
                                                                        <label>{{translate('add_tax_percentage')}} *</label>
                                                                        <span class="material-icons">percent</span>
                                                                    </div>
                                                                </div>
                                                                <div class="col-lg-4 col-md-5">
                                                                    <div class="form-floating form-floating__icon">
                                                                        <input type="number" class="form-control"
                                                                               name="min_bidding_price" min="0"
                                                                               max="100" step="any"
                                                                               placeholder="{{translate('min_bidding_price')}} *"
                                                                               required="" value="{{$service->min_bidding_price}}">
                                                                        <label>{{translate('min_bidding_price')}} *</label>
                                                                        <span class="material-icons">price_change</span>
                                                                    </div>
                                                                </div>
                                                                <div class="ol-lg-8 col-md-7">
                                                                    <div class="form-floating taginput-dark-support">
                                                                        <input type="text" class="form-control" name="tags"
                                                                               placeholder="{{translate('Enter tags')}}"
                                                                               value="{{implode(",",$tagNames)}}"
                                                                               data-role="tagsinput">
                                                                    </div>
                                                                </div>
                                                                <div class="col-12">
                                                                    <div class="bg-white border rounded p-3">
                                                                        <div class="form-check form-switch mb-2">
                                                                            <input type="hidden" name="is_single_provider" value="0">
                                                                            <input class="form-check-input" type="checkbox"
                                                                                   name="is_single_provider" value="1"
                                                                                   id="is-single-provider"
                                                                                   onchange="window.__toggleSingleProviderOptions && window.__toggleSingleProviderOptions()"
                                                                                   onclick="window.__toggleSingleProviderOptions && window.__toggleSingleProviderOptions()"
                                                                                   {{ old('is_single_provider', $service->is_single_provider) == 1 ? 'checked' : '' }}>
                                                                            <label class="form-check-label fw-semibold" for="is-single-provider">
                                                                                {{translate('single_provider_only')}}
                                                                            </label>
                                                                        </div>
                                                                        <p class="fs-12 text-color mt-0 mb-2">
                                                                            {{translate('single_provider_only_hint')}}
                                                                        </p>

                                                                        @php($editMode = old('single_provider_mode', $service->single_provider_mode))
                                                                        <div id="single-provider-options" class="ps-2 border-start" style="display:none;">
                                                                            <div class="form-check mb-2">
                                                                                <input class="form-check-input" type="radio"
                                                                                       name="single_provider_mode" value="any_first"
                                                                                       id="mode-any-first"
                                                                                       onchange="window.__toggleSingleProviderOptions && window.__toggleSingleProviderOptions()"
                                                                                       {{ ($editMode == 'any_first' || !$editMode) ? 'checked' : '' }}>
                                                                                <label class="form-check-label" for="mode-any-first">
                                                                                    {{translate('any_first_provider')}}
                                                                                </label>
                                                                                <p class="fs-12 text-color m-0">
                                                                                    {{translate('any_first_provider_hint')}}
                                                                                </p>
                                                                            </div>
                                                                            <div class="form-check mb-2">
                                                                                <input class="form-check-input" type="radio"
                                                                                       name="single_provider_mode" value="specific"
                                                                                       id="mode-specific"
                                                                                       onchange="window.__toggleSingleProviderOptions && window.__toggleSingleProviderOptions()"
                                                                                       {{ $editMode == 'specific' ? 'checked' : '' }}>
                                                                                <label class="form-check-label" for="mode-specific">
                                                                                    {{translate('select_any_existing_provider')}}
                                                                                </label>
                                                                                <p class="fs-12 text-color m-0">
                                                                                    {{translate('select_any_existing_provider_hint')}}
                                                                                </p>
                                                                            </div>
                                                                            <div id="specific-provider-wrapper" class="mt-2" style="display:none;">
                                                                                <div class="form-floating form-floating__icon">
                                                                                    <select class="form-control" name="single_provider_id" id="single-provider-id">
                                                                                        <option value="">{{translate('choose_provider')}}</option>
                                                                                        @foreach(($providers ?? collect()) as $providerOption)
                                                                                            @php($selectedProviderId = old('single_provider_id', $service->single_provider_id))
                                                                                            <option value="{{ $providerOption->id }}"
                                                                                                {{ $selectedProviderId == $providerOption->id ? 'selected' : '' }}>
                                                                                                {{ $providerOption->company_name }}
                                                                                                @if($providerOption->owner)
                                                                                                    ({{ $providerOption->owner->first_name }} {{ $providerOption->owner->last_name }})
                                                                                                @endif
                                                                                            </option>
                                                                                        @endforeach
                                                                                    </select>
                                                                                    <label>{{translate('choose_provider')}} *</label>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    <script>
                                                                        (function () {
                                                                            function toggleSingleProviderOptions() {
                                                                                var isOn = document.getElementById('is-single-provider');
                                                                                var optionsEl = document.getElementById('single-provider-options');
                                                                                var specificEl = document.getElementById('specific-provider-wrapper');
                                                                                var on = !!(isOn && isOn.checked);
                                                                                if (optionsEl) optionsEl.style.display = on ? 'block' : 'none';
                                                                                if (!on) {
                                                                                    if (specificEl) specificEl.style.display = 'none';
                                                                                    return;
                                                                                }
                                                                                var modeEl = document.querySelector('input[name="single_provider_mode"]:checked');
                                                                                var mode = modeEl ? modeEl.value : 'any_first';
                                                                                if (specificEl) specificEl.style.display = (mode === 'specific') ? 'block' : 'none';
                                                                            }
                                                                            window.__toggleSingleProviderOptions = toggleSingleProviderOptions;
                                                                            document.addEventListener('change', function (e) {
                                                                                if (!e.target) return;
                                                                                if (e.target.id === 'is-single-provider' || (e.target.name === 'single_provider_mode')) {
                                                                                    toggleSingleProviderOptions();
                                                                                }
                                                                            }, true);
                                                                            document.addEventListener('click', function (e) {
                                                                                if (!e.target) return;
                                                                                if (e.target.id === 'is-single-provider' || (e.target.name === 'single_provider_mode')) {
                                                                                    toggleSingleProviderOptions();
                                                                                }
                                                                            }, true);
                                                                            if (document.readyState === 'loading') {
                                                                                document.addEventListener('DOMContentLoaded', toggleSingleProviderOptions);
                                                                            } else {
                                                                                toggleSingleProviderOptions();
                                                                            }
                                                                        })();
                                                                    </script>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                    </section>

                                    <h3>{{translate('price_variation')}}</h3>
                                    <section>
                                        <div class="general_wrapper mb-20">
                                            <div class="outline-wrapper">
                                                <div class="card bg-animate">
                                                    <div class="card-body">
                                                        <button type="button" class="btn bg-white text-primary bg-transparent shadow-none border-0 opacity-1 generate_btn_wrapper p-0 variation_setup_auto_fill"
                                                                id="description-en-action-btn"  data-lang="en"
                                                                data-route="{{ route('admin.product.variation-setup-auto-fill') }}">
                                                            <div class="btn-svg-wrapper">
                                                                <img width="18" height="18" class=""
                                                                     src="{{ asset(path: 'public/assets/admin-module/img/ai/blink-right-small.svg') }}" alt="">
                                                            </div>
                                                            <span class="ai-text-animation d-none" role="status">{{ translate('Just_a_second') }}</span>
                                                            <span class="btn-text">{{ translate('Generate') }}</span>
                                                        </button>
                                                        <div class="p-xxl-20 p-12px bg-light rounded">
                                                            <div class="d-flex flex-wrap gap-20 mb-01">
                                                                <div class="form-floating flex-grow-1">
                                                                    <input type="text" class="form-control" name="variant_name"
                                                                           id="variant-name"
                                                                           placeholder="{{translate('add_variant')}} *" required="">
                                                                    <label>{{translate('add_variant')}} *</label>
                                                                </div>
                                                                <div class="form-floating flex-grow-1">
                                                                    <input type="number" class="form-control" name="variant_price"
                                                                           id="variant-price"
                                                                           placeholder="{{translate('price')}} *" required="" value="0">
                                                                    <label>{{translate('price')}} *</label>
                                                                </div>
                                                                <button type="button" class="btn rounded btn--primary" id="service-ajax-variation">
                                                                    <span class="material-icons">add</span>
                                                                    {{translate('add')}}
                                                                </button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="table-responsive p-01">
                                            <table class="table align-middle table-variation">
                                                <thead id="category-wise-zone" class="text-nowrap">
                                                <tr>
                                                    <th scope="col">{{translate('variations')}}</th>
                                                    <th scope="col">{{translate('default_price')}}</th>
                                                    @foreach($zones as $zone)
                                                        <th scope="col">{{$zone->name}}</th>
                                                    @endforeach
                                                    <th scope="col">{{translate('action')}}</th>
                                                </tr>
                                                </thead>
                                                <tbody id="variation-update-table">
                                                @include('servicemanagement::admin.partials._update-variant-data',['variants'=>$service->variations,'zones'=>$zones])
                                                </tbody>
                                            </table>

                                            <div id="new-variations-table"
                                                 class="{{session()->has('variations') && count(session('variations'))>0?'':'hide-div'}}">
                                                <label class="badge badge-primary mb-10">{{translate('new_variations')}}</label>
                                                <table class="table align-middle table-variation">
                                                    <tbody id="variation-table">
                                                    @include('servicemanagement::admin.partials._variant-data',['zones'=>$zones])
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </section>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        @include("servicemanagement::admin.partials.ai-sidebar")

        {{--AI assistant--}}
        <div class="floating-ai-button">
            <button type="button" class="btn btn-lg rounded-circle shadow-lg position-relative" data-bs-toggle="modal" data-bs-target="#aiAssistantModal"
                    data-action="main" title="AI Assistant">
                <span class="ai-btn-animation">
                    <span class="gradientCirc"></span>
                </span>
                <span class="position-relative z-1 text-white-absolute d-flex flex-column gap-1 align-items-center">
                    <img width="16" height="17" src="{{ asset(path: 'public/assets/admin-module/img/ai/hexa-ai.svg') }}" alt="">
                    <span class="fs-12 fw-semibold">{{ translate('Use_AI') }}</span>
                </span>
            </button>
            <div class="ai-tooltip">
                <span>{{translate("AI_Assistant")}}</span>
            </div>
        </div>
    </div>

    {{-- Service image crop modal (thumbnail 1:1 / cover 3:1) --}}
    <div class="modal fade" id="serviceImageCropModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">{{ translate('Crop Your Image') }}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="mb-2 text-muted" id="serviceCropRatioHint">Required ratio: 1:1</p>
                    <div style="max-height:60vh; overflow:hidden; background:#f5f5f5; border-radius:8px;">
                        <img id="serviceCropImage" src="" alt="crop" style="max-width:100%; display:block;">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" id="serviceCropCancelBtn" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="serviceCropApplyBtn">Crop &amp; Use</button>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('script')
    <script src="{{asset('public/assets/admin-module')}}/js//tags-input.min.js"></script>
    <script src="{{asset('public/assets/admin-module')}}/plugins/select2/select2.min.js"></script>
    <script src="{{asset('public/assets/admin-module')}}/plugins/jquery-steps/jquery.steps.min.js"></script>
    <script src="{{asset('public/assets/admin-module/plugins/tinymce/tinymce.min.js')}}"></script>
    <script src="{{asset('public/assets/ckeditor/jquery.js')}}"></script>
    <script src="{{asset('public/assets/admin-module')}}/plugins/cropper/cropper.min.js"></script>

    {{--AI--}}
    <script src="{{ asset('public/assets/admin-module/js/AI/products/ai-sidebar.js') }}"></script>
    <script src="{{ asset('public/assets/admin-module/js/AI/products/general-setup.js') }}"></script>
    <script src="{{ asset('public/assets/admin-module/js/AI/products/product-short-description-autofill.js') }}"></script>
    <script src="{{ asset('public/assets/admin-module/js/AI/products/product-description-autofill.js') }}"></script>
    <script src="{{ asset('public/assets/admin-module/js/AI/products/product-title-autofill.js') }}"></script>
    <script src="{{ asset('public/assets/admin-module/js/AI/products/product-variation-setup.js') }}"></script>
    <script src="{{ asset('public/assets/admin-module/js/AI/image-compressor/image-compressor.js') }}"></script>
    <script src="{{ asset('public/assets/admin-module/js/AI/image-compressor/compressor.min.js') }}"></script>

    <script>
        "use strict";

        $(document).ready(function () {
            $('.js-select').select2();

            function toggleSingleProviderOptions() {
                const isOn = $('#is-single-provider').is(':checked');
                const optionsEl = document.getElementById('single-provider-options');
                const specificEl = document.getElementById('specific-provider-wrapper');
                if (optionsEl) optionsEl.style.display = isOn ? 'block' : 'none';
                if (!isOn) {
                    if (specificEl) specificEl.style.display = 'none';
                    return;
                }
                const mode = ($('input[name="single_provider_mode"]:checked').val()) || 'any_first';
                if (specificEl) specificEl.style.display = (mode === 'specific') ? 'block' : 'none';
            }
            window.__toggleSingleProviderOptions = toggleSingleProviderOptions;

            $(document).on('change click', '#is-single-provider, input[name="single_provider_mode"]', toggleSingleProviderOptions);
            toggleSingleProviderOptions();
        });

        $("#form-wizard").steps({
            headerTag: "h3",
            bodyTag: "section",
            transitionEffect: "slideLeft",
            autoFocus: true,
            onStepChanged: function (event, currentIndex, priorIndex) {
                let nextBtn = $(".actions a[href='#next']");
                if (nextBtn.hasClass("proceed-to-next")) {
                    setTimeout(function () {
                        $(".variation_setup_auto_fill").trigger("click");
                    }, 1000);
                }
            },
            onFinished: function (event, currentIndex) {
                event.preventDefault();

                let isValid = true;
                $(".desc-err").remove(); // Remove previous error messages

                let variationSections = $("#variation-update-table, #variation-table");

                // Loop through all number inputs
                variationSections.find('input[type="number"]').each(function () {
                    let value = parseFloat($(this).val());
                    let minValue = parseFloat($(this).attr('min'));

                    if (isNaN(value) || value === "") {
                        toastr.error('Please enter a valid number');
                        isValid = false;
                    } else if (value <= 0) {
                        toastr.error('Value must be greater than zero');
                        isValid = false;
                    } else if (!isNaN(minValue) && value < minValue) {
                        toastr.error(`Minimum allowed value is ${minValue}`);
                        isValid = false;
                    }
                });

                if (!isValid) {
                    return false; // Stop form submission if validation fails
                }

                $("#service-add-form")[0].submit();

            }
        });

        ajax_get('{{url('/')}}/admin/category/ajax-childes-only/{{$service->category_id}}?sub_category_id={{$service->sub_category_id}}', 'sub-category-selector')

        $("#service-ajax-variation").on('click', function () {
            let route = "{{route('admin.service.ajax-add-variant')}}";
            let id = "variation-table";
            ajax_variation(route, id);
        })

        function ajax_variation(route, id) {

            let name = $('#variant-name').val();
            let price = $('#variant-price').val();

            if (name.length > 0 && price > 0) {
                $.get({
                    url: route,
                    dataType: 'json',
                    data: {
                        name: $('#variant-name').val(),
                        price: $('#variant-price').val(),
                    },
                    success: function (response) {
                        if (response.flag == 0) {
                            toastr.info('Already added');
                        } else {
                            $('#new-variations-table').show();
                            $('#' + id).html(response.template);
                            $('#variant-name').val("");
                            $('#variant-price').val(0);
                        }
                    },
                });
            } else {
                if(price <= 0){
                    toastr.warning('{{translate('price can not be 0 or negative')}}');
                }else{
                    toastr.warning('{{translate('fields_are_required')}}');
                }
            }
        }

        document.addEventListener('click', function(event) {
            if (event.target.closest('.service-ajax-remove-variant')) {
                const btn = event.target.closest('.service-ajax-remove-variant');
                if (!btn) return;
                var route = event.target.closest('.service-ajax-remove-variant').getAttribute('data-route');
                var id = event.target.closest('.service-ajax-remove-variant').getAttribute('data-id');
                const count = parseInt(btn.getAttribute('data-item'));
                if (count <= 1) {
                    Swal.fire({
                        title: "{{translate('Warning')}}",
                        text: "{{translate('Minimum variant cannot be less than one')}}",
                        icon: 'warning',
                        confirmButtonColor: 'var(--bs-primary)',
                    });
                    return;
                }
                ajax_remove_variant(route, id);
            }
        });


        function ajax_remove_variant(route, id) {
            Swal.fire({
                title: "{{translate('are_you_sure')}}?",
                text: "{{translate('want_to_remove_this_variation')}}",
                type: 'warning',
                showCloseButton: true,
                showCancelButton: true,
                cancelButtonColor: 'var(--bs-secondary)',
                confirmButtonColor: 'var(--bs-primary)',
                cancelButtonText: 'Cancel',
                confirmButtonText: 'Yes',
                reverseButtons: true
            }).then((result) => {
                if (result.value) {
                    $.get({
                        url: route,
                        dataType: 'json',
                        data: {},
                        beforeSend: function () {
                        },
                        success: function (response) {
                            console.log(response.template)
                            $('#' + id).html(response.template);
                        },
                        complete: function () {
                        },
                    });
                }
            })
        }


        $("#category-id").change(function () {
            let id = this.value;
            let route = "{{ url('/admin/category/ajax-childes/') }}/" + id;
            ajax_switch_category(route)
        });

        function ajax_switch_category(route) {
            $.get({
                url: route + '?service_id={{$service->id}}',
                dataType: 'json',
                data: {},
                beforeSend: function () {
                },
                success: function (response) {
                    console.log(response);
                    $('#sub-category-selector').html(response.template);
                    $('#category-wise-zone').html(response.template_for_zone);
                    $('#variation-table').html(response.template_for_variant);
                    $('#variation-update-table').html(response.template_for_update_variant);
                },
                complete: function () {
                },
            });
        }

        $(document).ready(function () {
            tinymce.init({
                selector: 'textarea.ckeditor'
            });
        });

        $(".lang_link").on('click', function (e) {
            e.preventDefault();
            $(".lang_link").removeClass('active');
            $(".lang-form").addClass('d-none');
            $(".lang-form2").addClass('d-none')

            $(".title-btn-wrapper").addClass('d-none');
            $(".short-description-btn-wrapper").addClass('d-none');
            $(".description-btn-wrapper").addClass('d-none');

            $(this).addClass('active');

            let form_id = this.id;
            let lang = form_id.substring(0, form_id.length - 5);

            $("#" + lang + "-form").removeClass('d-none');
            $("#" + lang + "-form2").removeClass('d-none');

            // show the right button
            $("#title-" + lang + "-action-btn").removeClass('d-none');
            $("#short-description-" + lang + "-action-btn").removeClass('d-none');
            $("#description-" + lang + "-action-btn").removeClass('d-none');

            if (lang == '{{$default_lang}}') {
                $(".from_part_2").removeClass('d-none');
            } else {
                $(".from_part_2").addClass('d-none');
            }
        });

        /* Gallery Image block - multi file preview + new image remove */
        document.getElementById('galleryInput')?.addEventListener('change', function (e) {
            const preview = document.getElementById('galleryNewPreview');
            [...e.target.files].forEach(file => {
                const reader = new FileReader();
                reader.onload = function (ev) {
                    const div = document.createElement('div');
                    div.className = 'col-md-2 col-4 gallery-item position-relative gallery-new-item';
                    div.innerHTML = `<img src="${ev.target.result}" class="w-100 rounded border" style="height:120px;object-fit:cover" alt="gallery">
                        <button type="button" class="btn btn-sm btn-danger position-absolute" style="top:4px;right:4px;padding:0 6px;line-height:1.4"
                            onclick="this.closest('.gallery-item').remove()">&times;</button>`;
                    preview.appendChild(div);
                };
                reader.readAsDataURL(file);
            });
        });

    </script>

    <script>
        (function () {
            if (typeof bootstrap === 'undefined' || typeof Cropper === 'undefined') {
                console.error('bootstrap/cropper not loaded');
                return;
            }
            var cropRules = { thumbnail: 1, cover_image: 3 };
            var cropper = null, activeInput = null, pendingFile = null, savedPreviewSrc = '';

            document.addEventListener('change', function (e) {
                var input = e.target;
                if (!input || !input.matches || !input.matches('.upload-file__input')) return;
                var fieldName = input.getAttribute('name');
                if (!cropRules[fieldName]) return;
                if (!input.files || !input.files[0]) return;
                var file = input.files[0];
                if (file.type && file.type.indexOf('image/') !== 0) return;

                var card = input.closest('.upload-file');
                var previewImg = card ? card.querySelector('.upload-file__img img') : null;
                savedPreviewSrc = previewImg ? (previewImg.getAttribute('src') || '') : '';
                openServiceImageCropper(input, file, cropRules[fieldName]);
            }, true);

            function openServiceImageCropper(input, file, aspect) {
                activeInput = input;
                pendingFile = file;
                var modalEl = document.getElementById('serviceImageCropModal');
                var imgEl = document.getElementById('serviceCropImage');
                var hintEl = document.getElementById('serviceCropRatioHint');
                if (!modalEl || !imgEl) return;
                hintEl.textContent = aspect === 1
                    ? 'Required ratio: 1:1 (square thumbnail)'
                    : 'Required ratio: 3:1 (wide cover banner)';
                var reader = new FileReader();
                reader.onload = function (ev) {
                    imgEl.src = ev.target.result;
                    bootstrap.Modal.getOrCreateInstance(modalEl).show();
                    modalEl.addEventListener('shown.bs.modal', function onShown() {
                        modalEl.removeEventListener('shown.bs.modal', onShown);
                        if (cropper) { cropper.destroy(); cropper = null; }
                        cropper = new Cropper(imgEl, {
                            aspectRatio: aspect,
                            viewMode: 1,
                            autoCropArea: 1,
                            responsive: true,
                            background: false
                        });
                    });
                };
                reader.readAsDataURL(file);
            }

            var applyBtn = document.getElementById('serviceCropApplyBtn');
            if (applyBtn) applyBtn.addEventListener('click', function () {
                if (!cropper || !activeInput || !pendingFile) return;
                var mime = pendingFile.type === 'image/png' ? 'image/png' : 'image/jpeg';
                cropper.getCroppedCanvas().toBlob(function (blob) {
                    if (!blob || !activeInput) return;
                    var ext = mime === 'image/png' ? 'png' : 'jpg';
                    var base = (pendingFile.name || 'image').replace(/\.[^.]+$/, '');
                    var croppedFile = new File([blob], base + '_crop.' + ext, { type: mime });
                    var dt = new DataTransfer();
                    dt.items.add(croppedFile);
                    activeInput.files = dt.files;
                    var card = activeInput.closest('.upload-file');
                    var previewImg = card ? card.querySelector('.upload-file__img img') : null;
                    if (previewImg) {
                        var r = new FileReader();
                        r.onload = function (ev2) { previewImg.src = ev2.target.result; };
                        r.readAsDataURL(croppedFile);
                    }
                    bootstrap.Modal.getOrCreateInstance(document.getElementById('serviceImageCropModal')).hide();
                    if (typeof toastr !== 'undefined') toastr.success('Image cropped successfully');
                }, mime, 0.92);
            });

            var cancelBtn = document.getElementById('serviceCropCancelBtn');
            if (cancelBtn) cancelBtn.addEventListener('click', function () {
                if (activeInput) {
                    activeInput.value = '';
                    var card = activeInput.closest('.upload-file');
                    var previewImg = card ? card.querySelector('.upload-file__img img') : null;
                    if (previewImg && savedPreviewSrc) previewImg.src = savedPreviewSrc;
                }
            });

            var cropModalEl = document.getElementById('serviceImageCropModal');
            if (cropModalEl) cropModalEl.addEventListener('hidden.bs.modal', function () {
                if (cropper) { cropper.destroy(); cropper = null; }
                activeInput = null;
                pendingFile = null;
                savedPreviewSrc = '';
                var imgEl = document.getElementById('serviceCropImage');
                if (imgEl) imgEl.removeAttribute('src');
            });
        })();
    </script>
@endpush
