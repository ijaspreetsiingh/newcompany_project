@extends('adminmodule::layouts.master')

@section('title', translate('provider_dashboard'))

@section('content')
    <div class="main-content">
        <div class="container-fluid">

            <div class="page-title-wrap mb-3 d-flex align-items-center flex-wrap gap-2 justify-content-between">
                <h2 class="page-title mb-0">{{ translate('Provider Dashboard') }}</h2>
                <a href="{{ route('admin.provider.list') }}" class="btn btn--secondary btn-sm">
                    <span class="material-icons align-middle">arrow_back</span> {{ translate('Back to List') }}
                </a>
            </div>

            {{-- Provider header --}}
            <div class="card mb-20">
                <div class="card-body p-20">
                    <div class="d-flex align-items-start flex-wrap gap-3">
                        <div class="avatar avatar-xl">
                            <img class="avatar-img radius-5" src="{{ $provider->logo_full_path }}" alt="{{ $provider->company_name }}">
                        </div>
                        <div class="flex-grow-1">
                            <h3 class="mb-1">{{ $provider->company_name }}</h3>
                            <div class="fs-12 text-muted mb-2">
                                {{ $provider->contact_person_name ?? '-' }} · {{ $provider->contact_person_phone ?? '-' }} · {{ $provider->company_email ?? '-' }}
                            </div>
                            <div class="d-flex flex-wrap gap-2">
                                @if($provider->is_approved == 1)
                                    <span class="badge badge-pill badge-success">{{ translate('Approved') }}</span>
                                @else
                                    <span class="badge badge-pill badge-warning">{{ translate('Pending Approval') }}</span>
                                @endif
                                @if($provider->user?->is_active == 1)
                                    <span class="badge badge-pill badge-success">{{ translate('Active') }}</span>
                                @else
                                    <span class="badge badge-pill badge-danger">{{ translate('Inactive') }}</span>
                                @endif
                                <span class="badge badge-pill badge-primary">{{ $provider->zone?->name ?? '-' }}</span>
                                @if($provider->assignedMainCategory)
                                    <span class="badge badge-pill badge-info">{{ $provider->assignedMainCategory->name ?? '-' }}</span>
                                @endif
                            </div>
                        </div>
                        <div class="text-end">
                            <div class="fs-12 text-muted">{{ translate('Total Earning') }}</div>
                            <h3 class="mb-0">{{ with_currency_symbol($totalEarning) }}</h3>
                            <div class="fs-12 text-muted mt-1">{{ translate('Admin Commission') }}: {{ $provider->admin_commission_percent }}% · {{ translate('Provider') }}: {{ $provider->provider_commission_percent }}%</div>
                        </div>
                    </div>

                    <div class="row g-3 mt-2">
                        <div class="col-sm-6 col-lg-3">
                            <div class="fs-12 text-muted">{{ translate('Address') }}</div>
                            <div>{{ $provider->company_address ?? '-' }}</div>
                        </div>
                        <div class="col-sm-6 col-lg-3">
                            <div class="fs-12 text-muted">{{ translate('Phone') }}</div>
                            <div>{{ $provider->company_phone ?? '-' }}</div>
                        </div>
                        <div class="col-sm-6 col-lg-3">
                            <div class="fs-12 text-muted">{{ translate('Owner') }}</div>
                            <div>{{ trim(($provider->owner?->first_name ?? '') . ' ' . ($provider->owner?->last_name ?? '')) ?: '-' }} ({{ $provider->owner?->email ?? '-' }})</div>
                        </div>
                        <div class="col-sm-6 col-lg-3">
                            <div class="fs-12 text-muted">{{ translate('Location') }}</div>
                            <div>{{ $provider->latitude ?? '-' }}, {{ $provider->longitude ?? '-' }}</div>
                        </div>
                    </div>
                </div>
            </div>

            {{-- Time period filter --}}
            <form method="GET" action="{{ route('admin.provider.dashboard', $provider->id) }}" class="card mb-20">
                <div class="card-body p-20 d-flex align-items-end flex-wrap gap-3">
                    <div>
                        <label class="form-label fw-semibold text-dark fs-12">{{ translate('From') }}</label>
                        <input type="date" name="from" value="{{ $from?->format('Y-m-d') }}" class="form-control">
                    </div>
                    <div>
                        <label class="form-label fw-semibold text-dark fs-12">{{ translate('To') }}</label>
                        <input type="date" name="to" value="{{ $to?->format('Y-m-d') }}" class="form-control">
                    </div>
                    <button type="submit" class="btn btn--primary btn-sm">{{ translate('Apply') }}</button>
                    <a href="{{ route('admin.provider.dashboard', $provider->id) }}" class="btn btn--secondary btn-sm">{{ translate('Reset') }}</a>
                    <span class="fs-12 text-muted ms-auto">
                        {{ $from ? $from->format('d M Y') : translate('All time') }} — {{ $to ? $to->format('d M Y') : translate('Now') }}
                    </span>
                </div>
            </form>

            {{-- Period stats --}}
            <div class="row g-3 mb-20">
                <div class="col-sm-6 col-xl-3">
                    <div class="p-3 rounded border">
                        <div class="fs-12 text-muted">{{ translate('Total Bookings') }} ({{ translate('period') }})</div>
                        <h3 class="mb-0">{{ $periodStatuses->sum() }}</h3>
                        <div class="fs-12 text-muted">{{ translate('All time') }}: {{ $allStatuses->sum() }}</div>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="p-3 rounded border bg-success bg-opacity-10">
                        <div class="fs-12 text-muted">{{ translate('Completed') }}</div>
                        <h3 class="mb-0 text-success">{{ $periodStatuses['completed'] ?? 0 }}</h3>
                        <div class="fs-12 text-muted">{{ translate('All time') }}: {{ $allStatuses['completed'] ?? 0 }}</div>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="p-3 rounded border bg-warning bg-opacity-10">
                        <div class="fs-12 text-muted">{{ translate('Pending / Accepted') }}</div>
                        <h3 class="mb-0 text-warning">{{ ($periodStatuses['pending'] ?? 0) + ($periodStatuses['accepted'] ?? 0) }}</h3>
                        <div class="fs-12 text-muted">{{ translate('All time') }}: {{ ($allStatuses['pending'] ?? 0) + ($allStatuses['accepted'] ?? 0) }}</div>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="p-3 rounded border bg-info bg-opacity-10">
                        <div class="fs-12 text-muted">{{ translate('Ongoing') }}</div>
                        <h3 class="mb-0 text-info">{{ $periodStatuses['ongoing'] ?? 0 }}</h3>
                        <div class="fs-12 text-muted">{{ translate('All time') }}: {{ $allStatuses['ongoing'] ?? 0 }}</div>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="p-3 rounded border bg-danger bg-opacity-10">
                        <div class="fs-12 text-muted">{{ translate('Canceled') }}</div>
                        <h3 class="mb-0 text-danger">{{ $periodStatuses['canceled'] ?? 0 }}</h3>
                        <div class="fs-12 text-muted">{{ translate('All time') }}: {{ $allStatuses['canceled'] ?? 0 }}</div>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="p-3 rounded border">
                        <div class="fs-12 text-muted">{{ translate('Period Earning') }} ({{ translate('completed') }})</div>
                        <h3 class="mb-0">{{ with_currency_symbol($periodEarning) }}</h3>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="p-3 rounded border">
                        <div class="fs-12 text-muted">{{ translate('Total Servicemen') }}</div>
                        <h3 class="mb-0">{{ $servicemen->count() }}
                            <span class="fs-12 text-success">({{ $servicemen->filter(fn ($s) => $s->user?->is_active == 1)->count() }} {{ translate('Active') }})</span>
                        </h3>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="p-3 rounded border">
                        <div class="fs-12 text-muted">{{ translate('Categories') }}</div>
                        <h3 class="mb-0">{{ $provider->subscribed_services_count }}</h3>
                    </div>
                </div>
            </div>

            {{-- Categories --}}
            <div class="card mb-20">
                <div class="card-body p-20">
                    <h5 class="mb-3">{{ translate('Assigned Categories') }}</h5>
                    <div class="d-flex flex-wrap gap-2">
                        @forelse($categories as $cat)
                            <span class="badge badge-pill badge-primary">
                                {{ $cat->category?->name ?? '-' }} / {{ $cat->sub_category?->name ?? '-' }}
                            </span>
                        @empty
                            <span class="text-muted fs-12">{{ translate('No data available') }}</span>
                        @endforelse
                    </div>
                </div>
            </div>

            {{-- Serviceman cards --}}
            <div class="card mb-20">
                <div class="card-body p-20">
                    <h5 class="mb-3">{{ translate('Servicemen') }} ({{ $servicemen->count() }})</h5>
                    <div class="row g-3">
                        @forelse($servicemen as $serviceman)
                            @php
                                $sStats = $servicemanStats->get($serviceman->id);
                                $sTotal = $sStats ? $sStats->sum('total') : 0;
                                $sCompleted = $sStats->firstWhere('booking_status', 'completed')->total ?? 0;
                                $sOngoing = $sStats->firstWhere('booking_status', 'ongoing')->total ?? 0;
                                $sCanceled = $sStats->firstWhere('booking_status', 'canceled')->total ?? 0;
                            @endphp
                            <div class="col-sm-6 col-lg-4 col-xl-3">
                                <a href="{{ route('admin.provider.serviceman_dashboard', $serviceman->id) }}"
                                   class="text-decoration-none">
                                    <div class="p-3 rounded border h-100">
                                        <div class="d-flex align-items-center gap-2 mb-2">
                                            <div class="avatar">
                                                <img class="avatar-img radius-5" src="{{ $serviceman->user?->profile_image_full_path }}" alt="">
                                            </div>
                                            <div class="flex-grow-1">
                                                <h6 class="mb-0 text-dark">{{ trim(($serviceman->user?->first_name ?? '') . ' ' . ($serviceman->user?->last_name ?? '')) ?: '-' }}</h6>
                                                <span class="fs-12 text-muted">{{ $serviceman->user?->phone ?? '-' }}</span>
                                            </div>
                                            @if($serviceman->user?->is_active == 1)
                                                <span class="badge badge-pill badge-success">{{ translate('Active') }}</span>
                                            @else
                                                <span class="badge badge-pill badge-danger">{{ translate('Inactive') }}</span>
                                            @endif
                                        </div>
                                        <div class="d-flex justify-content-between fs-12">
                                            <span class="text-muted">{{ translate('Bookings') }}: <b class="text-dark">{{ $sTotal }}</b></span>
                                            <span class="text-success">{{ translate('Done') }}: {{ $sCompleted }}</span>
                                        </div>
                                        <div class="d-flex justify-content-between fs-12 mt-1">
                                            <span class="text-info">{{ translate('Ongoing') }}: {{ $sOngoing }}</span>
                                            <span class="text-danger">{{ translate('Canceled') }}: {{ $sCanceled }}</span>
                                        </div>
                                        <div class="mt-2 fs-12 text-primary">{{ translate('View Details') }} →</div>
                                    </div>
                                </a>
                            </div>
                        @empty
                            <div class="col-12 text-center text-muted py-4">{{ translate('No data available') }}</div>
                        @endforelse
                    </div>
                </div>
            </div>

            {{-- Recent bookings --}}
            <div class="card mb-20">
                <div class="card-body p-20">
                    <h5 class="mb-3">{{ translate('Recent Bookings') }}</h5>
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="text-nowrap">
                                <tr>
                                    <th>#</th>
                                    <th>{{ translate('Customer') }}</th>
                                    <th>{{ translate('Status') }}</th>
                                    <th>{{ translate('Amount') }}</th>
                                    <th>{{ translate('Assign') }}</th>
                                    <th>{{ translate('Date') }}</th>
                                </tr>
                            </thead>
                            <tbody>
                            @forelse($recentBookings as $key => $booking)
                                <tr>
                                    <td>{{ $key + 1 }}</td>
                                    <td>{{ trim(($booking->first_name ?? '') . ' ' . ($booking->last_name ?? '')) ?: '-' }}</td>
                                    <td><span class="badge badge-pill badge-{{ $booking->booking_status == 'completed' ? 'success' : ($booking->booking_status == 'canceled' ? 'danger' : ($booking->booking_status == 'ongoing' ? 'info' : 'warning')) }}">{{ $booking->booking_status }}</span></td>
                                    <td>{{ with_currency_symbol($booking->total_booking_amount) }}</td>
                                    <td>{{ $booking->auto_assigned ? translate('Auto') : translate('Manual') }}</td>
                                    <td>{{ $booking->created_at ? date('d M Y H:i', strtotime($booking->created_at)) : '-' }}</td>
                                </tr>
                            @empty
                                <tr><td colspan="6" class="text-center text-muted">{{ translate('No data available') }}</td></tr>
                            @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            {{-- Chats --}}
            <div class="card mb-20">
                <div class="card-body p-20">
                    <h5 class="mb-3">{{ translate('Chat History') }} ({{ translate('Customer / Serviceman with Provider team') }})</h5>
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="text-nowrap">
                                <tr>
                                    <th>#</th>
                                    <th>{{ translate('Participants') }}</th>
                                    <th>{{ translate('Last Message') }}</th>
                                    <th>{{ translate('Action') }}</th>
                                </tr>
                            </thead>
                            <tbody>
                            @forelse($channels as $key => $channel)
                                <tr>
                                    <td>{{ $key + 1 }}</td>
                                    <td>
                                        @foreach($channel->channelUsers as $cu)
                                            <span class="badge badge-pill badge-secondary">
                                                {{ trim(($cu->user?->first_name ?? '') . ' ' . ($cu->user?->last_name ?? '')) ?: '-' }}
                                                ({{ str_replace(['provider-admin', 'provider-serviceman', 'customer'], ['Provider', 'Serviceman', 'Customer'], $cu->user?->user_type ?? '') }})
                                            </span>
                                        @endforeach
                                    </td>
                                    <td class="text-muted">{{ \Illuminate\Support\Str::limit($channel->channelLastConversation?->message ?? '-', 60) }}</td>
                                    <td>
                                        <button type="button" class="btn btn--secondary btn-sm view-chat-btn"
                                                data-channel="{{ $channel->id }}"
                                                data-title="{{ implode(' · ', $channel->channelUsers->map(fn ($cu) => trim(($cu->user?->first_name ?? '') . ' ' . ($cu->user?->last_name ?? '')) ?: '-')->all()) }}">
                                            {{ translate('View Chat') }}
                                        </button>
                                    </td>
                                </tr>
                            @empty
                                <tr><td colspan="4" class="text-center text-muted">{{ translate('No data available') }}</td></tr>
                            @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            {{-- Calls --}}
            <div class="card mb-20">
                <div class="card-body p-20">
                    <h5 class="mb-3">{{ translate('Call History') }}</h5>
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="text-nowrap">
                                <tr>
                                    <th>#</th>
                                    <th>{{ translate('Caller') }}</th>
                                    <th>{{ translate('Callee') }}</th>
                                    <th>{{ translate('Type') }}</th>
                                    <th>{{ translate('Status') }}</th>
                                    <th>{{ translate('Duration') }}</th>
                                    <th>{{ translate('Date') }}</th>
                                </tr>
                            </thead>
                            <tbody>
                            @forelse($calls as $key => $call)
                                <tr>
                                    <td>{{ $key + 1 }}</td>
                                    <td>{{ trim(($call->caller?->first_name ?? '') . ' ' . ($call->caller?->last_name ?? '')) ?: '-' }}</td>
                                    <td>{{ trim(($call->callee?->first_name ?? '') . ' ' . ($call->callee?->last_name ?? '')) ?: '-' }}</td>
                                    <td>{{ $call->call_type }}</td>
                                    <td><span class="badge badge-pill badge-{{ $call->status == 'ended' ? 'success' : 'warning' }}">{{ $call->status }}</span></td>
                                    <td>{{ gmdate('i:s', $call->duration) }}</td>
                                    <td>{{ $call->created_at?->format('d M Y H:i') }}</td>
                                </tr>
                            @empty
                                <tr><td colspan="7" class="text-center text-muted">{{ translate('No data available') }}</td></tr>
                            @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div>
    </div>

    {{-- Chat viewer modal --}}
    <div class="modal fade" id="chatViewModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title" id="chatViewModalTitle">{{ translate('Chat') }}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="chatViewModalBody" style="min-height: 300px;">
                    <div class="text-center text-muted py-5">{{ translate('Loading') }}...</div>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn--secondary btn-sm" id="chatLoadMoreBtn" style="display:none;">{{ translate('Load More') }}</button>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('css_or_js')
    <style>
        #chatViewModalBody .chat-bubble { max-width: 75%; padding: 8px 12px; border-radius: 10px; margin-bottom: 8px; }
        #chatViewModalBody .chat-bubble.incoming { background: #f1f3f7; }
        #chatViewModalBody .chat-bubble.outgoing { background: #e7f1ff; margin-left: auto; }
        #chatViewModalBody .chat-meta { font-size: 10px; color: #888; margin-top: 2px; }
    </style>
    <script>
        (function () {
            let currentChannel = null;
            let currentOffset = 0;

            function loadConversation(channelId, offset, append) {
                const body = document.getElementById('chatViewModalBody');
                if (!append) body.innerHTML = '<div class="text-center text-muted py-5">Loading...</div>';
                fetch('{{ route("admin.chat.admin-conversation") }}?channel_id=' + channelId + '&offset=' + offset, {
                    headers: { 'X-Requested-With': 'XMLHttpRequest', 'Accept': 'application/json' }
                })
                    .then(r => r.json())
                    .then(res => {
                        if (!append) body.innerHTML = res.template || '<div class="text-center text-muted py-5">No messages</div>';
                        else body.insertAdjacentHTML('afterbegin', res.template || '');
                        document.getElementById('chatLoadMoreBtn').style.display = 'inline-block';
                    })
                    .catch(() => { body.innerHTML = '<div class="text-center text-muted py-5">Failed to load</div>'; });
            }

            document.addEventListener('click', function (e) {
                const btn = e.target.closest('.view-chat-btn');
                if (btn) {
                    currentChannel = btn.dataset.channel;
                    currentOffset = 0;
                    document.getElementById('chatViewModalTitle').textContent = btn.dataset.title || 'Chat';
                    loadConversation(currentChannel, 0, false);
                    new bootstrap.Modal(document.getElementById('chatViewModal')).show();
                }
            });

            document.getElementById('chatLoadMoreBtn').addEventListener('click', function () {
                currentOffset += 100;
                loadConversation(currentChannel, currentOffset, true);
            });
        })();
    </script>
@endpush
