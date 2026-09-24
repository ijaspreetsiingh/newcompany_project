@extends('adminmodule::layouts.master')

@section('title',translate('zone_edit'))

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
                        <h2 class="page-title">{{translate('zone_update')}}</h2>
                    </div>

                    <div class="card zone-setup-instructions mb-30">
                        <div class="card-body p-30">
                            <form action="{{route('admin.zone.update',[$zone->id])}}" enctype="multipart/form-data"
                                  method="POST">
                                @csrf
                                @method('PUT')
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
                                                    <p>{{translate('click_this_icon_to_start_pin_points_in_the_map_and_connect_them_
                                                        to_draw_a_
                                                        zone_._Minimum_3_points_required')}}
                                                    </p>
                                                </div>
                                            </div>
                                            <div class="map-img mt-4">
                                                <img src="{{asset('public/assets/admin-module/img/instructions.gif')}}"
                                                     alt="">
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
                                            <div class="form-floating form-floating__icon mb-30 lang-form" id="default-form">
                                                <input type="text" name="name[]" class="form-control"
                                                       placeholder="{{translate('zone_name')}}"
                                                       value="{{$zone?->getRawOriginal('name')}}" required>
                                                <label>{{translate('zone_name')}} ({{ translate('default') }})</label>
                                                <span class="material-icons">note_alt</span>
                                            </div>
                                            <input type="hidden" name="lang[]" value="default">
                                            @foreach ($language?->live_values as $lang)
                                                    <?php
                                                    if (count($zone['translations'])) {
                                                        $translate = [];
                                                        foreach ($zone['translations'] as $t) {
                                                            if ($t->locale == $lang['code'] && $t->key == "zone_name") {
                                                                $translate[$lang['code']]['zone_name'] = $t->value;
                                                            }
                                                        }
                                                    }
                                                    ?>
                                                <div class="form-floating form-floating__icon mb-30 d-none lang-form"
                                                     id="{{$lang['code']}}-form">
                                                    <input type="text" name="name[]" class="form-control"
                                                           placeholder="{{translate('zone_name')}}"
                                                           value="{{$translate[$lang['code']]['zone_name']??''}}">
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
                                                               required value="{{$zone->name}}">
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
                                                      class="form-control" readonly>
                                                @foreach($zone->coordinates[0]->toArray()['coordinates'] as $key=>$coords)<?php if (count($zone->coordinates[0]->toArray()['coordinates']) != $key + 1){if ($key != 0) echo(','); ?>({{$coords[1]}},{{$coords[0]}})<?php } ?>@endforeach
                                            </textarea>
                                        </div>

                                        <div class="map-warper overflow-hidden map_area">
                                            <input id="pac-input" class="controls rounded search_area"
                                                   title="{{translate('search_your_location_here')}}" type="text"
                                                   placeholder="{{translate('search_here')}}"/>
                                            <div class="map_canvas" id="map-canvas"></div>
                                        </div>
                                    </div>
                                    <div class="col-12">
                                        <div class="d-flex justify-content-end gap-20 mt-30">
                                            <button class="btn btn--secondary" type="reset"
                                                    id="reset_btn">{{translate('reset')}}</button>
                                            <button class="btn btn--primary"
                                                    type="submit">{{translate('update')}}</button>
                                        </div>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('script')
    @php($api_key=(business_config('google_map', 'third_party'))->live_values)
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet.draw/1.0.4/leaflet.draw.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet.draw/1.0.4/leaflet.draw.js"></script>

    <script>
        "use strict";
        auto_grow();

        function auto_grow() {
            let element = document.getElementById("coordinates");
            element.style.height = "5px";
            element.style.height = (element.scrollHeight) + "px";
        }

        let map;
        let lat_longs = new Array();
        let drawnItems;
        let lastpolygon = null;
        let bounds;
        let polygons = [];


        function initialize() {
            let myLatlng = [{{trim(explode(' ',$zone->center)[1], 'POINT()')}}, {{trim(explode(' ',$zone->center)[0], 'POINT()')}}];
            map = L.map("map-canvas").setView(myLatlng, 13);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; OpenStreetMap contributors'
            }).addTo(map);

            var polygonCoords = [
                    @foreach($area['coordinates'] as $coords)
                        [{{$coords[1]}}, {{$coords[0]}}],
                    @endforeach
            ];

            var zonePolygon = L.polygon(polygonCoords, {
                color: '#050df2',
                weight: 2,
                opacity: 0.8,
                fillOpacity: 0,
                interactive: false
            }).addTo(map);

            map.fitBounds(zonePolygon.getBounds());

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

            map.on(L.Draw.Event.CREATED, function (event) {
                if (lastpolygon) {
                    drawnItems.removeLayer(lastpolygon);
                }
                var layer = event.layer;
                drawnItems.addLayer(layer);
                lastpolygon = layer;
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
                if (lastpolygon) {
                    drawnItems.removeLayer(lastpolygon);
                    lastpolygon = null;
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

        function set_all_zones() {
            $.get({
                url: '{{route('admin.zone.get-active-zones',[$zone->id])}}',
                dataType: 'json',
                success: function (data) {
                    for (var i = 0; i < data.length; i++) {
                        var zonePoly = L.polygon(data[i], {
                            color: '#FF0000',
                            weight: 2,
                            opacity: 0.8,
                            fillColor: '#FF0000',
                            fillOpacity: 0.1
                        }).addTo(map);
                        polygons.push(zonePoly);
                    }
                },
            });
        }

        $(document).on('ready', function () {
            set_all_zones();
        });

        $('#reset_btn').click(function () {
            $('#name').val(null);

            if (lastpolygon) {
                drawnItems.removeLayer(lastpolygon);
                lastpolygon = null;
            }
            $('#coordinates').val(null);
        })

        function performValidation(event) {
            return true;

            if (!lastpolygon) {
                event.preventDefault();
            }
        }

        $('form').submit(function(event) {
            performValidation(event);
        });

        $('#pac-input').keydown(function(event) {
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
            console.log(lang);
            $("#" + lang + "-form").removeClass('d-none');
        });
    </script>
@endpush
