
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _subCategoryId;
  XFile? _pickedImage;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescriptionController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked =
        await FileValidationHelper.validateAndPickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = picked);
    }
  }

  void _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    if (_subCategoryId == null) {
      showCustomSnackBar('select_sub_category'.tr);
      return;
    }
    if (_pickedImage == null) {
      showCustomSnackBar('service_image_is_required'.tr);
      return;
    }

    final double? price = double.tryParse(_priceController.text.trim());
    if (price == null) {
      showCustomSnackBar('price_must_be_a_number'.tr);
      return;
    }

    final bool success = await Get.find<MyServicesController>().createService(
      name: _nameController.text,
      subCategoryId: _subCategoryId!,
      shortDescription: _shortDescriptionController.text,
      description: _descriptionController.text,
      price: price,
      variantName: 'Standard',
      image: _pickedImage!,
    );

    if (success && mounted) Get.back();
  }

  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      appBar: CustomAppBar(
        title: 'create_service'.tr,
        centerTitle: true,
      ),
      body: GetBuilder<MyServicesController>(
        builder: (controller) {
          final List<AssignableSubCategory> options =
              controller.assignableSubCategories;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'create_service_message'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      height: 1.4,
                      color: InkColors.mutedForeground,
                    ),
                  ),

                  TextFieldTitle(title: 'service_name'.tr, requiredMark: true),
                  CustomTextFormField(
                    controller: _nameController,
                    hintText: 'service_name_hint'.tr,
                    capitalization: TextCapitalization.sentences,
                    onValidate: (value) =>
                        _required(value, 'service_name_is_required'.tr),
                  ),

                  TextFieldTitle(
                      title: 'sub_category'.tr, requiredMark: true),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: InkColors.card,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: InkColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _subCategoryId,
                        isExpanded: true,
                        hint: Text(
                          'select_sub_category'.tr,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: InkColors.mutedForeground),
                        ),
                        items: options
                            .map((option) => DropdownMenuItem<String>(
                                  value: option.id,
                                  child: Text(
                                    option.categoryName == null
                                        ? (option.name ?? '')
                                        : '${option.categoryName} / ${option.name ?? ''}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: InkColors.foreground),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _subCategoryId = value),
                      ),
                    ),
                  ),
                  if (_subCategoryId == null && _submitted)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeExtraSmall),
                      child: Text('select_sub_category'.tr,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).colorScheme.error)),
                    ),

                  TextFieldTitle(
                      title: 'short_description'.tr, requiredMark: true),
                  CustomTextFormField(
                    controller: _shortDescriptionController,
                    hintText: 'short_description_hint'.tr,
                    maxLines: 2,
                    capitalization: TextCapitalization.sentences,
                    maxLength: 1000,
                    onValidate: (value) => _required(
                        value, 'short_description_is_required'.tr),
                  ),

                  TextFieldTitle(
                      title: 'full_description'.tr, requiredMark: true),
                  CustomTextFormField(
                    controller: _descriptionController,
                    hintText: 'full_description_hint'.tr,
                    maxLines: 5,
                    inputType: TextInputType.multiline,
                    inputAction: TextInputAction.newline,
                    capitalization: TextCapitalization.sentences,
                    onValidate: (value) =>
                        _required(value, 'full_description_is_required'.tr),
                  ),

                  TextFieldTitle(title: 'price'.tr, requiredMark: true),
                  CustomTextFormField(
                    controller: _priceController,
                    hintText: '0',
                    inputType:
                        const TextInputType.numberWithOptions(decimal: true),
                    isShowBorder: true,
                    onValidate: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'price_is_required'.tr;
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'price_must_be_a_number'.tr;
                      }
                      return null;
                    },
                  ),

                  TextFieldTitle(
                      title: 'service_image'.tr, requiredMark: true),
                  InkWell(
                    onTap: _pickImage,
                    child: DottedBorderBox(
                      height: 110,
                      width: 110,
                      showErrorBorder:
                          _pickedImage == null && _submitted,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                        child: _pickedImage == null
                            ? const SizedBox()
                            : Image.file(
                                File(_pickedImage!.path),
                                height: 110,
                                width: 110,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  CustomButton(
                    btnTxt: 'submit_for_approval'.tr,
                    isLoading: controller.isSubmitting,
                    onPressed: controller.isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
