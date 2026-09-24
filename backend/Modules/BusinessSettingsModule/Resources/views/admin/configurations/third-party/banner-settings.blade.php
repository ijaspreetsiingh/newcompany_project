@if(isset($bannerSettings))
    <div class="card mb-15">
        <div class="p-20 border-bottom">
            <h4 class="page-title mb-1">
                {{translate('Home banner slider settings')}}
            </h4>
            <p class="fz-12">{{translate('Here you can manage the auto slide duration of the home screen banner slider')}}</p>
        </div>
        <div class="card-body p-20">
            <form action="{{route('admin.configuration.set-banner-settings')}}" method="POST">
                @csrf
                @method('PUT')
                <div class="row g-lg-4 g-3">
                    <div class="col-md-6 col-12">
                        <label class="mb-2 text-dark d-flex align-items-center gap-1">
                            {{translate('Banner auto slide duration (seconds)')}}
                            <i class="material-icons fz-14 text-light-gray" data-bs-toggle="tooltip"
                               data-bs-placement="top"
                               title="{{translate('Time in seconds after which the home banner slider will automatically move to the next banner. You can add any number of banners from the Promotions > Banner section, all of them will be shown in the slider.')}}"
                            >info</i>
                        </label>
                        <input type="number" class="form-control" min="1" max="60" step="1"
                               name="banner_auto_slide_duration"
                               placeholder="{{translate('Banner auto slide duration (seconds)')}} *"
                               required=""
                               value="{{ $bannerSettings['banner_auto_slide_duration'] ?? 5 }}">
                    </div>
                </div>
                @can('configuration_update')
                    <div class="d-flex justify-content-end gap-xl-3 gap-2 mt-20">
                        <button type="reset" class="btn btn--secondary rounded">{{translate('reset')}}</button>
                        <button type="submit" class="btn btn--primary demo_check rounded">{{translate('update')}}</button>
                    </div>
                @endcan
            </form>
        </div>
    </div>
@endif
