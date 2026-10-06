@extends('adminmodule::layouts.master')

@section('title',translate('Provider Services'))

@section('content')
    <div class="main-content">
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <div class="page-title-wrap mb-3 d-flex justify-content-between">
                        <h2 class="page-title">{{translate('Provider Services')}}</h2>
                    </div>

                    <div class="d-flex flex-wrap justify-content-end align-items-center border-bottom mx-lg-4 mb-10 gap-3">
                        <div class="d-flex gap-2 fw-medium mb-1">
                            <span class="opacity-75">{{translate('Total')}}:</span>
                            <span class="title-color">{{$requests->total()}}</span>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-body pb-5">
                            <div class="d-flex flex-wrap gap-2 mb-4">
                                @foreach(['create'=>'New Services','update'=>'Service Updates'] as $key=>$label)
                                    <a href="{{url()->current()}}?tab={{$key}}&status={{$status}}&search={{$search??''}}"
                                       class="btn {{$tab==$key?'btn--primary':'btn--secondary'}}">
                                        {{translate($label)}}
                                        <span class="badge badge-pill {{$tab==$key?'bg-white text-primary':'bg-dark text-white'}} ms-2">{{$tabCounts[$key]}}</span>
                                    </a>
                                @endforeach
                            </div>

                            <div class="data-table-top d-flex flex-wrap gap-10 justify-content-between">
                                <div class="d-flex flex-wrap gap-2">
                                    @foreach(['pending'=>'Pending','approved'=>'Approved','denied'=>'Denied','all'=>'All'] as $key=>$label)
                                        <a href="{{url()->current()}}?tab={{$tab}}&status={{$key}}"
                                           class="btn {{$status==$key?'btn--primary':'btn--secondary'}}">
                                            {{translate($label)}}
                                        </a>
                                    @endforeach
                                </div>

                                <form action="{{url()->current()}}" class="search-form search-form_style-two" method="GET">
                                    <input type="hidden" name="tab" value="{{$tab}}">
                                    <input type="hidden" name="status" value="{{$status}}">
                                    <div class="input-group search-form__input_group">
                                        <span class="search-form__icon"><span class="material-icons">search</span></span>
                                        <input type="search" class="theme-input-style search-form__input"
                                               value="{{$search??''}}" name="search"
                                               placeholder="{{translate('search_by_service_name')}}">
                                    </div>
                                    <button type="submit" class="btn btn--primary">{{translate('search')}}</button>
                                </form>
                            </div>

                            <div class="table-responsive">
                                <table class="table align-middle">
                                    <thead class="text-nowrap">
                                        <tr>
                                            <th>{{translate('SL')}}</th>
                                            <th>{{translate('Service')}}</th>
                                            <th>{{translate('Provider')}}</th>
                                            <th>{{translate('Category')}}</th>
                                            <th>{{translate('Sub Category')}}</th>
                                            @if($tab == 'update')
                                                <th>{{translate('Before (approved)')}}</th>
                                            @endif
                                            <th>{{translate('Price')}}</th>
                                            <th>{{translate('Status')}}</th>
                                            <th>{{translate('Action')}}</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        @forelse($requests as $key => $item)
                                            @php
                                                $svc = $item->service;
                                                if (!$svc) { continue; }
                                                $prev = $item->previous_values ? (json_decode($item->previous_values, true) ?: []) : [];
                                                $prevPrices = $prev['prices'] ?? [];
                                                $currentPriceRows = ($svc->variations ?? collect())->where('zone_id', $svc->zone_id)->values();
                                            @endphp
                                            <tr>
                                                <td>{{$requests->firstItem()+$key}}</td>
                                                <td>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <img src="{{$svc->cover_image_full_path ?? asset('public/assets/admin-module/img/placeholder.png')}}"
                                                             alt="" width="40" height="40" class="rounded">
                                                        <div>
                                                            <div class="fw-medium">{{$svc->name ?? '-'}}</div>
                                                            <div class="fs-12 text-muted">{{\Illuminate\Support\Str::limit($svc->short_description ?? '', 60)}}</div>
                                                            <span class="badge badge-pill {{($item->request_type=='create')?'badge-info':'badge-primary'}} mt-1">
                                                                {{translate($item->request_type == 'create' ? 'New Service' : 'Service Update')}}
                                                            </span>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    @if($item->provider)
                                                        <a href="{{route('admin.provider.details',[$item->provider->id, 'web_page'=>'overview'])}}">
                                                            {{$item->provider->company_name}}
                                                        </a>
                                                    @endif
                                                </td>
                                                <td>{{translate($svc->category->name ?? 'Not available')}}</td>
                                                <td>{{translate($svc->subCategory->name ?? 'Not available')}}</td>
                                                @if($tab == 'update')
                                                    <td class="fs-12">
                                                        <div>{{translate('Short description')}}:
                                                            <b>{{\Illuminate\Support\Str::limit($prev['short_description'] ?? '-', 50)}}</b>
                                                        </div>
                                                        @foreach(($svc->variations ?? collect()) as $variation)
                                                            <div>
                                                                {{$variation->variant}}:
                                                                <b>{{isset($prevPrices[$variation->variant_key]) ? currency_symbol().number_format((float)$prevPrices[$variation->variant_key], 2) : '-'}}</b>
                                                                <span class="text-muted">-></span>
                                                                <b class="text-success">{{currency_symbol()}}{{number_format($variation->price, 2)}}</b>
                                                            </div>
                                                        @endforeach
                                                    </td>
                                                @endif
                                                <td>
                                                    @forelse($currentPriceRows as $variation)
                                                        <div class="fs-12">{{$variation->variant}}: <b>{{currency_symbol()}}{{number_format($variation->price, 2)}}</b></div>
                                                    @empty
                                                        <span class="text-muted">-</span>
                                                    @endforelse
                                                </td>
                                                <td>
                                                    @if($svc->approval_status == 'approved')
                                                        <span class="badge badge-pill badge-success">{{translate('Approved')}}</span>
                                                    @elseif($svc->approval_status == 'denied')
                                                        <span class="badge badge-pill badge-danger">{{translate('Denied')}}</span>
                                                    @else
                                                        <span class="badge badge-pill badge-warning">{{translate('Pending')}}</span>
                                                    @endif
                                                </td>
                                                <td>
                                                    <div class="table-actions d-flex gap-2">
                                                        @can('service_manage_status')
                                                            @if($item->status != 'approved')
                                                                <form action="{{route('admin.service.provider-service-update')}}" method="POST">
                                                                    @csrf
                                                                    <input type="hidden" name="service_id" value="{{$svc->id}}">
                                                                    <input type="hidden" name="status" value="approve">
                                                                    <button type="submit" class="btn btn--success btn-sm">{{translate('Approve')}}</button>
                                                                </form>
                                                            @endif
                                                            @if($item->status != 'denied')
                                                                <form action="{{route('admin.service.provider-service-update')}}" method="POST">
                                                                    @csrf
                                                                    <input type="hidden" name="service_id" value="{{$svc->id}}">
                                                                    <input type="hidden" name="status" value="deny">
                                                                    <button type="submit" class="btn btn--danger btn-sm">{{translate('Deny')}}</button>
                                                                </form>
                                                            @endif
                                                        @endcan
                                                    </div>
                                                </td>
                                            </tr>
                                        @empty
                                            <tr class="text-center">
                                                <td colspan="9">{{translate('No data available')}}</td>
                                            </tr>
                                        @endforelse
                                    </tbody>
                                </table>
                            </div>
                            <div class="d-flex justify-content-end">
                                {!! $requests->links() !!}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
