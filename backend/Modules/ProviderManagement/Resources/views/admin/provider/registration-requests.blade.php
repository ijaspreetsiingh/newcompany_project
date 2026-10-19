@extends('adminmodule::layouts.master')

@section('title',translate('Provider Registration Requests'))

@section('content')
    <div class="main-content">
        <div class="container-fluid">
            <div class="page-title-wrap mb-30">
                <h2 class="page-title">{{translate('Provider Registration Requests')}}</h2>
                <p class="mb-0 opacity-75 fz-12">
                    {{translate('Requests submitted from the landing page. Approve to create an active provider ID. Rule: in one zone, only the active provider of a category actually serves customers.')}}
                </p>
            </div>

            <div class="d-flex flex-wrap justify-content-between align-items-center border-bottom mx-lg-4 mb-10 gap-3">
                <ul class="nav nav--tabs">
                    <li class="nav-item">
                        <a class="nav-link {{$status=='all'?'active':''}}"
                           href="{{url()->current()}}?status=all">
                            {{translate('all')}} ({{$statusCounts['all']}})
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{$status=='pending'?'active':''}}"
                           href="{{url()->current()}}?status=pending">
                            {{translate('pending')}} ({{$statusCounts['pending']}})
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{$status=='approved'?'active':''}}"
                           href="{{url()->current()}}?status=approved">
                            {{translate('approved')}} ({{$statusCounts['approved']}})
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{$status=='approved_inactive'?'active':''}}"
                           href="{{url()->current()}}?status=approved_inactive">
                            {{translate('created inactive')}} ({{$statusCounts['approved_inactive']}})
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{$status=='accepted_existing'?'active':''}}"
                           href="{{url()->current()}}?status=accepted_existing">
                            {{translate('old provider activated')}} ({{$statusCounts['accepted_existing']}})
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{$status=='declined'?'active':''}}"
                           href="{{url()->current()}}?status=declined">
                            {{translate('declined')}} ({{$statusCounts['declined']}})
                        </a>
                    </li>
                </ul>

                <div class="d-flex gap-2 fw-medium">
                    <span class="opacity-75">{{translate('Total')}}:</span>
                    <span class="title-color">{{$requests->total()}}</span>
                </div>
            </div>

            <div class="tab-content">
                <div class="tab-pane fade show active">
                    <div class="card">
                        <div class="card-body">

                            @if($status != 'all')
                                <form action="{{url()->current()}}?status={{$status}}" method="POST" class="d-flex align-items-center gap-2 mb-3" style="max-width: 340px;">
                                    @csrf
                                    <input type="search" class="form-control" name="search" value="{{$search}}" placeholder="{{translate('search_here')}}">
                                    <button type="submit" class="btn btn--secondary btn-sm">
                                        <span class="material-icons fz-20">search</span>
                                    </button>
                                </form>
                            @endif

                            <div class="table-responsive">
                                <table class="table align-middle">
                                    <thead class="align-middle">
                                    <tr>
                                        <th>{{translate('Sl')}}</th>
                                        <th>{{translate('contact_person')}} / {{translate('business_name')}}</th>
                                        <th class="min-w-140">{{translate('account_details')}}</th>
                                        <th class="min-w-120">{{translate('zone')}}</th>
                                        <th class="min-w-140">{{translate('category_and_services')}}</th>
                                        <th class="min-w-100">{{translate('status')}}</th>
                                        <th class="min-w-100">{{translate('dateapplied') ?? translate('date')}}</th>
                                        <th>{{translate('action')}}</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    @forelse($requests as $key => $requestItem)
                                        <tr>
                                            <td>{{$key + $requests->firstItem()}}</td>
                                            <td>
                                                <div class="d-flex flex-column min-w-200">
                                                    <h5 class="mb-1">{{\Illuminate\Support\Str::limit($requestItem->contact_person_name, 25)}}</h5>
                                                    <span class="fz-12">{{\Illuminate\Support\Str::limit($requestItem->company_name, 30)}}</span>
                                                    <span class="fz-12">{{\Illuminate\Support\Str::limit($requestItem->contact_person_phone, 15)}}</span>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="d-flex flex-column">
                                                    <span class="fz-12">{{$requestItem->account_email}}</span>
                                                    <span class="fz-12">{{$requestItem->account_phone}}</span>
                                                </div>
                                            </td>
                                            <td>{{$requestItem->zone?->name ?? '-'}}</td>
                                            <td>
                                                <div class="d-flex flex-column">
                                                    <span>{{$requestItem->mainCategory?->name ?? '-'}}</span>
                                                    @if(is_array($requestItem->sub_category_ids) && count($requestItem->sub_category_ids) > 0)
                                                        <span class="fz-12 opacity-75">{{count($requestItem->sub_category_ids)}} {{translate('specific services')}}</span>
                                                    @else
                                                        <span class="fz-12 opacity-75">{{translate('complete category')}}</span>
                                                    @endif
                                                </div>
                                            </td>
                                            <td>
                                                <span class="badge
                                                    {{$requestItem->status == 'pending' ? 'badge-warning' : ''}}
                                                    {{$requestItem->status == 'approved' ? 'badge-success' : ''}}
                                                    {{$requestItem->status == 'approved_inactive' ? 'badge-secondary' : ''}}
                                                    {{$requestItem->status == 'accepted_existing' ? 'badge-info' : ''}}
                                                    {{$requestItem->status == 'declined' ? 'badge-danger' : ''}}">
                                                    {{\Illuminate\Support\Str::headline($requestItem->status)}}
                                                </span>
                                                @if($requestItem->createdProvider)
                                                    <div class="fz-12 opacity-75">
                                                        {{translate('Provider ID')}}:
                                                        <a href="{{route('admin.provider.details', [$requestItem->createdProvider->id, 'web_page' => 'overview'])}}">
                                                            {{\Illuminate\Support\Str::limit($requestItem->createdProvider->company_name, 20)}}
                                                        </a>
                                                        ({{$requestItem->createdProvider->is_active ? translate('active') : translate('inactive')}})
                                                    </div>
                                                @endif
                                            </td>
                                            <td>{{\Carbon\Carbon::parse($requestItem->created_at)->format('d M Y')}}</td>
                                            <td>
                                                @can('provider_add')
                                                    @if($requestItem->status == 'pending')
                                                        <button type="button" class="action-btn btn--light-primary"
                                                                style="--size: 30px"
                                                                title="{{translate('Review')}}"
                                                                data-bs-toggle="modal"
                                                                data-bs-target="#reviewRequestModal-{{$requestItem->id}}">
                                                            @if(!empty($conflictMap[$requestItem->id]))
                                                                <span class="material-icons text-warning">notification_important</span>
                                                            @else
                                                                <span class="material-icons">rule</span>
                                                            @endif
                                                        </button>
                                                    @else
                                                        <span class="material-icons opacity-50 fz-20" title="{{translate('Already processed')}}">check_circle</span>
                                                    @endif
                                                @endcan
                                            </td>
                                        </tr>
                                    @empty
                                        <tr>
                                            <td colspan="8" class="text-center py-5">{{translate('not_found')}}</td>
                                        </tr>
                                    @endforelse
                                    </tbody>
                                </table>
                            </div>

                        </div>
                        <div class="card-footer">
                            {{ $requests->links() }}
                        </div>
                    </div>
                </div>
            </div>

            {{-- ==================== Review modals (popup) ==================== --}}
            @foreach($requests->where('status', 'pending') as $requestItem)
                @php $conflicts = $conflictMap[$requestItem->id] ?? collect(); @endphp
                <div class="modal fade" id="reviewRequestModal-{{$requestItem->id}}" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">{{translate('Review Registration Request')}}</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">

                                {{-- request details --}}
                                <div class="border rounded p-3 mb-4">
                                    <h6 class="mb-3">{{translate('Request details')}}</h6>
                                    <div class="row g-2 fz-14">
                                        <div class="col-md-4"><span class="opacity-75">{{translate('name')}}:</span> {{$requestItem->contact_person_name}}</div>
                                        <div class="col-md-4"><span class="opacity-75">{{translate('phone')}}:</span> {{$requestItem->contact_person_phone}}</div>
                                        <div class="col-md-4"><span class="opacity-75">{{translate('email')}}:</span> {{$requestItem->contact_person_email}}</div>
                                        <div class="col-md-4"><span class="opacity-75">{{translate('business_name')}}:</span> {{$requestItem->company_name}}</div>
                                        <div class="col-md-4"><span class="opacity-75">{{translate('business_email')}}:</span> {{$requestItem->company_email}}</div>
                                        <div class="col-md-4"><span class="opacity-75">{{translate('business_phone')}}:</span> {{$requestItem->company_phone}}</div>
                                        <div class="col-md-12"><span class="opacity-75">{{translate('business_address')}}:</span> {{$requestItem->company_address}}</div>
                                        <div class="col-md-4"><span class="opacity-75">{{translate('login_email')}}:</span> {{$requestItem->account_email}}</div>
                                        <div class="col-md-4"><span class="opacity-75">{{translate('login_phone')}}:</span> {{$requestItem->account_phone}}</div>
                                        <div class="col-md-4"><span class="opacity-75">{{translate('identity_type')}}:</span> {{\Illuminate\Support\Str::headline($requestItem->identity_type)}} ({{$requestItem->identity_number}})</div>
                                        <div class="col-md-4"><span class="opacity-75">{{translate('zone')}}:</span> {{$requestItem->zone?->name}}</div>
                                        <div class="col-md-8"><span class="opacity-75">{{translate('category')}}:</span> {{$requestItem->mainCategory?->name}}
                                            @if(is_array($requestItem->sub_category_ids) && count($requestItem->sub_category_ids) > 0)
                                                ({{count($requestItem->sub_category_ids)}} {{translate('selected services')}})
                                            @else
                                                ({{translate('complete category')}})
                                            @endif
                                        </div>
                                    </div>
                                </div>

                                @if($conflicts->isNotEmpty())
                                    {{-- ========== Duplicate popup: same zone + same category me already provider ========== --}}
                                    <div class="alert alert-warning d-flex align-items-start gap-2" role="alert">
                                        <span class="material-icons">notification_important</span>
                                        <div>
                                            <strong>{{translate('Another provider already exists for this zone and category!')}}</strong>
                                            <div class="fz-12">
                                                {{translate('Only the provider with an active status is actually present in that zone. Choose:')}} <br>
                                                <strong>{{translate('Accept')}}</strong> = {{translate('activate the old provider instead of creating a new one;')}} <br>
                                                <strong>{{translate('Cancel')}}</strong> = {{translate('still create this new provider ID, but it will stay inactive.')}}
                                            </div>
                                        </div>
                                    </div>

                                    @foreach($conflicts as $conflictItem)
                                        @php $existingProvider = $conflictItem->provider; @endphp
                                        <div class="border rounded p-3 mb-3 bg-light">
                                            <div class="d-flex flex-wrap justify-content-between align-items-center gap-2">
                                                <div>
                                                    <h6 class="mb-1">
                                                        {{translate('Existing provider')}}:
                                                        <a href="{{route('admin.provider.details', [$existingProvider->id, 'web_page' => 'overview'])}}">
                                                            {{$existingProvider->company_name}}
                                                        </a>
                                                        @if($existingProvider->contact_person_name)
                                                            ({{$existingProvider->contact_person_name}})
                                                        @endif
                                                    </h6>
                                                    <span class="badge {{$existingProvider->is_active ? 'badge-success' : 'badge-danger'}}">
                                                        {{$existingProvider->is_active ? translate('active') : translate('inactive')}}
                                                    </span>
                                                    <span class="fz-12 opacity-75 ms-2">{{translate('zone')}}: {{$requestItem->zone?->name}}</span>
                                                </div>
                                                <div class="d-flex flex-wrap gap-4 text-center">
                                                    <div>
                                                        <h5 class="mb-0">{{$conflictItem->services_total}}</h5>
                                                        <span class="fz-12 opacity-75">{{translate('total services')}}</span>
                                                    </div>
                                                    <div>
                                                        <h5 class="mb-0">{{$conflictItem->subscribed_total}}</h5>
                                                        <span class="fz-12 opacity-75">{{translate('total subscribed categories')}}</span>
                                                    </div>
                                                    <div>
                                                        <h5 class="mb-0">{{$conflictItem->servicemen_total}}</h5>
                                                        <span class="fz-12 opacity-75">{{translate('total profiles (servicemen)')}}</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    @endforeach

                                    <div class="d-flex flex-wrap gap-2 mt-4">
                                        <form action="{{route('admin.provider.registration_requests.accept_existing', [$requestItem->id])}}" method="POST" class="d-inline">
                                            @csrf
                                            <button type="submit" class="btn btn--primary">
                                                <span class="material-icons fz-18">task_alt</span>
                                                {{translate('Accept (activate old provider)')}}
                                            </button>
                                        </form>
                                        <form action="{{route('admin.provider.registration_requests.approve_inactive', [$requestItem->id])}}" method="POST" class="d-inline">
                                            @csrf
                                            <button type="submit" class="btn btn--danger">
                                                <span class="material-icons fz-18">cancel</span>
                                                {{translate('Cancel (create new, inactive)')}}
                                            </button>
                                        </form>
                                        <form action="{{route('admin.provider.registration_requests.decline', [$requestItem->id])}}" method="POST" class="d-inline">
                                            @csrf
                                            <button type="submit" class="btn btn--secondary">
                                                <span class="material-icons fz-18">block</span>
                                                {{translate('decline')}}
                                            </button>
                                        </form>
                                    </div>
                                @else
                                    {{-- ========== No duplicate: simple approve / decline ========== --}}
                                    <div class="alert alert-info" role="alert">
                                        <span class="material-icons align-middle fz-20">verified</span>
                                        {{translate('No active provider exists in this zone for this category. Approving will create this provider ID as ACTIVE.')}}
                                    </div>

                                    <div class="d-flex flex-wrap gap-2 mt-4">
                                        <form action="{{route('admin.provider.registration_requests.approve', [$requestItem->id])}}" method="POST" class="d-inline">
                                            @csrf
                                            <button type="submit" class="btn btn--primary">
                                                <span class="material-icons fz-18">check_circle</span>
                                                {{translate('approve')}} &amp; {{translate('create (active)')}}
                                            </button>
                                        </form>
                                        <form action="{{route('admin.provider.registration_requests.decline', [$requestItem->id])}}" method="POST" class="d-inline">
                                            @csrf
                                            <button type="submit" class="btn btn--danger">
                                                <span class="material-icons fz-18">block</span>
                                                {{translate('decline')}}
                                            </button>
                                        </form>
                                    </div>
                                @endif

                            </div>
                        </div>
                    </div>
                </div>
            @endforeach

        </div>
    </div>
@endsection
