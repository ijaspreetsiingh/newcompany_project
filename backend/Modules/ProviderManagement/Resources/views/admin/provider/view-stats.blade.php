<div class="d-flex align-items-center gap-3 mb-4">
    <div class="avatar avatar-lg">
        <img class="avatar-img radius-5" src="{{$provider->logo_full_path}}" alt="{{$provider->company_name}}">
    </div>
    <div>
        <h4 class="mb-1">{{$provider->company_name}}</h4>
        <span class="fs-12 text-muted">{{$provider->contact_person_name}} · {{$provider->contact_person_phone}}</span>
    </div>
</div>

<div class="row g-3 mb-4">
    <div class="col-sm-6 col-xl-4">
        <div class="p-3 rounded border">
            <div class="fs-12 text-muted">{{translate('Total Bookings')}}</div>
            <h3 class="mb-0">{{$stats['total_bookings']}}</h3>
        </div>
    </div>
    <div class="col-sm-6 col-xl-4">
        <div class="p-3 rounded border">
            <div class="fs-12 text-muted">{{translate('Approved Bookings')}}</div>
            <h3 class="mb-0 text-success">{{$stats['completed']}}</h3>
        </div>
    </div>
    <div class="col-sm-6 col-xl-4">
        <div class="p-3 rounded border">
            <div class="fs-12 text-muted">{{translate('On Hold / Pending')}}</div>
            <h3 class="mb-0 text-warning">{{$stats['hold']}} <span class="fs-12 text-muted">(ongoing: {{$stats['ongoing']}})</span></h3>
        </div>
    </div>
    <div class="col-sm-6 col-xl-4">
        <div class="p-3 rounded border">
            <div class="fs-12 text-muted">{{translate('Total Earning')}}</div>
            <h3 class="mb-0">{{with_currency_symbol($stats['total_earning'])}}</h3>
        </div>
    </div>
    <div class="col-sm-6 col-xl-4">
        <div class="p-3 rounded border">
            <div class="fs-12 text-muted">{{translate('Assigned Sub Categories')}}</div>
            <h3 class="mb-0">{{$stats['sub_categories']}}</h3>
        </div>
    </div>
    <div class="col-sm-6 col-xl-4">
        <div class="p-3 rounded border">
            <div class="fs-12 text-muted">{{translate('Serviceman')}}</div>
            <h3 class="mb-0">{{$stats['serviceman_total']}} <span class="fs-12 text-success">({{$stats['serviceman_active']}} {{translate('Active')}})</span></h3>
        </div>
    </div>
</div>

<h5 class="mb-3">{{translate('Current Month')}} ({{now()->format('M Y')}})</h5>
<div class="row g-3 mb-4">
    <div class="col-sm-4">
        <div class="p-3 rounded border bg-success bg-opacity-10">
            <div class="fs-12 text-muted">{{translate('Booking Completed')}}</div>
            <h4 class="mb-0 text-success">{{$stats['month_completed']}}</h4>
        </div>
    </div>
    <div class="col-sm-4">
        <div class="p-3 rounded border bg-danger bg-opacity-10">
            <div class="fs-12 text-muted">{{translate('Booking Canceled')}}</div>
            <h4 class="mb-0 text-danger">{{$stats['month_canceled']}}</h4>
        </div>
    </div>
    <div class="col-sm-4">
        <div class="p-3 rounded border bg-warning bg-opacity-10">
            <div class="fs-12 text-muted">{{translate('On Hold')}}</div>
            <h4 class="mb-0 text-warning">{{$stats['month_hold']}}</h4>
        </div>
    </div>
    <div class="col-12">
        <div class="p-3 rounded border">
            <div class="fs-12 text-muted">{{translate('Month Earning (completed bookings)')}}</div>
            <h4 class="mb-0">{{with_currency_symbol($stats['month_earning'])}}</h4>
        </div>
    </div>
</div>

<h5 class="mb-3">{{translate('Serviceman Breakdown')}}</h5>
<div class="table-responsive">
    <table class="table align-middle">
        <thead class="text-nowrap">
            <tr>
                <th>#</th>
                <th>{{translate('Name')}}</th>
                <th>{{translate('Phone')}}</th>
                <th>{{translate('Status')}}</th>
            </tr>
        </thead>
        <tbody>
        @forelse($servicemen as $key => $serviceman)
            <tr>
                <td>{{$key+1}}</td>
                <td>{{trim(($serviceman->user?->first_name ?? '').' '.($serviceman->user?->last_name ?? '')) ?: '-'}}</td>
                <td>{{$serviceman->user?->phone ?? '-'}}</td>
                <td>
                    @if($serviceman->user?->is_active == 1)
                        <span class="badge badge-pill badge-success">{{translate('Active')}}</span>
                    @else
                        <span class="badge badge-pill badge-danger">{{translate('Inactive')}}</span>
                    @endif
                </td>
            </tr>
        @empty
            <tr>
                <td colspan="4" class="text-center text-muted">{{translate('No data available')}}</td>
            </tr>
        @endforelse
        </tbody>
    </table>
</div>
