<hr class="my-4">

<!-- STEP: SELECT PROVIDERS (Dynamic based on Zone + Category/Service) -->
<div class="provider-selector mb-30">
    @isset($heading)
        <h5 class="mb-3">{{ $heading }}</h5>
    @endisset
    <p class="text-muted small">{{ translate('Leave empty to apply for all providers. Select providers from the filtered list below (or use Select All) to restrict this promotion to them.') }}</p>
    <label class="mb-2">{{ translate('Select Providers') }}</label>
    <select class="provider-select theme-input-style w-100" name="provider_ids[]"
            multiple="multiple" id="provider_selector__select"
            data-selected="{{ json_encode($selectedProviderIds ?? []) }}">
        <option value="all">{{ translate('Select All') }}</option>
    </select>
    <small class="text-muted d-block mt-2">{{ translate('Select zones and categories/services above first, matching providers will load here automatically') }}</small>
</div>

@push('script')
    <script>
        "use Strict";

        (function () {
            if (window.__providerCascadeInitialized) return;
            window.__providerCascadeInitialized = true;

            function escapeHtml(value) {
                return $('<div>').text(value == null ? '' : value).html();
            }

            function selectedProviderIds() {
                var $select = $('#provider_selector__select');
                if (!$select.length) return [];

                var vals = ($select.val() || []).filter(function (v) {
                    return v !== 'loading' && v !== '0' && v !== 'hint';
                });
                if (vals.length) return vals;

                var raw = $select.data('selected');
                if (typeof raw === 'string') {
                    try { raw = JSON.parse(raw); } catch (e) { raw = []; }
                }
                return Array.isArray(raw) ? raw : [];
            }

            function expandAllOption($select) {
                var selectedValues = $select.val();
                if (selectedValues !== null && selectedValues.includes('all')) {
                    $select.find('option').not(':disabled').prop('selected', 'selected');
                    $select.find('option[value="all"]').prop('selected', false);
                    $select.trigger('change');
                    return true;
                }
                return false;
            }

            // "Select All" expansion (provider select is rebuilt via AJAX → delegated)
            $(document).on('change', '#category_selector__select, #service_selector__select, #provider_selector__select', function () {
                expandAllOption($(this));
            });

            function renderProviders(providers, keep) {
                var $select = $('#provider_selector__select');
                if (!$select.length) return;

                keep = keep || [];

                if (providers === null) {
                    $select.html('<option value="loading" disabled>{{ translate("Loading providers...") }}</option>');
                    return;
                }

                var html = '<option value="all">{{ translate("Select All") }}</option>';
                if (providers.length > 0) {
                    providers.forEach(function (provider) {
                        var selectedAttr = keep.includes(provider.id) ? 'selected' : '';
                        var label = escapeHtml(provider.name);
                        if (provider.categories && provider.categories.length > 0) {
                            label += ' (' + escapeHtml(provider.categories.join(', ')) + ')';
                        }
                        html += '<option value="' + escapeHtml(provider.id) + '" ' + selectedAttr + '>' +
                            label + '</option>';
                    });
                } else {
                    html += '<option disabled>{{ translate("No providers found for selection") }}</option>';
                }

                $select.html(html);
                $select.removeAttr('data-selected');

                if ($.fn.select2 && $select.data('select2')) {
                    $select.trigger('change.select2');
                }
            }

            function renderProviderHint() {
                var $select = $('#provider_selector__select');
                if (!$select.length) return;

                $select.html('<option value="hint" disabled selected>{{ translate("Select zone & category/service first") }}</option>');
                $select.removeAttr('data-selected');

                if ($.fn.select2 && $select.data('select2')) {
                    $select.trigger('change.select2');
                }
            }

            var loadTimer = null;
            function loadProviders() {
                clearTimeout(loadTimer);
                loadTimer = setTimeout(function () {
                    var $select = $('#provider_selector__select');
                    if (!$select.length) return;

                    var keep = selectedProviderIds();
                    var discountType = $('input[name="discount_type"]:checked').val() || 'category';
                    var categoryIds = $('#category_selector__select').val() || [];
                    var serviceIds = $('#service_selector__select').val() || [];
                    var zoneIds = $('#zone_selector__select').val() || [];

                    if (zoneIds.length === 0 || (categoryIds.length === 0 && serviceIds.length === 0)) {
                        renderProviderHint();
                        return;
                    }

                    renderProviders(null, keep);

                    $.ajax({
                        url: '{{ $providerRoute }}',
                        type: 'POST',
                        data: {
                            _token: '{{ csrf_token() }}',
                            category_ids: categoryIds,
                            service_ids: serviceIds,
                            zone_ids: zoneIds,
                            discount_type: discountType
                        },
                        success: function (response) {
                            renderProviders((response && response.providers) ? response.providers : [], keep);
                        },
                        error: function () {
                            renderProviders([], keep);
                        }
                    });
                }, 120);
            }

            $('#category_selector__select, #service_selector__select, #zone_selector__select').on('change', loadProviders);
            $('input[name="discount_type"]').on('change', loadProviders);

            if ($.fn.select2) {
                $('.provider-select').select2({
                    placeholder: '{{ translate("Select Providers") }}'
                });
            }

            loadProviders();
        })();
    </script>
@endpush
