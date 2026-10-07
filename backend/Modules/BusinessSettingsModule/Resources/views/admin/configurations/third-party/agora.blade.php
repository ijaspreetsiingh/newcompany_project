@if($webPage == 'agora-config')
    <div class="tab-content">
        <form action="{{route('admin.configuration.store-third-party-data')}}"
              method="POST"
              class="third-party-data-form"
              enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <input type="hidden" name="party_name" value="agora">
            <div class="tab-pane fade show active">
                <div class="card">
                    <div class="card-body p-20">
                        <div class="d-flex flex-md-nowrap flex-wrap align-items-center justify-content-between gap-2 mb-20">
                            <div>
                                <h4 class="page-title mb-1">{{translate('Agora Voice & Video Calling')}}</h4>
                                <p class="fz-12">{{translate('Setup your Agora credentials to enable in-app voice & video calling between customers, service men and providers. Calls work only for providers allowed under Provider Edit > In-App Calling.')}}</p>
                                <p class="fz-12 mb-0">
                                    <a href="https://www.agora.io/en/pricing/" target="_blank" class="text-primary text-decoration-underline fw-medium" >{{ translate('Create a free Agora account') }}</a>
                                    <span class="text-muted">({{ translate('Create a project, copy its App ID and App Certificate (Secondary Certificate) and paste below.') }})</span>
                                </p>
                            </div>
                            <div class="d-flex justify-content-between align-items-center px-3 py-lg-3 py-2">
                                <label class="switcher ml-auto mb-0">
                                    <input type="checkbox" name="status" class="switcher_input" @checked($data['status'] ?? false)>
                                    <span class="switcher_control"></span>
                                </label>
                            </div>
                        </div>

                        <div class="discount-type body-bg rounded p-20 mb-20">
                            <div class="row g-4">
                                <div class="col-md-6 col-12">
                                    <div class="">
                                        <label class="mb-2 text-dark d-flex align-items-center gap-1">{{translate('App ID')}}
                                            <i class="material-icons fz-14 text-light-gray" data-bs-toggle="tooltip"
                                               data-bs-placement="top"
                                               title="{{translate('Agora project App ID')}}">info</i>
                                        </label>
                                        <input type="text" class="form-control"
                                               name="agora_app_id"
                                               placeholder="{{translate('Ex: 00000000000000000000000000000000000000000000')}} *"
                                               required=""
                                               value="{{ $data['agora_app_id'] ?? '' }}">
                                    </div>
                                </div>

                                <div class="col-md-6 col-12">
                                    <div class="">
                                        <label class="mb-2 text-dark d-flex align-items-center gap-1">{{translate('App Certificate')}}
                                            <i class="material-icons fz-14 text-light-gray" data-bs-toggle="tooltip"
                                               data-bs-placement="top"
                                               title="{{translate('Agora project App Certificate (Primary/Secondary certificate)')}}">info</i>
                                        </label>
                                        <input type="text" class="form-control"
                                               name="agora_app_certificate"
                                               placeholder="{{translate('Ex: 00000000000000000000000000000000000000000000')}} *"
                                               required=""
                                               autocomplete="off"
                                               value="{{ $data['agora_app_certificate'] ?? '' }}">
                                    </div>
                                </div>
                            </div>
                        </div>

                        @can('configuration_update')
                            <div class="d-flex justify-content-end gap-xl-3 gap-2">
                                <button type="reset" class="btn btn--secondary rounded">{{translate('reset')}}</button>
                                <button type="submit" class="btn btn--primary demo_check rounded">{{translate('Save')}}</button>
                            </div>
                        @endcan
                    </div>
                </div>
            </div>
        </form>
    </div>
@endif
