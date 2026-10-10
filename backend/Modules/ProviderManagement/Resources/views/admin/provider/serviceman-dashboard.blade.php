@extends('adminmodule::layouts.master')

@section('title', translate('serviceman_dashboard'))

@section('content')
    <div class="main-content">
        <div class="container-fluid">

            <div class="page-title-wrap mb-3 d-flex align-items-center flex-wrap gap-2 justify-content-between">
                <div class="d-flex align-items-center gap-2">
                    <a href="{{ route('admin.provider.dashboard', $serviceman->provider_id) }}"
                       class="action-btn btn--light-primary" style="--size: 34px" title="{{ translate('Back') }}">
                        <span class="material-icons">arrow_back</span>
                    </a>
                    <h2 class="page-title mb-0">{{ translate('Serviceman Dashboard') }}</h2>
                </div>
            </div>

            {{-- Serviceman header --}}
            <div class="card mb-20">
                <div class="card-body p-20">
                    <div class="d-flex align-items-center flex-wrap gap-3">
                        <div class="avatar avatar-xl">
                            <img class="avatar-img radius-5" src="{{ $serviceman->user?->profile_image_full_path }}" alt="">
                        </div>
                        <div class="flex-grow-1">
                            <h3 class="mb-1">{{ trim(($serviceman->user?->first_name ?? '') . ' ' . ($serviceman->user?->last_name ?? '')) ?: '-' }}</h3>
                            <div class="fs-12 text-muted mb-2">{{ $serviceman->user?->phone ?? '-' }} · {{ $serviceman->user?->email ?? '-' }}</div>
                            <div class="d-flex flex-wrap gap-2">
                                @if($serviceman->user?->is_active == 1)
                                    <span class="badge badge-pill badge-success">{{ translate('Active') }}</span>
                                @else
                                    <span class="badge badge-pill badge-danger">{{ translate('Inactive') }}</span>
                                @endif
                                <span class="badge badge-pill badge-primary">{{ translate('Provider') }}: {{ $serviceman->provider?->company_name ?? '-' }}</span>
                            </div>
                        </div>
                    </div>

                    {{-- Current / ongoing client --}}
                    <div class="mt-3">
                        <h5 class="mb-2">{{ translate('Currently Working For') }}</h5>
                        @if($currentBooking)
                            <div class="p-3 rounded border bg-info bg-opacity-10">
                                <div class="d-flex flex-wrap gap-3 align-items-center">
                                    <div>
                                        <div class="fs-12 text-muted">{{ translate('Client') }}</div>
                                        <h5 class="mb-0">{{ trim(($currentBooking->first_name ?? '') . ' ' . ($currentBooking->last_name ?? '')) ?: '-' }}</h5>
                                    </div>
                                    <div>
                                        <div class="fs-12 text-muted">{{ translate('Phone') }}</div>
                                        <div>{{ $currentBooking->phone ?? '-' }}</div>
                                    </div>
                                    <div>
                                        <div class="fs-12 text-muted">{{ translate('Status') }}</div>
                                        <span class="badge badge-pill badge-info">{{ $currentBooking->booking_status }}</span>
                                    </div>
                                    <div>
                                        <div class="fs-12 text-muted">{{ translate('Amount') }}</div>
                                        <div>{{ with_currency_symbol($currentBooking->total_booking_amount) }}</div>
                                    </div>
                                    <div>
                                        <div class="fs-12 text-muted">{{ translate('Started') }}</div>
                                        <div>{{ $currentBooking->created_at ? date('d M Y H:i', strtotime($currentBooking->created_at)) : '-' }}</div>
                                    </div>
                                </div>
                            </div>
                        @else
                            <div class="p-3 rounded border text-muted fs-12">{{ translate('No ongoing booking right now') }}</div>
                        @endif
                    </div>
                </div>
            </div>

            {{-- Time period filter --}}
            <form method="GET" action="{{ route('admin.provider.serviceman_dashboard', $serviceman->id) }}" class="card mb-20">
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
                    <a href="{{ route('admin.provider.serviceman_dashboard', $serviceman->id) }}" class="btn btn--secondary btn-sm">{{ translate('Reset') }}</a>
                    <span class="fs-12 text-muted ms-auto">
                        {{ $from ? $from->format('d M Y') : translate('All time') }} — {{ $to ? $to->format('d M Y') : translate('Now') }}
                    </span>
                </div>
            </form>

            {{-- Stats --}}
            <div class="row g-3 mb-20">
                <div class="col-sm-6 col-xl-3">
                    <div class="p-3 rounded border">
                        <div class="fs-12 text-muted">{{ translate('Total Bookings Assigned') }} ({{ translate('all time') }})</div>
                        <h3 class="mb-0">{{ $allStatuses->sum() }}</h3>
                        <div class="fs-12 text-muted">{{ translate('This period') }}: {{ $periodStatuses->sum() }}</div>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="p-3 rounded border bg-primary bg-opacity-10">
                        <div class="fs-12 text-muted">{{ translate('Assigned by Provider') }} ({{ translate('default') }})</div>
                        <h3 class="mb-0 text-primary">{{ $assignedByProvider }}</h3>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="p-3 rounded border bg-light bg-opacity-10">
                        <div class="fs-12 text-muted">{{ translate('Auto Assigned') }}</div>
                        <h3 class="mb-0">{{ $autoAssigned }}</h3>
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
                        <div class="fs-12 text-muted">{{ translate('Pending') }}</div>
                        <h3 class="mb-0 text-warning">{{ $periodStatuses['pending'] ?? 0 }}</h3>
                        <div class="fs-12 text-muted">{{ translate('All time') }}: {{ $allStatuses['pending'] ?? 0 }}</div>
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
                    <div class="p-3 rounded border bg-secondary bg-opacity-10">
                        <div class="fs-12 text-muted">{{ translate('On Hold') }}</div>
                        <h3 class="mb-0">{{ ($periodStatuses['pending'] ?? 0) + ($periodStatuses['accepted'] ?? 0) }}</h3>
                    </div>
                </div>
            </div>

            {{-- Bookings --}}
            <div class="card mb-20">
                <div class="card-body p-20">
                    <h5 class="mb-3">{{ translate('Bookings') }} ({{ translate('period') }})</h5>
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="text-nowrap">
                                <tr>
                                    <th>#</th>
                                    <th>{{ translate('Client') }}</th>
                                    <th>{{ translate('Phone') }}</th>
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
                                    <td>{{ $booking->phone ?? '-' }}</td>
                                    <td><span class="badge badge-pill badge-{{ $booking->booking_status == 'completed' ? 'success' : ($booking->booking_status == 'canceled' ? 'danger' : ($booking->booking_status == 'ongoing' ? 'info' : 'warning')) }}">{{ $booking->booking_status }}</span></td>
                                    <td>{{ with_currency_symbol($booking->total_booking_amount) }}</td>
                                    <td>
                                        @if($booking->auto_assigned)
                                            <span class="badge badge-pill badge-secondary">{{ translate('Auto') }}</span>
                                        @else
                                            <span class="badge badge-pill badge-primary">{{ translate('By Provider') }}</span>
                                        @endif
                                    </td>
                                    <td>{{ $booking->created_at ? date('d M Y H:i', strtotime($booking->created_at)) : '-' }}</td>
                                </tr>
                            @empty
                                <tr><td colspan="7" class="text-center text-muted">{{ translate('No data available') }}</td></tr>
                            @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            {{-- Chats --}}
            <div class="card mb-20">
                <div class="card-body p-20">
                    <h5 class="mb-3">{{ translate('Chat History') }} ({{ translate('Serviceman with Customer / Provider') }})</h5>
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
