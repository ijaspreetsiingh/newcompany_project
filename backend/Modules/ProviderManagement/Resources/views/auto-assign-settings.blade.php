@extends('providermanagement::layouts.master')

@section('title', translate('auto_assign_settings'))

@section('content')
    <div class="main-content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <div class="page-title-wrap mb-3">
                        <h2 class="page-title">{{ translate('auto_assign_settings') }}</h2>
                    </div>

                    <div class="row">
                        <div class="col-md-8 col-xl-6">
                            <div class="card">
                                <div class="card-body">

                                    <form action="{{ route('provider.auto_assign_settings.update') }}" method="POST" id="auto-assign-form">
                                        @csrf
                                        <input type="hidden" name="auto_assign_mode" id="auto_assign_mode_input" value="{{ $provider->auto_assign_mode ? 1 : 0 }}">

                                        {{-- Toggle --}}
                                        <div class="d-flex justify-content-between align-items-center border rounded p-3 mb-4">
                                            <div>
                                                <h6 class="mb-1">{{ translate('auto_assign_mode') }}</h6>
                                                <small class="text-muted">{{ translate('auto_assign_mode_hint') }}</small>
                                            </div>
                                            <div class="form-check form-switch m-0" style="transform: scale(1.5);">
                                                <input class="form-check-input" type="checkbox" role="switch"
                                                       id="auto_assign_toggle" {{ $provider->auto_assign_mode ? 'checked' : '' }}>
                                            </div>
                                            <input type="hidden" id="switch_state" value="{{ $provider->auto_assign_mode ? '1' : '0' }}">
                                        </div>

                                        {{-- Wait time --}}
                                        <div class="border rounded p-3 mb-4" id="wait-time-section" style="{{ $provider->auto_assign_mode ? '' : 'opacity:0.5;' }}">
                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                <h6 class="mb-0">{{ translate('booking_wait_time') }}</h6>
                                                <span class="badge bg-primary" id="wait-time-label">{{ (int)($provider->auto_assign_wait_time / 60) }} {{ translate('minutes') }}</span>
                                            </div>
                                            <input type="range" class="form-range" name="auto_assign_wait_time" id="wait_time_slider"
                                                   min="60" max="600" step="60"
                                                   value="{{ $provider->auto_assign_wait_time ?: 120 }}">
                                            <small class="text-muted">{{ translate('auto_assign_wait_time_hint') }}</small>
                                        </div>

                                        <button type="submit" class="btn btn--primary">{{ translate('save') }}</button>
                                    </form>

                                </div>
                            </div>

                            {{-- Info card --}}
                            <div class="card mt-3">
                                <div class="card-body">
                                    <h6 class="mb-2"><span class="material-symbols-outlined align-middle">info</span> {{ translate('how_it_works') }}</h6>
                                    <ul class="mb-0 pl-3" style="padding-left: 1.2rem;">
                                        <li class="mb-1">{{ translate('auto_assign_info_on') }}</li>
                                        <li class="mb-1">{{ translate('auto_assign_info_off') }}</li>
                                        <li>{{ translate('auto_assign_info_timeout') }}</li>
                                    </ul>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('script')
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const toggle = document.getElementById('auto_assign_toggle');
            const modeInput = document.getElementById('auto_assign_mode_input');
            const waitSection = document.getElementById('wait-time-section');
            const slider = document.getElementById('wait_time_slider');
            const label = document.getElementById('wait-time-label');

            toggle.addEventListener('change', function () {
                modeInput.value = this.checked ? 1 : 0;
                waitSection.style.opacity = this.checked ? '1' : '0.5';
            });

            slider.addEventListener('input', function () {
                label.innerText = (this.value / 60) + ' {{ translate('minutes') }}';
            });
        });
    </script>
@endpush
