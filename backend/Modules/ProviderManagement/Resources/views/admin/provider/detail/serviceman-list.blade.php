@extends('adminmodule::layouts.master')

@section('title',translate('provider_details'))

@section('content')
    <div class="main-content">
        <div class="container-fluid">
            <div class="page-title-wrap mb-3">
                <h2 class="page-title">{{translate('Provider_Details')}}</h2>
            </div>

            <div class="mb-3">
                <ul class="nav nav--tabs nav--tabs__style2">
                    <li class="nav-item">
                        <a class="nav-link {{$webPage=='overview'?'active':''}}"
                           href="{{url()->current()}}?web_page=overview">{{translate('Overview')}}</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{$webPage=='subscribed_services'?'active':''}}"
                           href="{{url()->current()}}?web_page=subscribed_services">{{translate('Subscribed_Services')}}</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{$webPage=='bookings'?'active':''}}"
                           href="{{url()->current()}}?web_page=bookings">{{translate('Bookings')}}</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{$webPage=='serviceman_list'?'active':''}}"
                           href="{{url()->current()}}?web_page=serviceman_list">{{translate('Service_Man_List')}}</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{$webPage=='settings'?'active':''}}"
                           href="{{url()->current()}}?web_page=settings">{{translate('Settings')}}</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{$webPage=='bank_information'?'active':''}}"
                           href="{{url()->current()}}?web_page=bank_information">{{translate('Bank_Information')}}</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{$webPage=='reviews'?'active':''}}"
                           href="{{url()->current()}}?web_page=reviews">{{translate('Reviews')}}</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{$webPage=='subscription'?'active':''}}"
                           href="{{url()->current()}}?web_page=subscription&provider_id={{ request()->id }}">{{translate('Business Plan')}}</a>
                    </li>
                </ul>
            </div>

            <div class="card">
                <div class="card-body p-30">
                    {{$servicemen->count() == 0 ? translate('Provider_has_no_serviceman_yet') : ''}}

                    @php
                        $totalRatingsTracked = $servicemanRatingStats->sum('total_ratings');
                        $totalReviewsTracked = $servicemanRatingStats->sum('total_reviews');
                        $avgRatingTracked = $totalRatingsTracked > 0
                            ? $servicemanRatingStats->sum(fn($stat) => ((float) $stat->avg_rating) * ((int) $stat->total_ratings)) / $totalRatingsTracked
                            : 0;
                    @endphp
                    <div class="d-flex flex-wrap gap-4 mb-3 pb-2 border-bottom">
                        <span class="title-color fw-medium">{{translate('Total_Servicemen')}}: {{$servicemen->total()}}</span>
                        <span class="title-color fw-medium">{{translate('ratings')}}: {{$totalRatingsTracked}}</span>
                        <span class="title-color fw-medium">{{translate('reviews')}}: {{$totalReviewsTracked}}</span>
                        <span class="title-color fw-medium">{{translate('Average_Rating')}}: {{number_format($avgRatingTracked, 1)}}/5</span>
                    </div>

                    <div class="service-man-list">
                        @foreach($servicemen as $serviceman)
                            @php($servicemanStat = $servicemanRatingStats->get($serviceman->id))
                            <div class="service-man-list__item">
                                <div class="service-man-list__item_header">
                                    <img src="{{$serviceman?->user->profile_image_full_path}}"
                                        alt="{{ translate('profile_image') }}">
                                    <h4 class="service-man-name">{{ Str::limit($serviceman->user ? $serviceman->user->first_name.' '.$serviceman->user->last_name:'', 30) }}</h4>
                                    <a class="service-man-phone"
                                       href="tel:+880372786552">{{$serviceman->user->phone}}</a>
                                </div>
                                <div class="service-man-list__item_body">
                                    <a class="service-man-mail"
                                       href="mailto:example@email.com">{{$serviceman->user->email}}</a>
                                    <p class="service-man-address">
                                    </p>
                                    <div class="d-flex align-items-center gap-3 mt-2">
                                        <span class="d-flex align-items-center gap-1 title-color fw-medium">
                                            <span class="material-icons" style="font-size:16px;color:#FFB900;">star</span>
                                            {{ $servicemanStat ? number_format((float) $servicemanStat->avg_rating, 1) : '0.0' }}/5
                                        </span>
                                        <span class="opacity-75">
                                            ({{ $servicemanStat->total_ratings ?? 0 }} {{translate('ratings')}},
                                             {{ $servicemanStat->total_reviews ?? 0 }} {{translate('reviews')}})
                                        </span>
                                    </div>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
