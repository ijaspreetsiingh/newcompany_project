
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class EditServiceSheet extends StatefulWidget {
  final MyServiceItem service;

  const EditServiceSheet({super.key, required this.service});

  @override
  State<EditServiceSheet> createState() => _EditServiceSheetState();
}

class _EditServiceSheetState extends State<EditServiceSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _shortDescriptionController;
  late final List<TextEditingController> _priceControllers;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _shortDescriptionController = TextEditingController(
        text: widget.service.shortDescription ?? '');
    _priceControllers = widget.service.variants
        .map((v) => TextEditingController(
            text: v.price == v.price.roundToDouble()
                ? v.price.toStringAsFixed(0)
                : v.price.toString()))
        .toList();
  }

  @override
  void dispose() {
    _shortDescriptionController.dispose();
    for (final controller in _priceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked =
        await FileValidationHelper.validateAndPickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = picked);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, double> prices = {};
    for (int i = 0; i < widget.service.variants.length; i++) {
      final double? value =
          double.tryParse(_priceControllers[i].text.trim().isEmpty
              ? '0'
              : _priceControllers[i].text.trim());
      if (value == null) {
        showCustomSnackBar('price_must_be_a_number'.tr);
        return;
      }
      prices[widget.service.variants[i].variantKey] = value;
    }

    final bool success = await Get.find<MyServicesController>().updateService(
      serviceId: widget.service.id,
      prices: prices,
      shortDescription: _shortDescriptionController.text,
      image: _pickedImage,
    );

    if (success && mounted) {
      Get.back();
    }
  }

  void _discard() {
    showCustomDialog(
      child: ConfirmationDialog(
        title: 'discard_changes'.tr,
        description: 'discard_changes_message'.tr,
        yesButtonText: 'yes'.tr,
        noButtonText: 'no'.tr,
        onYesPressed: () async {
          Get.back();
          final bool success = await Get.find<MyServicesController>()
              .deleteService(widget.service.id);
          if (success && mounted) Get.back();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('edit_service'.tr,
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: InkColors.foreground)),
                          const SizedBox(height: 2),
                          Text(widget.service.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: InkColors.mutedForeground)),
                        ],
                      ),
                    ),
                    InkIconButton(
                      icon: Icons.close_rounded,
                      onTap: () => Get.back(),
                    ),
                  ],
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                TextFieldTitle(
                    title: 'service_image'.tr, requiredMark: false),

                InkWell(
                  onTap: _pickImage,
                  child: Row(
                    children: [
                      if (_pickedImage != null)
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                          child: Image.file(File(_pickedImage!.path),
                              height: 58, width: 58, fit: BoxFit.cover),
                        )
                      else
                        ServiceCover(image: widget.service.coverImage),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Text(
                          'change_image'.tr,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: InkColors.mutedForeground),
                        ),
                      ),
                      Icon(Icons.photo_camera_outlined,
                          size: 18, color: InkColors.mutedForeground),
                    ],
                  ),
                ),

                TextFieldTitle(title: 'short_description'.tr),
                CustomTextFormField(
                  controller: _shortDescriptionController,
                  hintText: 'short_description_hint'.tr,
                  maxLines: 3,
                  inputAction: TextInputAction.done,
                  capitalization: TextCapitalization.sentences,
                  maxLength: 1000,
                ),

                TextFieldTitle(
                    title: 'price'.tr,
                    subtitle:
                        widget.service.variants.length > 1 ? 'per_variant'.tr : null),

                for (int i = 0; i < widget.service.variants.length; i++) ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          widget.service.variants[i].variant,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: InkColors.foreground),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        flex: 3,
                        child: CustomTextFormField(
                          controller: _priceControllers[i],
                          hintText: '0',
                          inputType:
                              const TextInputType.numberWithOptions(decimal: true),
                          isShowBorder: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ],

                const SizedBox(height: Dimensions.paddingSizeSmall),

                GetBuilder<MyServicesController>(
                  builder: (controller) {
                    return Column(
                      children: [
                        CustomButton(
                          btnTxt: 'save_changes'.tr,
                          isLoading: controller.isSubmitting,
                          onPressed: controller.isSubmitting ? null : _save,
                        ),
                        if (widget.service.isEdited)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeSmall),
                            child: CustomButton(
                              btnTxt: 'discard_changes'.tr,
                              transparent: true,
                              textColor: InkColors.destructive,
                              onPressed:
                                  controller.isSubmitting ? null : _discard,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
