<div class="tab-pane fade" id="location-search">
    <div class="card">
        <div class="card-header">
            <h4 class="page-title">{{translate('Location_Search_Settings')}}</h4>
        </div>
        <div class="card-body p-30">
            <div class="alert alert-info mb-30">
                <p>
                    <i class="material-icons">info</i>
                    {{translate('Configure the radius search behavior for service discovery. These settings control how far users can search for services when none are found in their initial location.')}}
                </p>
            </div>
            <form action="{{route('admin.location-settings.update')}}" method="POST" id="location-search-form">
                @csrf
                @method('PUT')
                <div class="row">
                    <div class="col-md-6 col-12">
                        <div class="mb-30">
                            <div class="form-floating">
                                <input type="number" 
                                       class="form-control" 
                                       name="initial_radius"
                                       placeholder="{{translate('initial_search_radius')}}"
                                       step="0.5"
                                       min="1"
                                       max="100"
                                       required
                                       value="{{$locationSettings->initial_radius ?? 5}}">
                                <label>{{translate('initial_search_radius')}} (km) *</label>
                            </div>
                            <small class="text-muted">{{translate('Default search radius when no services found. E.g., 5 km')}}</small>
                        </div>
                    </div>

                    <div class="col-md-6 col-12">
                        <div class="mb-30">
                            <div class="form-floating">
                                <input type="number" 
                                       class="form-control" 
                                       name="max_radius"
                                       placeholder="{{translate('maximum_search_radius')}}"
                                       step="0.5"
                                       min="1"
                                       max="500"
                                       required
                                       value="{{$locationSettings->max_radius ?? 50}}">
                                <label>{{translate('maximum_search_radius')}} (km) *</label>
                            </div>
                            <small class="text-muted">{{translate('Maximum allowed search radius. E.g., 50 km')}}</small>
                        </div>
                    </div>

                    <div class="col-md-6 col-12">
                        <div class="mb-30">
                            <div class="form-floating">
                                <input type="number" 
                                       class="form-control" 
                                       name="radius_increment_step"
                                       placeholder="{{translate('radius_increment_step')}}"
                                       step="0.5"
                                       min="0.5"
                                       max="50"
                                       required
                                       value="{{$locationSettings->radius_increment_step ?? 5}}">
                                <label>{{translate('radius_increment_step')}} (km) *</label>
                            </div>
                            <small class="text-muted">{{translate('Each expansion increases radius by this amount. E.g., 5 km (5→10→15→20...)')}}</small>
                        </div>
                    </div>

                    <div class="col-md-6 col-12">
                        <div class="mb-30">
                            <div class="form-floating">
                                <input type="number" 
                                       class="form-control" 
                                       name="max_search_attempts"
                                       placeholder="{{translate('max_search_attempts')}}"
                                       min="1"
                                       max="20"
                                       required
                                       value="{{$locationSettings->max_search_attempts ?? 5}}">
                                <label>{{translate('max_search_attempts')}} *</label>
                            </div>
                            <small class="text-muted">{{translate('How many times user can expand search before final "not available" message')}}</small>
                        </div>
                    </div>

                    <div class="col-12">
                        <div class="mb-30">
                            <div class="form-check form-switch">
                                <input class="form-check-input" 
                                       type="checkbox" 
                                       name="show_popup_on_location_change"
                                       id="show_popup_check"
                                       {{($locationSettings->show_popup_on_location_change ?? 1) ? 'checked' : ''}}>
                                <label class="form-check-label" for="show_popup_check">
                                    {{translate('Show popup when services not found')}}
                                </label>
                            </div>
                            <small class="text-muted">{{translate('Enable/disable the "search with more radius" popup')}}</small>
                        </div>
                    </div>

                    <div class="col-12">
                        <div class="mb-30">
                            <div class="form-check form-switch">
                                <input class="form-check-input" 
                                       type="checkbox" 
                                       name="show_zone_reminder"
                                       id="zone_reminder_check"
                                       {{($locationSettings->show_zone_reminder ?? 1) ? 'checked' : ''}}>
                                <label class="form-check-label" for="zone_reminder_check">
                                    {{translate('Show zone reminder for new zones')}}
                                </label>
                            </div>
                            <small class="text-muted">{{translate('Show "fill house details" popup when user enters a new zone')}}</small>
                        </div>
                    </div>
                </div>

                <div class="alert alert-success mt-20">
                    <h6 class="mb-2">
                        <i class="material-icons">check_circle</i>
                        {{translate('Example Flow:')}}
                    </h6>
                    <ul class="mb-0 ps-3">
                        <li>{{translate('User in location → Search from 5 km (initial_radius)')}} </li>
                        <li>{{translate('No service found → Popup: "Expand to 10 km?"')}}</li>
                        <li>{{translate('Click "Search" → Radius becomes 10 km (5 + 5 step)')}}</li>
                        <li>{{translate('Still no service → Next attempt: 15 km (10 + 5)')}}</li>
                        <li>{{translate('Max 5 attempts reached → Final popup: "Not available"')}}</li>
                    </ul>
                </div>

                <div class="d-flex justify-content-end gap-2">
                    <button type="reset" class="btn btn--secondary">
                        {{translate('reset')}}
                    </button>
                    <button type="submit" class="btn btn--primary demo_check">
                        {{translate('update_settings')}}
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
