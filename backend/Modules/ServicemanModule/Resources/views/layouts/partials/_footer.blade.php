<footer class="footer">
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-6">
                <span>{{translate('copyright')}} &copy; {{date('Y')}} {{translate('All Rights Reserved')}}</span>
            </div>
            <div class="col-md-6 text-end">
                <span>{{translate('Software_Version')}} : {{ env('SOFTWARE_VERSION') }}</span>
            </div>
        </div>
    </div>
</footer>
