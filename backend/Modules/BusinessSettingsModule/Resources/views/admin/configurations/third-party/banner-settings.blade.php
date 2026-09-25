@php
    $sliderBanners = $sliderBanners ?? collect();
@endphp

{{-- =================== 1. AUTO SLIDE DURATION =================== --}}
@if(isset($bannerSettings))
<div class="card mb-4">
    <div class="p-20 border-bottom">
        <h4 class="page-title mb-1">{{ translate('Home banner slider settings') }}</h4>
        <p class="fz-12 mb-0">{{ translate('Manage the auto slide duration of the home screen banner slider') }}</p>
    </div>
    <div class="card-body p-20">
        <form action="{{ route('admin.configuration.set-banner-settings') }}" method="POST">
            @csrf
            @method('PUT')
            <div class="row g-3">
                <div class="col-md-4 col-12">
                    <label class="mb-2 text-dark d-flex align-items-center gap-1">
                        {{ translate('Auto slide duration (seconds)') }}
                        <i class="material-icons fz-14 text-muted" data-bs-toggle="tooltip"
                           title="{{ translate('Time in seconds after which the slider automatically moves to the next banner.') }}">info</i>
                    </label>
                    <input type="number" class="form-control" min="1" max="60" step="1"
                           name="banner_auto_slide_duration"
                           placeholder="{{ translate('e.g. 5') }}"
                           required
                           value="{{ $bannerSettings['banner_auto_slide_duration'] ?? 5 }}">
                </div>
            </div>
            @can('configuration_update')
                <div class="d-flex justify-content-end gap-2 mt-20">
                    <button type="reset" class="btn btn--secondary rounded">{{ translate('reset') }}</button>
                    <button type="submit" class="btn btn--primary demo_check rounded">{{ translate('update') }}</button>
                </div>
            @endcan
        </form>
    </div>
</div>
@endif

{{-- =================== 2. SLIDER BANNER UPLOAD =================== --}}
<div class="card mb-4">
    <div class="p-20 border-bottom d-flex align-items-center justify-content-between flex-wrap gap-2">
        <div>
            <h4 class="page-title mb-1">{{ translate('Home Screen Slider Banners') }}</h4>
            <p class="fz-12 mb-0">
                {{ translate('Upload images that will appear as the home screen carousel slider in the user app. You can add unlimited banners.') }}
            </p>
        </div>
        <span class="badge badge--primary px-3 py-2 fz-14">
            {{ $sliderBanners->count() }} {{ translate('banner(s)') }}
        </span>
    </div>

    {{-- Upload form --}}
    @can('configuration_update')
    <div class="card-body p-20 border-bottom bg-light">
        <form action="{{ route('admin.configuration.slider-banner.add') }}" method="POST" enctype="multipart/form-data" id="sliderUploadForm">
            @csrf
            <div class="row g-3 align-items-end">
                {{-- Title --}}
                <div class="col-md-3 col-12">
                    <label class="mb-2 text-dark">{{ translate('Banner Title') }} <span class="text-muted fz-11">({{ translate('optional') }})</span></label>
                    <input type="text" name="slider_title" class="form-control"
                           placeholder="{{ translate('e.g. Summer Offer') }}" maxlength="191">
                </div>

                {{-- Redirect link --}}
                <div class="col-md-3 col-12">
                    <label class="mb-2 text-dark">{{ translate('Redirect Link') }} <span class="text-muted fz-11">({{ translate('optional') }})</span></label>
                    <input type="url" name="redirect_link" class="form-control"
                           placeholder="https://example.com">
                </div>

                {{-- Image upload --}}
                <div class="col-md-4 col-12">
                    <label class="mb-2 text-dark">
                        {{ translate('Banner Image') }} <span class="text-danger">*</span>
                        <span class="text-muted fz-11">(JPG, PNG, WEBP — {{ translate('recommended') }} 1200×500)</span>
                    </label>
                    <input type="file" name="slider_image" id="sliderImageInput"
                           class="form-control" accept="image/jpeg,image/png,image/webp,image/gif"
                           required onchange="previewSliderImage(this)">
                </div>

                {{-- Preview + submit --}}
                <div class="col-md-2 col-12 d-flex align-items-center gap-2">
                    <img id="sliderPreview" src="#" alt="preview"
                         class="rounded border d-none"
                         style="height:42px;width:70px;object-fit:cover;">
                    <button type="submit" class="btn btn--primary demo_check w-100">
                        <i class="material-icons fz-18 align-middle">add_photo_alternate</i>
                        {{ translate('Add') }}
                    </button>
                </div>
            </div>
        </form>
    </div>
    @endcan

    {{-- Banners grid --}}
    <div class="card-body p-20">
        @if($sliderBanners->isEmpty())
            <div class="d-flex flex-column align-items-center justify-content-center py-5 text-center">
                <img src="{{ asset('public/assets/admin-module/img/media/banner-upload-file.png') }}"
                     alt="no banners" style="height:80px;opacity:.5;" class="mb-3"
                     onerror="this.style.display='none'">
                <p class="text-muted mb-0">{{ translate('No slider banners yet. Upload your first banner above.') }}</p>
            </div>
        @else
            <div class="row g-3" id="sliderBannerGrid">
                @foreach($sliderBanners as $banner)
                <div class="col-xl-3 col-lg-4 col-md-6 col-12" id="slider-card-{{ $banner->id }}">
                    <div class="card h-100 border shadow-sm">
                        {{-- Image --}}
                        <div style="height:160px;overflow:hidden;background:#f8f8f8;" class="rounded-top">
                            <img src="{{ $banner->banner_image_full_path }}"
                                 alt="{{ $banner->banner_title ?? 'Slider Banner' }}"
                                 style="width:100%;height:100%;object-fit:cover;"
                                 onerror="this.src='{{ asset('public/assets/admin-module/img/placeholder.png') }}'">
                        </div>

                        <div class="card-body p-12px">
                            {{-- Title --}}
                            <p class="fw-semibold mb-1 text-truncate fz-13" title="{{ $banner->banner_title ?? '' }}">
                                {{ $banner->banner_title ?: translate('Untitled Banner') }}
                            </p>

                            {{-- Redirect link --}}
                            @if($banner->redirect_link)
                                <a href="{{ $banner->redirect_link }}" target="_blank"
                                   class="d-block fz-11 text-muted text-truncate mb-2"
                                   title="{{ $banner->redirect_link }}">
                                    <i class="material-icons fz-12 align-middle">link</i>
                                    {{ $banner->redirect_link }}
                                </a>
                            @else
                                <p class="fz-11 text-muted mb-2">{{ translate('No redirect link') }}</p>
                            @endif

                            {{-- Active toggle + delete --}}
                            <div class="d-flex align-items-center justify-content-between mt-auto">
                                <div class="d-flex align-items-center gap-2">
                                    <label class="switcher mb-0" title="{{ translate('Toggle active status') }}">
                                        <input type="checkbox" class="switcher_input slider-toggle"
                                               data-id="{{ $banner->id }}"
                                               {{ $banner->is_active ? 'checked' : '' }}>
                                        <span class="switcher_control"></span>
                                    </label>
                                    <span class="fz-11 text-muted">
                                        {{ $banner->is_active ? translate('Active') : translate('Inactive') }}
                                    </span>
                                </div>

                                @can('configuration_update')
                                <form action="{{ route('admin.configuration.slider-banner.delete', $banner->id) }}"
                                      method="POST"
                                      onsubmit="return confirm('{{ translate('Delete this slider banner?') }}')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn btn-sm btn-outline-danger p-1"
                                            title="{{ translate('Delete') }}">
                                        <i class="material-icons fz-16">delete_outline</i>
                                    </button>
                                </form>
                                @endcan
                            </div>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>
        @endif
    </div>
</div>

{{-- =================== JS =================== --}}
@push('script')
<script>
    // Image preview before upload
    function previewSliderImage(input) {
        const preview = document.getElementById('sliderPreview');
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
                preview.classList.remove('d-none');
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    // Active toggle via AJAX
    document.querySelectorAll('.slider-toggle').forEach(function(toggle) {
        toggle.addEventListener('change', function() {
            const id = this.dataset.id;
            const label = this.closest('.d-flex').querySelector('span.fz-11');
            const isActive = this.checked;

            fetch("{{ url('admin/configuration/slider-banner/toggle') }}/" + id, {
                method: 'PATCH',
                headers: {
                    'X-CSRF-TOKEN': '{{ csrf_token() }}',
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                },
            })
            .then(res => res.json())
            .then(data => {
                if (label) {
                    label.textContent = isActive ? '{{ translate('Active') }}' : '{{ translate('Inactive') }}';
                }
            })
            .catch(() => {
                // revert on error
                toggle.checked = !isActive;
            });
        });
    });
</script>
@endpush
