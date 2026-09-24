@extends('servicemanmodule::layouts.new-master')
@section('title', translate('Booking_Details').' #'.$booking->readable_id)

@section('content')
<div class="content container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div class="d-flex align-items-center gap-3">
            <a href="{{route('serviceman.booking.list')}}" class="btn btn-outline-secondary btn-sm">
                <span class="material-icons" style="font-size:16px">arrow_back</span>
            </a>
            <h4 class="mb-0">{{translate('booking_details')}} #{{ $booking->readable_id }}</h4>
        </div>
        <div>
            @if($booking->booking_status == 'pending' || $booking->booking_status == 'accepted')
                <span class="badge bg-warning fs-6">{{translate('pending')}}</span>
            @elseif($booking->booking_status == 'ongoing')
                <span class="badge bg-info fs-6">{{translate('ongoing')}}</span>
            @elseif($booking->booking_status == 'completed')
                <span class="badge bg-success fs-6">{{translate('completed')}}</span>
            @elseif($booking->booking_status == 'canceled')
                <span class="badge bg-danger fs-6">{{translate('canceled')}}</span>
            @endif
        </div>
    </div>

    <div class="row">
        <div class="col-xl-8">
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">{{translate('service_details')}}</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>{{translate('service')}}</th>
                                    <th>{{translate('variant')}}</th>
                                    <th class="text-center">{{translate('quantity')}}</th>
                                    <th class="text-end">{{translate('unit_price')}}</th>
                                    <th class="text-end">{{translate('total')}}</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($booking->detail as $detail)
                                    <tr>
                                        <td>{{ $detail->service?->name ?? '-' }}</td>
                                        <td>{{ $detail->variation ?? '-' }}</td>
                                        <td class="text-center">{{ $detail->quantity }}</td>
                                        <td class="text-end">{{ with_decimal_point($detail->service_unit_cost) }}</td>
                                        <td class="text-end">{{ with_decimal_point($detail->service_total_cost) }}</td>
                                    </tr>
                                @endforeach
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td colspan="4" class="text-end fw-bold">{{translate('subtotal')}}</td>
                                    <td class="text-end">{{ with_decimal_point($booking->total_order_amount) }}</td>
                                </tr>
                                @if(($booking->total_discount_amount ?? 0) > 0)
                                    <tr>
                                        <td colspan="4" class="text-end">{{translate('discount')}}</td>
                                        <td class="text-end text-success">-{{ with_decimal_point($booking->total_discount_amount) }}</td>
                                    </tr>
                                @endif
                                @if(($booking->total_tax_amount ?? 0) > 0)
                                    <tr>
                                        <td colspan="4" class="text-end">{{translate('tax')}}</td>
                                        <td class="text-end">{{ with_decimal_point($booking->total_tax_amount) }}</td>
                                    </tr>
                                @endif
                                <tr class="border-top">
                                    <td colspan="4" class="text-end fw-bold fs-5">{{translate('grand_total')}}</td>
                                    <td class="text-end fw-bold fs-5">{{ with_decimal_point($booking->total_order_amount) }}</td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                </div>
            </div>

            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">{{translate('service_location')}}</h5>
                </div>
                <div class="card-body">
                    @if(isset($booking->service_address) && isset($booking->service_address->lat) && isset($booking->service_address->lon))
                        <div id="service-location-map" style="height: 300px; border-radius: 8px; border: 1px solid #dee2e6; margin-bottom: 16px;"></div>
                        <div class="d-flex align-items-start gap-3">
                            <span class="material-icons text-primary">location_on</span>
                            <div>
                                <p class="mb-1 fw-medium">{{ $booking->service_address->address ?? '-' }}</p>
                                <small class="text-muted">
                                    {{ $booking->service_address->contact_person_name ?? '' }}
                                    {{ $booking->service_address->contact_person_number ? '| '.$booking->service_address->contact_person_number : '' }}
                                </small>
                                <br>
                                <a href="https://www.openstreetmap.org/directions?engine=fossgis_osrm_car&lat={{ $booking->service_address->lat }}&lon={{ $booking->service_address->lon }}" target="_blank" class="btn btn-sm btn-primary mt-2">
                                    <span class="material-icons" style="font-size:16px">directions</span> {{translate('get_directions')}}
                                </a>
                            </div>
                        </div>
                    @elseif(isset($booking->service_address))
                        <div class="d-flex align-items-start gap-3">
                            <span class="material-icons text-primary">location_on</span>
                            <div>
                                <p class="mb-1">{{ $booking->service_address->address ?? '-' }}</p>
                                <small class="text-muted">
                                    {{ $booking->service_address->contact_person_name ?? '' }}
                                    {{ $booking->service_address->contact_person_number ? '| '.$booking->service_address->contact_person_number : '' }}
                                </small>
                            </div>
                        </div>
                    @else
                        <p class="text-muted">{{translate('no_address')}}</p>
                    @endif
                </div>
            </div>

            @if($booking->photo_evidence_full_path && count($booking->photo_evidence_full_path) > 0)
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">{{translate('evidence_photos')}}</h5>
                    </div>
                    <div class="card-body">
                        <div class="d-flex gap-2 flex-wrap">
                            @foreach($booking->photo_evidence_full_path as $photo)
                                <img src="{{ $photo }}" class="rounded" width="120" height="120" style="object-fit:cover;" alt="">
                            @endforeach
                        </div>
                    </div>
                </div>
            @endif
        </div>

        <div class="col-xl-4">
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">{{translate('customer_info')}}</h5>
                </div>
                <div class="card-body">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <img src="{{ $booking->customer?->profile_image_full_path ?? '' }}" class="rounded-circle" width="50" height="50" alt="">
                        <div>
                            <h6 class="mb-0">{{ $booking->customer?->first_name ?? '' }} {{ $booking->customer?->last_name ?? '' }}</h6>
                            <small class="text-muted">{{ $booking->customer?->phone ?? '' }}</small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">{{translate('payment_info')}}</h5>
                </div>
                <div class="card-body">
                    <div class="d-flex flex-column gap-2">
                        <div class="d-flex justify-content-between">
                            <span class="text-muted">{{translate('payment_method')}}</span>
                            <span class="fw-medium">{{ str_replace('_', ' ', ucfirst($booking->payment_method ?? '-')) }}</span>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span class="text-muted">{{translate('payment_status')}}</span>
                            @if($booking->is_paid)
                                <span class="badge bg-success">{{translate('paid')}}</span>
                            @else
                                <span class="badge bg-warning">{{translate('unpaid')}}</span>
                            @endif
                        </div>
                        <div class="d-flex justify-content-between">
                            <span class="text-muted">{{translate('total_amount')}}</span>
                            <span class="fw-bold">{{ with_decimal_point($booking->total_order_amount) }}</span>
                        </div>
                    </div>
                </div>
            </div>

            @if($booking->booking_status == 'completed' || $booking->booking_status == 'ongoing')
                @php($otpVerify = business_config('confirm_otp_for_complete_service', 'booking_setup'))
                @if(isset($otpVerify) && $otpVerify->live_values == 1)
                    <div class="card mb-4 border-primary">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0">{{translate('otp_verification')}}</h5>
                        </div>
                        <div class="card-body text-center">
                            <p class="text-muted">{{translate('share_this_otp_with_customer')}}</p>
                            <h2 class="text-primary fw-bold letter-spacing-3">{{ $booking->booking_otp ?? '----' }}</h2>
                        </div>
                    </div>
                @endif
            @endif

            @if(in_array($booking->booking_status, ['pending', 'accepted']))
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">{{translate('update_status')}}</h5>
                    </div>
                    <div class="card-body">
                        <form action="{{route('serviceman.booking.status-update')}}" method="POST">
                            @csrf
                            <input type="hidden" name="booking_id" value="{{ $booking->id }}">
                            <input type="hidden" name="booking_status" value="ongoing">
                            <button type="submit" class="btn btn-primary w-100" onclick="return confirm('{{translate('are_you_sure_start_service')}}')">
                                <span class="material-icons me-1">play_arrow</span> {{translate('start_service')}}
                            </button>
                        </form>
                    </div>
                </div>
            @endif

            @if($booking->booking_status == 'ongoing')
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">{{translate('complete_service')}}</h5>
                    </div>
                    <div class="card-body">
                        @php($otpVerify = business_config('confirm_otp_for_complete_service', 'booking_setup'))
                        <form action="{{route('serviceman.booking.status-update')}}" method="POST" id="completeForm">
                            @csrf
                            <input type="hidden" name="booking_id" value="{{ $booking->id }}">
                            <input type="hidden" name="booking_status" value="completed">

                            @if(isset($otpVerify) && $otpVerify->live_values == 1)
                                <div class="mb-3">
                                    <label class="form-label">{{translate('enter_otp_from_customer')}}</label>
                                    <input type="text" name="otp" class="form-control text-center fw-bold" maxlength="4" pattern="[0-9]{4}" placeholder="____" required>
                                </div>
                            @endif

                            <button type="submit" class="btn btn-success w-100" onclick="return confirm('{{translate('are_you_sure_complete_service')}}')">
                                <span class="material-icons me-1">check_circle</span> {{translate('complete_service')}}
                            </button>
                        </form>
                    </div>
                </div>
            @endif
        </div>
    </div>
</div>

@push('script')
    @if(isset($booking->service_address) && isset($booking->service_address->lat) && isset($booking->service_address->lon))
        <script>
            (function() {
                var lat = {{ $booking->service_address->lat }};
                var lon = {{ $booking->service_address->lon }};

                var map = L.map('service-location-map').setView([lat, lon], 15);

                L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
                    maxZoom: 19
                }).addTo(map);

                var customerIcon = L.divIcon({
                    className: 'custom-marker',
                    html: '<div style="background:#dc3545;width:12px;height:12px;border-radius:50%;border:3px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,0.4);"></div>',
                    iconSize: [18, 18],
                    iconAnchor: [9, 9]
                });

                L.marker([lat, lon], {icon: customerIcon}).addTo(map)
                    .bindPopup('<strong>{{ addslashes($booking->service_address->contact_person_name ?? "Customer") }}</strong><br>{{ addslashes(Str::limit($booking->service_address->address ?? "", 60)) }}')
                    .openPopup();

                setTimeout(function() { map.invalidateSize(); }, 200);
            })();
        </script>
    @endif

    @if($booking->booking_status == 'ongoing')
        <script>
            (function() {
                var trackingActive = true;
                var watchId = null;
                var sendInterval = null;
                var lastLat = null;
                var lastLng = null;
                var csrfToken = '{{ csrf_token() }}';
                var updateUrl = '{{ route("serviceman.update-location") }}';

                function sendLocation(lat, lng) {
                    $.ajax({
                        url: updateUrl,
                        method: 'POST',
                        headers: { 'X-CSRF-TOKEN': csrfToken },
                        data: { lat: lat, lng: lng },
                        success: function() {},
                        error: function() {}
                    });
                }

                function startTracking() {
                    if (!navigator.geolocation) return;

                    watchId = navigator.geolocation.watchPosition(
                        function(pos) {
                            lastLat = pos.coords.latitude;
                            lastLng = pos.coords.longitude;
                        },
                        function(err) {},
                        { enableHighAccuracy: true, maximumAge: 5000, timeout: 10000 }
                    );

                    sendInterval = setInterval(function() {
                        if (lastLat !== null && lastLng !== null && trackingActive) {
                            sendLocation(lastLat, lastLng);
                        }
                    }, 10000);
                }

                startTracking();

                window.addEventListener('beforeunload', function() {
                    trackingActive = false;
                    if (watchId !== null) navigator.geolocation.clearWatch(watchId);
                    if (sendInterval !== null) clearInterval(sendInterval);
                });
            })();
        </script>
    @endif
@endpush
@endsection
