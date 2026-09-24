@extends('servicemanmodule::layouts.new-master')
@section('title', translate('My_Bookings'))

@section('content')
<div class="content container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="mb-0">{{translate('my_bookings')}}</h4>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="mb-4">
                <ul class="nav nav-pills gap-2">
                    <li class="nav-item">
                        <a class="nav-link {{ $status == 'all' ? 'active' : '' }}" href="{{route('serviceman.booking.list', ['status' => 'all'])}}">{{translate('all')}}</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{ $status == 'pending' ? 'active' : '' }} bg-warning" href="{{route('serviceman.booking.list', ['status' => 'pending'])}}">{{translate('pending')}}</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{ $status == 'ongoing' ? 'active' : '' }} bg-info" href="{{route('serviceman.booking.list', ['status' => 'ongoing'])}}">{{translate('ongoing')}}</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{ $status == 'completed' ? 'active' : '' }} bg-success" href="{{route('serviceman.booking.list', ['status' => 'completed'])}}">{{translate('completed')}}</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{ $status == 'canceled' ? 'active' : '' }} bg-danger" href="{{route('serviceman.booking.list', ['status' => 'canceled'])}}">{{translate('canceled')}}</a>
                    </li>
                </ul>
            </div>

            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>{{translate('booking_id')}}</th>
                            <th>{{translate('service')}}</th>
                            <th>{{translate('customer')}}</th>
                            <th>{{translate('amount')}}</th>
                            <th>{{translate('status')}}</th>
                            <th>{{translate('date')}}</th>
                            <th>{{translate('action')}}</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($bookings as $booking)
                            <tr>
                                <td>
                                    <a href="{{route('serviceman.booking.details', [$booking->id])}}" class="text-primary fw-medium">
                                        #{{ $booking->readable_id }}
                                    </a>
                                </td>
                                <td>{{ $booking->detail->first()?->service?->name ?? '-' }}</td>
                                <td>{{ $booking->customer?->first_name ?? '-' }}</td>
                                <td>{{ with_decimal_point($booking->total_order_amount ?? 0) }}</td>
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
                                <td>
                                    <a href="{{route('serviceman.booking.details', [$booking->id])}}" class="btn btn-sm btn-outline-primary">
                                        <span class="material-icons" style="font-size:16px">visibility</span>
                                    </a>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="7" class="text-center text-muted py-4">
                                    {{translate('no_bookings_found')}}
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <div class="d-flex justify-content-end">
                {{ $bookings->links() }}
            </div>
        </div>
    </div>
</div>
@endsection
