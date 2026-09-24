@extends('adminmodule::layouts.new-master')

@section('title',translate('zone_setup'))

@push('css_or_js')
    <link rel="stylesheet" href="{{asset('public/assets/admin-module/plugins/dataTables/jquery.dataTables.min.css')}}"/>
    <link rel="stylesheet" href="{{asset('public/assets/admin-module/plugins/dataTables/select.dataTables.min.css')}}"/>
    <link rel="stylesheet" href="{{asset('public/assets/admin-module/css/zone-module.css')}}"/>
@endpush

@section('content')
    <div class="main-content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <div class="page-title-wrap mb-3">
                        <h2 class="page-title">{{translate('zone_setup')}}</h2>
                    </div>

                    @can('zone_add')
                        <div class="card zone-setup-instructions mb-30">
                            <div class="card-body p-30">
                                <form id="zone-form" action="{{route('admin.zone.store')}}"
                                      enctype="multipart/form-data"
                                      method="POST">
                                    @csrf
                                    <div class="row justify-content-between">
                                        <div class="col-lg-5 col-xl-4 mb-5 mb-lg-0">
                                            <h4 class="mb-3 c1">{{translate('instructions')}}</h4>
                                            <div class="d-flex flex-column">
                                                <p>{{translate('create_zone_by_click_on_map_and_connect_the_dots_together')}}</p>

                                                <div class="media mb-2 gap-3 align-items-center">
                                                    <img
                                                        src="{{asset('public/assets/admin-module/img/icons/map-drag.png')}}"
                                                        alt="{{ translate('image') }}" class="map-icon-global">
                                                    <div class="media-body ">
                                                        <p>{{translate('use_this_to_drag_map_to_find_proper_area')}}</p>
                                                    </div>
                                                </div>

                                                <div class="media gap-3 align-items-center">
                                                    <img
                                                        src="{{asset('public/assets/admin-module/img/icons/map-draw.png')}}"
                                                        alt="{{ translate('image') }}" class="map-icon-global">
                                                    <div class="media-body ">
                                                        <p>{{translate('click_this_icon_to_start_pin_points_in_the_map_and_connect_them_to_draw_a_
                                                        zone_._Minimum_3_points_required')}}
                                                        </p>
                                                    </div>
                                                </div>
                                                <div class="map-img mt-4">
                                                    <img class="dark-support"
                                                         src="{{asset('public/assets/admin-module/img/instructions.gif')}}"
                                                         alt="{{ translate('image') }}">
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-lg-7">
                                            @php($language= Modules\BusinessSettingsModule\Entities\BusinessSettings::where('key_name','system_language')->first())
                                            @php($default_lang = str_replace('_', '-', app()->getLocale()))
                                            @if($language)
                                                <ul class="nav nav--tabs border-color-primary mb-4">
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
                                            @if($language)
                                                <div class="form-floating form-floating__icon mb-30 lang-form"
                                                     id="default-form">
                                                    <input type="text" name="name[]" class="form-control"
                                                           placeholder="{{translate('zone_name')}}" required>
                                                    <label>{{translate('zone_name')}} ({{ translate('default') }}
                                                        )</label>
                                                    <span class="material-icons">note_alt</span>
                                                </div>
                                                <input type="hidden" name="lang[]" value="default">
                                                @foreach ($language?->live_values as $lang)
                                                    <div
                                                        class="form-floating form-floating__icon mb-30 d-none lang-form"
                                                        id="{{$lang['code']}}-form">
                                                        <input type="text" name="name[]" class="form-control"
                                                               placeholder="{{translate('zone_name')}}">
                                                        <label>{{translate('zone_name')}}
                                                            ({{strtoupper($lang['code'])}})</label>
                                                        <span class="material-icons">note_alt</span>
                                                    </div>
                                                    <input type="hidden" name="lang[]" value="{{$lang['code']}}">
                                                @endforeach
                                            @else
                                                <div class="lang-form">
                                                    <div class="mb-30">
                                                        <div class="form-floating form-floating__icon">
                                                            <input type="text" class="form-control" name="name[]"
                                                                   placeholder="{{translate('zone_name')}} *"
                                                                   required value="{{old('name')}}">
                                                            <label>{{translate('zone_name')}} *</label>
                                                            <span class="material-icons">note_alt</span>
                                                        </div>
                                                    </div>
                                                </div>
                                                <input type="hidden" name="lang[]" value="default">
                                            @endif

                                            <div class="form-group mb-3 coordinates">
                                                <label class="input-label"
                                                       for="exampleFormControlInput1">{{translate('coordinates')}}
                                                    <span
                                                        class="input-label-secondary">{{translate('draw_your_zone_on_the_map')}}</span>
                                                </label>
                                                <textarea type="text" rows="8" name="coordinates" id="coordinates"
                                                          class="form-control" readonly></textarea>
                                            </div>

                                            <div class="map-warper map__zone-setup dark-support rounded overflow-hidden">
                                                <input id="pac-input" class="controls rounded search_area"
                                                       title="{{translate('search_your_location_here')}}" type="text"
                                                       placeholder="{{translate('search_here')}}"/>
                                                <div class="map_canvas" id="map-canvas"></div>
                                            </div>
                                        </div>
                                        <div class="col-12">
                                            <div class="d-flex justify-content-end gap-3 mt-30">
                                                <button class="btn btn--secondary" type="reset"
                                                        id="reset_btn">{{translate('reset')}}</button>
                                                <button class="btn btn--primary"
                                                        type="submit">{{translate('submit')}}</button>
                                            </div>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    @endcan

                    <div class="d-flex justify-content-end border-bottom mx-lg-4 mb-10">
                        <div class="d-flex gap-2 fw-medium">
                            <span class="opacity-75">{{translate('Total_Zones')}}:</span>
                            <span class="title-color">{{ $zones->total() }}</span>
                        </div>
                    </div>

                    <div class="card mb-30">
                        <div class="card-body">
                            <div class="data-table-top d-flex flex-wrap gap-10 justify-content-between">
                                <form action="{{url()->current()}}" class="search-form search-form_style-two"  method="GET">
                                    <div class="input-group search-form__input_group">
                                            <span class="search-form__icon">
                                                <span class="material-icons">search</span>
                                            </span>
                                        <input type="search" class="theme-input-style search-form__input zone-search-input"
                                               value="{{$search}}" name="search"
                                               placeholder="{{translate('search_here')}}">
                                    </div>
                                    <button type="submit" class="btn btn--primary">{{translate('search')}}</button>
                                </form>

                                <div class="d-flex flex-wrap align-items-center gap-3">
                                    @can('zone_export')
                                        <div class="dropdown">
                                            <button type="button"
                                                    class="btn btn--secondary text-capitalize dropdown-toggle"
                                                    data-bs-toggle="dropdown">
                                                <span
                                                    class="material-icons">file_download</span> {{translate('download')}}
                                            </button>
                                            <ul class="dropdown-menu dropdown-menu-lg dropdown-menu-right">
                                                <li><a class="dropdown-item"
                                                       href="{{route('admin.zone.download')}}?search={{$search}}">{{translate('excel')}}</a>
                                                </li>
                                            </ul>
                                        </div>
                                    @endcan
                                </div>
                            </div>

                            <div id="ListTableContainer">
                                @include('zonemanagement::admin.partials._table')
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <input type="hidden" id="offset" value="{{ request()->page }}">

@endsection

@push('script')
    <script src="{{asset('public/assets/admin-module/plugins/dataTables/jquery.dataTables.min.js')}}"></script>
    <script src="{{asset('public/assets/admin-module/plugins/dataTables/dataTables.select.min.js')}}"></script>

    @php($api_key=(business_config('google_map', 'third_party'))->live_values)
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet.draw/1.0.4/leaflet.draw.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet.draw/1.0.4/leaflet.draw.js"></script>

    <script>
        "use strict";

        let map;
        let drawnItems;
        let lastPolygon = null;
        let polygons = [];

        function initialize() {
            let myLatLng = {
                lat: 23.757989,
                lng: 90.360587
            };

            map = L.map("map-canvas").setView(myLatLng, 10);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; OpenStreetMap contributors'
            }).addTo(map);

            drawnItems = new L.FeatureGroup();
            map.addLayer(drawnItems);

            var drawControl = new L.Control.Draw({
                draw: {
                    polygon: {
                        shapeOptions: {
                            color: '#050df2'
                        },
                        allowIntersection: false,
                        showArea: true
                    },
                    marker: false,
                    polyline: false,
                    circle: false,
                    circlemarker: false,
                    rectangle: false
                },
                edit: {
                    featureGroup: drawnItems
                }
            });
            map.addControl(drawControl);

            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(
                    (position) => {
                        const pos = {
                            lat: position.coords.latitude,
                            lng: position.coords.longitude,
                        };
                        map.setView(pos, 13);
                    });
            }

            map.on(L.Draw.Event.CREATED, function (event) {
                if (lastPolygon) {
                    drawnItems.removeLayer(lastPolygon);
                }
                var layer = event.layer;
                drawnItems.addLayer(layer);
                lastPolygon = layer;
                var coords = layer.getLatLngs()[0].map(function(latlng) {
                    return '(' + latlng.lat + ',' + latlng.lng + ')';
                });
                $('#coordinates').val('(' + coords.join(',') + ')');
            });

            var resetDiv = L.DomUtil.create('div', 'leaflet-control leaflet-control-custom');
            resetDiv.innerHTML = 'X';
            resetDiv.style.backgroundColor = '#fff';
            resetDiv.style.border = '2px solid #fff';
            resetDiv.style.borderRadius = '3px';
            resetDiv.style.boxShadow = '0 2px 6px rgba(0,0,0,.3)';
            resetDiv.style.cursor = 'pointer';
            resetDiv.style.padding = '2px 6px';
            resetDiv.style.fontSize = '12px';
            resetDiv.title = 'Reset map';
            resetDiv.addEventListener('click', function() {
                if (lastPolygon) {
                    drawnItems.removeLayer(lastPolygon);
                    lastPolygon = null;
                }
                $('#coordinates').val('');
            });
            var resetControl = L.Control.extend({
                options: { position: 'topleft' },
                onAdd: function() { return resetDiv; }
            });
            new resetControl().addTo(map);

            const input = document.getElementById("pac-input");
            var searchControl = L.Control.extend({
                options: { position: 'topleft' },
                onAdd: function() {
                    var container = L.DomUtil.create('div');
                    container.appendChild(input);
                    return container;
                }
            });
            new searchControl().addTo(map);

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
                                    searchMarkers.push(mrkr);
                                });
                                map.fitBounds(searchMarkers.map(function(m) { return m.getLatLng(); }));
                            }
                        });
                }
            });
        }

        window.addEventListener('load', initialize);


        $('#reset_btn').click(function (e) {
            e.preventDefault();

            $('input[name="name[]"]').val('');

            $('#coordinates').val('');
            if (lastPolygon) {
                drawnItems.removeLayer(lastPolygon);
                lastPolygon = null;
            }

            // Re-center the map to default location
            if (map) {
                map.setView({ lat: 23.757989, lng: 90.360587 }, 10);
            }

            $('#pac-input').val('');
        });


        function performValidation(event) {
            if (!lastpolygon) {
                event.preventDefault();
                toastr.warning('{{ translate('Please draw your zone on the map') }}', {
                    CloseButton: true,
                    ProgressBar: true,
                });
            }
        }

        $('#zone-form').submit(function (event) {
            performValidation(event);
        });

        $('#pac-input').keydown(function (event) {
            if (event.keyCode === 13) {
                performValidation(event);
            }
        });

        $(".lang_link").on('click', function (e) {
            e.preventDefault();
            $(".lang_link").removeClass('active');
            $(".lang-form").addClass('d-none');
            $(this).addClass('active');

            let form_id = this.id;
            let lang = form_id.substring(0, form_id.length - 5);
            $("#" + lang + "-form").removeClass('d-none');
        });

        let statusSelectedItem;
        let statusSelectedRoute;
        let statusInitialState;

        $('.nav-link').on('click', function () {
            const urlParams = new URLSearchParams($(this).attr('href').split('?')[1]);
        });

        $(document).on('change', '.status-update', function (e) {
            // Prevent default toggle behavior to avoid checkbox jumping
            e.preventDefault();
            e.stopImmediatePropagation();

            statusSelectedItem = $(this);
            statusInitialState = statusSelectedItem.prop('checked'); // Get current state (true if ON)

            // Immediately revert the checkbox visually until confirmation
            statusSelectedItem.prop('checked', !statusInitialState);

            let itemId = statusSelectedItem.data('id');
            statusSelectedRoute = '{{ route('admin.zone.status-update', ['id' => ':itemId']) }}'.replace(':itemId', itemId);

            let confirmationTitleText = statusInitialState
                ? '{{ translate('Are you sure to Turn On the Zone Status') }}?'
                : '{{ translate('Are you sure to Turn Off the Zone Status') }}?';

            $('.confirmation-title-text').text(confirmationTitleText);

            let confirmationDescriptionText = statusInitialState
                ? '{{ translate('Once you turn on the Zone Status, the user can find the category, services, and location in that zone') }}.'
                : '{{ translate('Once you turn off the Zone Status it will impact the category, services, and location finding for customers') }}.';

            $('.confirmation-description-text').text(confirmationDescriptionText);

            let imgSrc = statusInitialState
                ? "{{ asset('public/assets/admin-module/img/icons/status-on.png') }}"
                : "{{ asset('public/assets/admin-module/img/icons/status-off.png') }}";

            $('#confirmChangeModal img').attr('src', imgSrc);

            showModal();
        });

        $('#confirmChange').on('click', function () {
            updateStatus(statusSelectedRoute);
        });

        $('.cancel-change').on('click', function () {
            resetCheckboxState();
            hideModal();
        });

        $('#confirmChangeModal').on('hidden.bs.modal', function () {
            resetCheckboxState();
        });

        function showModal() {
            $('#confirmChangeModal').modal('show');
        }

        function hideModal() {
            $('#confirmChangeModal').modal('hide');
        }

        //  Reverts checkbox if user cancels
        function resetCheckboxState() {
            if (statusSelectedItem) {
                statusSelectedItem.prop('checked', !statusInitialState);
            }
        }

        //  AJAX update - triggers only if user confirms
        function updateStatus(route) {
            let page = $('#offset').val();
            $.ajax({
                url: route,
                type: 'POST',
                data: {_token: '{{ csrf_token() }}'},
                dataType: 'json',
                success: function (data) {
                    toastr.success(data.message, {
                        CloseButton: true,
                        ProgressBar: true
                    });

                    // Update UI manually or reload table as needed
                    reloadTable(page); // Optional - if backend changes are needed
                    hideModal();
                },
                error: function () {
                    resetCheckboxState();
                    toastr.error('Something went wrong! Please try again.');
                }
            });
        }

        function reloadTable(page) {
            let search = $('.zone-search-input').val();
            $.ajax({
                url: "{{ route('admin.zone.table') }}",
                type: "GET",
                data: {
                    search: search,
                    page: page
                },
                success: function (response) {
                    if (response.page != page) {
                        updateBrowserUrl(search, response.page);
                        $('#offset').val((response.page - 1) * {{ pagination_limit() }});
                    } else {
                        $('#offset').val(response.offset);
                        updateBrowserUrl(search, page);
                    }

                    $('#totalListCount').html(response.totalCount)
                    $('#ListTableContainer').empty().html(response.view);
                },
                error: function () {
                    toastr.error('Failed to update table. Please reload the page.', {
                        CloseButton: true,
                        ProgressBar: true
                    });
                }
            });
        }

        function updateBrowserUrl(search, page) {
            const params = new URLSearchParams();
            if (search) params.set('search', search);
            if (page > 1) params.set('page', page);

            const newUrl = `${window.location.pathname}?${params.toString()}`;
            window.history.replaceState({}, '', newUrl);
        }
    </script>
@endpush
