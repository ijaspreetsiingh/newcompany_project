<?php $user = auth()->user(); ?>
<header class="header">
    <div class="header-left">
        <div class="toggle-menu-button" data-trigger="sidebar">
            <span class="material-icons">menu</span>
        </div>
    </div>
    <div class="header-right">
        <div class="d-flex gap-3 align-items-center">
            <div class="dropdown">
                <a href="#" class="dropdown-toggle d-flex align-items-center" data-bs-toggle="dropdown">
                    <div class="avatar">
                        <img class="avatar-img rounded-circle" src="{{ $user->profile_image_full_path }}" alt="{{translate('profile')}}">
                    </div>
                    <span class="d-none d-lg-inline ms-2">{{ $user->first_name }}</span>
                </a>
                <ul class="dropdown-menu dropdown-menu-end">
                    <li><a class="dropdown-item" href="{{route('serviceman.profile.index')}}">
                        <span class="material-icons me-2">account_circle</span>{{translate('My_Profile')}}</a>
                    </li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item text-danger" href="{{route('serviceman.auth.logout')}}">
                        <span class="material-icons me-2">logout</span>{{translate('logout')}}</a>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</header>
