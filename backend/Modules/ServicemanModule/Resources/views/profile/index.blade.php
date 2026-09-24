@extends('servicemanmodule::layouts.new-master')
@section('title', translate('My_Profile'))

@section('content')
<div class="content container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="mb-0">{{translate('my_profile')}}</h4>
    </div>

    <div class="row">
        <div class="col-xl-4 mb-4">
            <div class="card">
                <div class="card-body text-center">
                    <img src="{{ $user->profile_image_full_path }}" class="rounded-circle mb-3" width="120" height="120" style="object-fit:cover;" alt="">
                    <h5>{{ $user->first_name }} {{ $user->last_name }}</h5>
                    <p class="text-muted mb-1">{{ $user->email }}</p>
                    <p class="text-muted">{{ $user->phone }}</p>
                    <span class="badge bg-primary">{{translate('serviceman')}}</span>
                </div>
            </div>
        </div>

        <div class="col-xl-8">
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">{{translate('update_profile')}}</h5>
                </div>
                <div class="card-body">
                    <form action="{{route('serviceman.profile.update')}}" method="POST" enctype="multipart/form-data">
                        @csrf
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">{{translate('first_name')}}</label>
                                <input type="text" name="first_name" class="form-control @error('first_name') is-invalid @enderror" value="{{ old('first_name', $user->first_name)}}" required>
                                @error('first_name') <div class="invalid-feedback">{{ $message }}</div> @enderror
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">{{translate('last_name')}}</label>
                                <input type="text" name="last_name" class="form-control @error('last_name') is-invalid @enderror" value="{{ old('last_name', $user->last_name)}}" required>
                                @error('last_name') <div class="invalid-feedback">{{ $message }}</div> @enderror
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">{{translate('email')}}</label>
                                <input type="email" name="email" class="form-control @error('email') is-invalid @enderror" value="{{ old('email', $user->email)}}" required>
                                @error('email') <div class="invalid-feedback">{{ $message }}</div> @enderror
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">{{translate('phone')}}</label>
                                <input type="text" class="form-control" value="{{ $user->phone }}" disabled>
                                <small class="text-muted">{{translate('phone_cannot_be_changed')}}</small>
                            </div>
                            <div class="col-md-12 mb-3">
                                <label class="form-label">{{translate('profile_image')}}</label>
                                <input type="file" name="profile_image" class="form-control" accept="image/*">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary">
                            <span class="material-icons me-1" style="font-size:18px">save</span> {{translate('save_changes')}}
                        </button>
                    </form>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">{{translate('change_password')}}</h5>
                </div>
                <div class="card-body">
                    <form action="{{route('serviceman.profile.change-password')}}" method="POST">
                        @csrf
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">{{translate('current_password')}}</label>
                                <input type="password" name="current_password" class="form-control @error('current_password') is-invalid @enderror" required>
                                @error('current_password') <div class="invalid-feedback">{{ $message }}</div> @enderror
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">{{translate('new_password')}}</label>
                                <input type="password" name="password" class="form-control @error('password') is-invalid @enderror" required>
                                @error('password') <div class="invalid-feedback">{{ $message }}</div> @enderror
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">{{translate('confirm_password')}}</label>
                                <input type="password" name="password_confirmation" class="form-control" required>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-warning">
                            <span class="material-icons me-1" style="font-size:18px">lock</span> {{translate('change_password')}}
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
