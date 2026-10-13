import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';

/// SPEC: serviceman on-site customer ki extra chije add karta hai —
///  1) EXISTING SERVICE: provider ki subscribed categories ki services select
///     karo (external) — price prefill hoti hai (edit bhi kar sakte ho)
///  2) MANUAL: custom name + custom price (custom)
/// Total bill update hota hai.
class ExtraWorkSection extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool isSubBooking;
  const ExtraWorkSection({super.key, required this.bookingDetails, required this.isSubBooking});

  bool get _canEdit =>
      (bookingDetails.bookingStatus == 'accepted' || bookingDetails.bookingStatus == 'ongoing');

  @override
  Widget build(BuildContext context) {
    final List<ExtraService> extras = bookingDetails.extraServices ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.kCard,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: context.kBorder, width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: [
          Icon(Icons.construction_rounded, size: 18, color: context.kForeground),
          const SizedBox(width: 8),
          Expanded(
            child: Text('extra_work_list'.tr,
              style: robotoBold.copyWith(fontSize: 14, color: context.kForeground),
            ),
          ),
          if (_canEdit)
            InkWell(
              onTap: () => _showAddSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: context.kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kRadiusSm),
                ),
                child: Row(children: [
                  Icon(Icons.add, size: 14, color: context.kPrimary),
                  const SizedBox(width: 2),
                  Text('add'.tr, style: robotoMedium.copyWith(fontSize: 12, color: context.kPrimary)),
                ]),
              ),
            ),
        ]),

        const SizedBox(height: 4),
        Text('extra_work_hint'.tr,
          style: robotoRegular.copyWith(fontSize: 11, color: context.kMutedForeground),
        ),

        const SizedBox(height: 10),

        if (extras.isEmpty)
          Text('no_extra_work_added'.tr,
            style: robotoRegular.copyWith(fontSize: 12, color: context.kMutedForeground),
          )
        else
          ...extras.map((extra) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${extra.name ?? ''} ${extra.type == 'external' ? '(${'external'.tr})' : ''}',
                    style: robotoMedium.copyWith(fontSize: 13, color: context.kForeground),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  Text('${extra.quantity ?? 1} x ${PriceConverter.convertPrice(extra.price ?? 0)}',
                    style: robotoRegular.copyWith(fontSize: 11, color: context.kMutedForeground),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              Text(PriceConverter.convertPrice(((extra.price ?? 0) * (extra.quantity ?? 1))),
                style: robotoBold.copyWith(fontSize: 13, color: context.kForeground),
              ),
              if (_canEdit) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => Get.find<BookingDetailsController>().removeExtraService(
                    bookingId: bookingDetails.id.toString(),
                    extraServiceId: extra.id.toString(),
                    isSubBooking: isSubBooking,
                  ),
                  child: Icon(Icons.delete_outline, size: 18, color: context.kDestructive),
                ),
              ],
            ]),
          )),
      ]),
    );
  }

  void _showAddSheet(BuildContext context) {
    Get.bottomSheet(
      _ExtraWorkAddSheet(
        bookingId: bookingDetails.id.toString(),
        isSubBooking: isSubBooking,
      ),
      isScrollControlled: true,
    );
  }
}

class _ExtraWorkAddSheet extends StatefulWidget {
  final String bookingId;
  final bool isSubBooking;
  const _ExtraWorkAddSheet({required this.bookingId, required this.isSubBooking});

  @override
  State<_ExtraWorkAddSheet> createState() => _ExtraWorkAddSheetState();
}

class _ExtraWorkAddSheetState extends State<_ExtraWorkAddSheet> {
  bool _selectMode = true; // true = existing service, false = manual
  Map<String, dynamic>? _selectedService;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<BookingDetailsController>().loadProviderServices();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _pickService(Map<String, dynamic> service) {
    setState(() {
      _selectedService = service;
      _nameController.text = service['name']?.toString() ?? '';
      _priceController.text = ((service['price'] as num?) ?? 0).toStringAsFixed(2);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final BookingDetailsController controller = Get.find<BookingDetailsController>();

    final bool isSuccess = await controller.addExtraService(
      bookingId: widget.bookingId,
      name: _nameController.text.trim(),
      price: _priceController.text.trim(),
      quantity: _qtyController.text.trim(),
      type: _selectMode ? 'external' : 'custom',
      isSubBooking: widget.isSubBooking,
    );

    // Multiple extra works: sheet band mat karo — form clear karke turant
    // agla item add ho sakta hai (customer zyada kaam karvata hai to kaam aata
    // hai). Failure pe fields waise hi rehne do (retry).
    if (!isSuccess || !mounted) return;
    setState(() {
      _selectedService = null;
      _nameController.clear();
      _priceController.clear();
      _qtyController.text = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: context.kCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusLg)),
      ),
      child: GetBuilder<BookingDetailsController>(builder: (controller) {
        return Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('add_extra_work'.tr,
              style: robotoBold.copyWith(fontSize: 16, color: context.kForeground),
            ),
            const SizedBox(height: 4),
            Text('extra_work_hint'.tr,
              style: robotoRegular.copyWith(fontSize: 11, color: context.kMutedForeground),
            ),
            const SizedBox(height: 14),

            // ---- Mode toggle: Select Service | Manual ----
            Row(children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() { _selectMode = true; _selectedService = null; }),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectMode ? context.kPrimary.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(kRadiusSm),
                      border: Border.all(color: _selectMode ? context.kPrimary : context.kBorder),
                    ),
                    child: Text('select_existing_service'.tr,
                      style: robotoMedium.copyWith(fontSize: 12, color: _selectMode ? context.kPrimary : context.kMutedForeground),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() {
                    _selectMode = false;
                    _selectedService = null;
                    _nameController.clear();
                    _priceController.clear();
                  }),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !_selectMode ? context.kPrimary.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(kRadiusSm),
                      border: Border.all(color: !_selectMode ? context.kPrimary : context.kBorder),
                    ),
                    child: Text('manual_add'.tr,
                      style: robotoMedium.copyWith(fontSize: 12, color: !_selectMode ? context.kPrimary : context.kMutedForeground),
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 14),

            // ---- Existing service list (select mode) ----
            if (_selectMode) ...[
              if (controller.providerServicesLoading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (controller.providerServices.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('no_services_found'.tr,
                    style: robotoRegular.copyWith(fontSize: 12, color: context.kMutedForeground),
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.kBorder),
                    borderRadius: BorderRadius.circular(kRadiusSm),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.providerServices.length,
                    itemBuilder: (context, index) {
                      final service = controller.providerServices[index];
                      final bool isSelected = _selectedService?['id'] == service['id'];
                      return InkWell(
                        onTap: () => _pickService(service),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? context.kPrimary.withValues(alpha: 0.08) : Colors.transparent,
                            border: Border(bottom: BorderSide(color: context.kBorder, width: 0.5)),
                          ),
                          child: Row(children: [
                            Icon(
                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 18,
                              color: isSelected ? context.kPrimary : context.kMutedForeground,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(service['name']?.toString() ?? '',
                                style: robotoRegular.copyWith(fontSize: 13, color: context.kForeground),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(PriceConverter.convertPrice(((service['price'] as num?) ?? 0).toDouble()),
                              style: robotoMedium.copyWith(fontSize: 12, color: context.kMutedForeground),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
            ],

            // ---- Name (service se prefill ya manual) ----
            TextFormField(
              controller: _nameController,
              readOnly: _selectMode && _selectedService != null,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: _selectMode ? 'select_service_hint'.tr : 'extra_service_name'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusMd)),
              ),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'field_is_required'.tr : null,
            ),
            const SizedBox(height: 12),

            // ---- Price + Qty ----
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'extra_service_price'.tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusMd)),
                  ),
                  validator: (value) => (value == null || double.tryParse(value) == null) ? 'field_is_required'.tr : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'extra_service_quantity'.tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusMd)),
                  ),
                  validator: (value) => (value == null || int.tryParse(value) == null || int.parse(value) < 1) ? 'field_is_required'.tr : null,
                ),
              ),
            ]),
            const SizedBox(height: 16),

            CustomButton(
              btnTxt: 'add'.tr,
              isLoading: controller.isUpdate,
              width: double.infinity,
              onPressed: _submit,
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('extra_work_added_hint'.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(fontSize: 11, color: context.kMutedForeground),
              ),
            ),
          ]),
        );
      }),
    );
  }
}
