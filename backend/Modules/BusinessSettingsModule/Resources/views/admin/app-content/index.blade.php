@extends('adminmodule::layouts.new-master')

@section('title', translate('app_content'))

@section('content')
    <div class="main-content">
        <div class="container-fluid">
            <div class="page-title-wrap mb-3">
                <h2 class="page-title">{{ translate('App Content') }}</h2>
            </div>

            <div class="pick-map mb-20 p-12 rounded d-flex flex-md-nowrap flex-wrap align-items-center gap-1 bg-primary bg-opacity-10">
                <p class="fz-12 mb-0">{{ translate('Set separate About Us / Privacy / Terms content for each app. Leave a field empty to use the default shared page.') }}</p>
            </div>

            @if(session('success'))
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    {{ session('success') }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            @endif

            <form action="{{ route('admin.configuration.app-content.update') }}" method="POST">
                @csrf
                @method('PUT')

                <ul class="nav nav-tabs mb-3" id="appContentTabs" role="tablist">
                    @foreach($apps as $index => $app)
                        <li class="nav-item" role="presentation">
                            <button class="nav-link {{ $index === 0 ? 'active' : '' }}"
                                    id="tab-{{ $app }}" data-bs-toggle="tab"
                                    data-bs-target="#pane-{{ $app }}" type="button" role="tab">
                                {{ translate($app === 'user' ? 'User App' : ($app === 'provider' ? 'Provider App' : 'Serviceman App')) }}
                            </button>
                        </li>
                    @endforeach
                </ul>

                <div class="tab-content">
                    @foreach($apps as $index => $app)
                        <div class="tab-pane fade {{ $index === 0 ? 'show active' : '' }}"
                             id="pane-{{ $app }}" role="tabpanel">
                            <div class="card mb-20">
                                <div class="card-body p-20">
                                    @foreach($pages as $page)
                                        <div class="mb-3">
                                            <label class="form-label fw-semibold text-dark">
                                                {{ translate(str_replace('_', ' ', $page)) }}
                                            </label>
                                            <textarea name="{{ $page . '_' . $app }}"
                                                      class="form-control"
                                                      rows="4"
                                                      placeholder="{{ translate('Leave empty to use the default shared page') }}">{{ old($page . '_' . $app, $content[$app][$page]) }}</textarea>
                                        </div>
                                    @endforeach
                                </div>
                            </div>
                        </div>
                    @endforeach
                </div>

                <div class="mb-20 text-end">
                    <button type="submit" class="btn btn--primary transition fz-12 fw-semibold px-4">
                        {{ translate('save_changes') }}
                    </button>
                </div>
            </form>
        </div>
    </div>
@endsection
