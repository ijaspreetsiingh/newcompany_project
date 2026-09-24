@extends('servicemanmodule::layouts.new-master')
@section('title', translate('ServiceMan_Dashboard'))

@section('content')
<div class="content container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="mb-0">{{translate('dashboard')}}</h4>
        <span class="text-muted">{{date('d M Y')}}</span>
    </div>

    <div class="row">
        <div class="col-xl-3 col-sm-6 mb-4">
            <div class="card h-100">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="avatar avatar-lg bg-primary-subtle rounded">
                        <span class="material-icons text-primary">assignment</span>
                    </div>
                    <div>
                        <h3 class="mb-0">{{ $total_bookings }}</h3>
                        <p class="text-muted mb-0">{{translate('total_bookings')}}</p>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-sm-6 mb-4">
            <div class="card h-100">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="avatar avatar-lg bg-warning-subtle rounded">
                        <span class="material-icons text-warning">pending_actions</span>
                    </div>
                    <div>
                        <h3 class="mb-0">{{ $pending_bookings }}</h3>
                        <p class="text-muted mb-0">{{translate('pending')}}</p>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-sm-6 mb-4">
            <div class="card h-100">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="avatar avatar-lg bg-info-subtle rounded">
                        <span class="material-icons text-info">autorenew</span>
                    </div>
                    <div>
                        <h3 class="mb-0">{{ $ongoing_bookings }}</h3>
                        <p class="text-muted mb-0">{{translate('ongoing')}}</p>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-sm-6 mb-4">
            <div class="card h-100">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="avatar avatar-lg bg-success-subtle rounded">
                        <span class="material-icons text-success">check_circle</span>
                    </div>
                    <div>
                        <h3 class="mb-0">{{ $completed_bookings }}</h3>
                        <p class="text-muted mb-0">{{translate('completed')}}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-xl-8 mb-4">
            <div class="card h-100">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">{{translate('recent_bookings')}}</h5>
                    <a href="{{route('serviceman.booking.list', ['status' => 'all'])}}" class="btn-link">{{translate('view_all')}}</a>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>{{translate('booking_id')}}</th>
                                    <th>{{translate('service')}}</th>
                                    <th>{{translate('customer')}}</th>
                                    <th>{{translate('status')}}</th>
                                    <th>{{translate('date')}}</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($recent_bookings as $booking)
                                    <tr>
                                        <td>
                                            <a href="{{route('serviceman.booking.details', [$booking->id])}}" class="text-primary">
                                                #{{ $booking->readable_id }}
                                            </a>
                                        </td>
                                        <td>{{ $booking->detail->first()?->service?->name ?? '-' }}</td>
                                        <td>{{ $booking->customer?->first_name ?? '-' }}</td>
                                        <td>
                                            @if($booking->booking_status == 'pending')
                                                <span class="badge bg-warning">{{translate('pending')}}</span>
                                            @elseif($booking->booking_status == 'accepted')
                                                <span class="badge bg-info">{{translate('accepted')}}</span>
                                            @elseif($booking->booking_status == 'ongoing')
                                                <span class="badge bg-primary">{{translate('ongoing')}}</span>
                                            @elseif($booking->booking_status == 'completed')
                                                <span class="badge bg-success">{{translate('completed')}}</span>
                                            @elseif($booking->booking_status == 'canceled')
                                                <span class="badge bg-danger">{{translate('canceled')}}</span>
                                            @endif
                                        </td>
                                        <td>{{ date('d M, Y', strtotime($booking->created_at)) }}</td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="5" class="text-center text-muted py-4">
                                            {{translate('no_bookings_found')}}
                                        </td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-4 mb-4">
            <div class="card h-100">
                <div class="card-header">
                    <h5 class="mb-0">{{translate('provider_info')}}</h5>
                </div>
                <div class="card-body">
                    @if(isset($provider))
                        <div class="d-flex align-items-center gap-3 mb-3">
                            <img src="{{ $provider->logo_full_path }}" class="rounded-circle" width="60" height="60" alt="">
                            <div>
                                <h6 class="mb-0">{{ $provider->company_name }}</h6>
                                <small class="text-muted">{{ $provider->company_email }}</small>
                            </div>
                        </div>
                        <div class="d-flex flex-column gap-2">
                            <div class="d-flex align-items-center gap-2">
                                <span class="material-icons text-muted" style="font-size:18px">phone</span>
                                <span>{{ $provider->company_phone ?? '-' }}</span>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <span class="material-icons text-muted" style="font-size:18px">location_on</span>
                                <span>{{ $provider->company_address ?? '-' }}</span>
                            </div>
                        </div>
                    @else
                        <p class="text-muted text-center">{{translate('no_provider_assigned')}}</p>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
