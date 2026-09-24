<?php $user = auth()->user(); ?>
<aside class="aside">
    <div class="aside-header">
        <a href="{{route('serviceman.dashboard')}}" class="logo d-flex gap-2">
            <img src="{{asset('public/assets/serviceman-module/img/media/logo.png')}}" style="max-height: 50px" alt="{{translate('logo')}}" class="main-logo">
        </a>
        <button class="toggle-menu-button aside-toggle border-0 bg-transparent p-0 dark-color">
            <span class="material-icons">menu</span>
        </button>
    </div>
    <div class="aside-body" data-trigger="scrollbar">
        <div class="user-profile media gap-3 align-items-center my-3">
            <div class="avatar">
                <img class="avatar-img rounded-circle aspect-square object-fit-cover" src="{{ $user->profile_image_full_path }}" alt="{{translate('profile')}}">
            </div>
            <div class="media-body">
                <h5 class="card-title">{{ Str::limit($user->first_name.' '.$user->last_name, 30) }}</h5>
                <span class="card-text">{{ Str::limit($user->email, 30) }}</span>
            </div>
        </div>

        <ul class="nav">
            <li class="nav-category">{{translate('main')}}</li>
            <li>
                <a href="{{route('serviceman.dashboard')}}" class="{{request()->is('serviceman/dashboard')?'active-menu':''}}">
                    <span class="material-icons">dashboard</span>
                    <span class="link-title">{{translate('dashboard')}}</span>
                </a>
            </li>

            <li class="nav-category">{{translate('booking_management')}}</li>
            <li class="has-sub-item {{request()->is('serviceman/booking/*')?'sub-menu-opened':''}}">
                <a href="#" class="{{request()->is('serviceman/booking/*')?'active-menu':''}}">
                    <span class="material-icons">shopping_cart</span>
                    <span class="link-title">{{translate('bookings')}}</span>
                </a>
                <ul class="nav sub-menu">
                    <li>
                        <a href="{{route('serviceman.booking.list', ['status'=>'all'])}}" class="{{request()->query('status')=='all'?'active-menu':''}}">
                            <span class="link-title">{{translate('All_Bookings')}}</span>
                        </a>
                    </li>
                    <li>
                        <a href="{{route('serviceman.booking.list', ['status'=>'pending'])}}" class="{{request()->query('status')=='pending'?'active-menu':''}}">
                            <span class="link-title">{{translate('Pending')}}</span>
                        </a>
                    </li>
                    <li>
                        <a href="{{route('serviceman.booking.list', ['status'=>'ongoing'])}}" class="{{request()->query('status')=='ongoing'?'active-menu':''}}">
                            <span class="link-title">{{translate('Ongoing')}}</span>
                        </a>
                    </li>
                    <li>
                        <a href="{{route('serviceman.booking.list', ['status'=>'completed'])}}" class="{{request()->query('status')=='completed'?'active-menu':''}}">
                            <span class="link-title">{{translate('Completed')}}</span>
                        </a>
                    </li>
                    <li>
                        <a href="{{route('serviceman.booking.list', ['status'=>'canceled'])}}" class="{{request()->query('status')=='canceled'?'active-menu':''}}">
                            <span class="link-title">{{translate('Canceled')}}</span>
                        </a>
                    </li>
                </ul>
            </li>

            <li class="nav-category">{{translate('account')}}</li>
            <li>
                <a href="{{route('serviceman.profile.index')}}" class="{{request()->is('serviceman/profile*')?'active-menu':''}}">
                    <span class="material-icons">account_circle</span>
                    <span class="link-title">{{translate('My_Profile')}}</span>
                </a>
            </li>
        </ul>
    </div>
</aside>
