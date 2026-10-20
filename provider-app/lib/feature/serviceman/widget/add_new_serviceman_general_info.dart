import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class ServiceManGeneralInfo extends StatefulWidget {
  final bool isFromEditScreen;
  const ServiceManGeneralInfo({super.key, this.isFromEditScreen = false});

  @override
  State<ServiceManGeneralInfo> createState() => _ServiceManGeneralInfoState();
}

class _ServiceManGeneralInfoState extends State<ServiceManGeneralInfo> {
  final FocusNode _firstNameFocus  = FocusNode();
  final FocusNode _lastNameFocus   = FocusNode();
  final FocusNode _phoneFocus      = FocusNode();
  final FocusNode _identityFocus   = FocusNode();

  @override
  void initState() {
    super.initState();
    Get.find<ServicemanSetupController>().resetOtherValidationData();
    // Load provider's subscribed sub-categories for the picker
    Get.find<ServicemanSetupController>().loadSubscribedSubCategories();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GetBuilder<ServicemanSetupController>(
        builder: (ctrl) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Form(
              key: ctrl.addServiceManGeneralInfoValidation,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // ── Profile image ───────────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: Get.width),
                      if (ctrl.profileImage == '' && ctrl.pickedProfileImage == null)
                        DottedBorderBox(onTap: () => ctrl.pickProfileImage(false))
                      else if (ctrl.profileImage != '' && ctrl.pickedProfileImage == null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              CustomImage(height: 100, width: 100, image: ctrl.profileImage),
                              Container(
                                width: 35, height: 35,
                                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).disabledColor),
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                  onPressed: () => ctrl.pickProfileImage(false),
                                  icon: const Icon(Icons.edit, color: Colors.white, size: 17),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(ctrl.pickedProfileImage!.path),
                              fit: BoxFit.cover, height: 100, width: 100,
                            ),
                          ),
                          Positioned(
                            top: -10, right: -10,
                            child: IconButton(
                              onPressed: () => ctrl.pickProfileImage(true),
                              icon: const Icon(Icons.highlight_remove_rounded, color: Colors.red, size: 25),
                            ),
                          ),
                        ]),
                      if (!ctrl.isProfilePicValid)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text('fill_required_field'.tr,
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: Dimensions.fontSizeSmall)),
                        ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      SizedBox(
                        width: 300,
                        child: ImageValidationTextWidget(textAlign: TextAlign.center),
                      ),
                    ],
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // ── Name row ────────────────────────────────────────────
                  Row(children: [
                    Expanded(
                      child: CustomTextField(
                        inputType: TextInputType.text,
                        controller: ctrl.firstNameController,
                        focusNode: _firstNameFocus,
                        nextFocus: _lastNameFocus,
                        capitalization: TextCapitalization.words,
                        hintText: 'serviceman_first_name'.tr,
                        title: 'first_name'.tr,
                        maxLines: 1,
                        onValidate: (v) => FormValidationHelper().isValidFirstName(v ?? ''),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeLarge),
                    Expanded(
                      child: CustomTextField(
                        inputType: TextInputType.text,
                        focusNode: _lastNameFocus,
                        nextFocus: _phoneFocus,
                        controller: ctrl.lastNameController,
                        hintText: 'serviceman_last_name'.tr,
                        title: 'last_name'.tr,
                        capitalization: TextCapitalization.words,
                        maxLines: 1,
                        onValidate: (v) => FormValidationHelper().isValidLastName(v ?? ''),
                      ),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // ── Phone ───────────────────────────────────────────────
                  CustomTextField(
                    onCountryChanged: (cc) => ctrl.countryDialCode = cc.dialCode!,
                    countryDialCode: ctrl.countryDialCode,
                    hintText: 'serviceman_phone_number'.tr,
                    controller: ctrl.phoneController,
                    inputType: TextInputType.phone,
                    focusNode: _phoneFocus,
                    onValidate: (v) {
                      if (v == null || v.isEmpty) return 'phone_number_hint'.tr;
                      return FormValidationHelper()
                          .isValidPhone(ctrl.countryDialCode! + v);
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // ── Identity type ───────────────────────────────────────
                  TextFieldTitle(
                      title: 'serviceman_identity_type'.tr,
                      requiredMark: true,
                      isPadding: false),
                  Container(
                    width: Get.width, height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Theme.of(context).hintColor)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Theme.of(context).focusColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        elevation: 2,
                        hint: Text(
                          ctrl.selectedIdentityType == ''
                              ? 'select_serviceman_identity'.tr
                              : ctrl.selectedIdentityType.tr,
                          style: robotoRegular.copyWith(
                            color: ctrl.selectedIdentityType == ''
                                ? Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)
                                : Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: AppConstants.identityTypeList
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.tr),
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) ctrl.setValue(newValue);
                        },
                      ),
                    ),
                  ),
                  if (!ctrl.isIdentityTypeValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text('fill_required_field'.tr,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: Dimensions.fontSizeSmall)),
                    ),
                  const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                  // ── Identity number ─────────────────────────────────────
                  CustomTextField(
                    inputType: TextInputType.text,
                    hintText: 'serviceman_identity_number'.tr,
                    controller: ctrl.identityNumberController,
                    maxLines: 1,
                    focusNode: _identityFocus,
                    title: 'serviceman_identity'.tr,
                    onValidate: (v) =>
                        FormValidationHelper().isValidServicemanIdentityNumber(v),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // ── Identity images ─────────────────────────────────────
                  if (ctrl.identificationImage.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ctrl.identificationImage.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeExtraSmall),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          child: CustomImage(
                              height: 180, width: Get.width,
                              image: ctrl.identificationImage[i]),
                        ),
                      ),
                    ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ctrl.selectedIdentityImageList.length,
                    itemBuilder: (_, i) => PickedIdentityImage(index: i),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  if (ctrl.selectedIdentityImageList.length <
                      AppConstants.limitOfPickedIdentityImageNumber)
                    DottedBorderBox(
                      height: 100, width: Get.width,
                      onTap: () => ctrl.pickIdentityImage(false),
                    ),
                  if (!ctrl.isServicemanIdentityImageValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text('fill_required_field'.tr,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: Dimensions.fontSizeSmall)),
                    ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // ── Category assignment section ──────────────────────────
                  _CategoryAssignmentSection(ctrl: ctrl),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // ── Next / Save button ──────────────────────────────────
                  ctrl.isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                                color: Theme.of(context).hoverColor),
                          ],
                        )
                      : CustomButton(
                          fontSize: Dimensions.fontSizeDefault,
                          btnTxt: !widget.isFromEditScreen
                              ? 'next_btn'.tr
                              : 'save'.tr,
                          onPressed: () => _validate(ctrl),
                        ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _validate(ServicemanSetupController ctrl) {
    ctrl.checkOtherValidationField();
    if (ctrl.selectedSubCategoryIds.isEmpty) {
      showCustomSnackBar('serviceman_category_required_hint'.tr);
      return;
    }
    if (ctrl.addServiceManGeneralInfoValidation.currentState!.validate() &&
        ctrl.isIdentityTypeValid &&
        ctrl.isServicemanIdentityImageValid &&
        ctrl.isProfilePicValid) {
      final String numberWithCountryCode = ctrl.countryDialCode! +
          ValidationHelper.getValidPhone(
              '${ctrl.countryDialCode!}${ctrl.phoneController.value.text}');

      if (!widget.isFromEditScreen) {
        ctrl.controller!.index = 1;
        ctrl.updateTabControllerValue(ServicemanTabControllerState.accountIno);
      } else {
        final ServicemanBody body = ServicemanBody(
          firstName:      ctrl.firstNameController.text,
          lastName:       ctrl.lastNameController.text,
          email:          ctrl.emailController.text,
          phone:          numberWithCountryCode,
          identityNumber: ctrl.identityNumberController.text,
          identityType:   ctrl.selectedIdentityType,
          subCategoryIds: List.from(ctrl.selectedSubCategoryIds),
        );

        String servicemanId;
        if (ctrl.currentServicemanIndex != null) {
          servicemanId = ctrl
              .servicemanList![ctrl.currentServicemanIndex!].serviceman!.id!;
        } else {
          servicemanId =
              Get.find<ServicemanDetailsController>().servicemanModel!.id!;
        }
        ctrl.editServicemanInfoWithoutPassword(body, servicemanId);
      }
    }
  }
}

// ── Category assignment widget ─────────────────────────────────────────────

class _CategoryAssignmentSection extends StatelessWidget {
  final ServicemanSetupController ctrl;
  const _CategoryAssignmentSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(
            'assign_categories'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          const SizedBox(width: 6),
          Text('*', style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error)),
        ]),
        const SizedBox(height: 4),
        Text(
          'serviceman_category_required_hint'.tr,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        if (ctrl.isCategoryLoading)
          const Center(child: CircularProgressIndicator())
        else if (ctrl.subscribedSubCategories.isEmpty)
          Text(
            'no_subscribed_category'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ctrl.subscribedSubCategories.map((sub) {
              final String id      = sub.subCategoryId ?? '';
              final String label   = sub.displayLabel;   // "Home Cleaning → Deep Cleaning"
              final bool selected  = ctrl.selectedSubCategoryIds.contains(id);

              return GestureDetector(
                onTap: () => ctrl.toggleSubCategory(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (selected)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.check,
                            size: 14,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    Text(
                      label,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ]),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ── Identity image preview ─────────────────────────────────────────────────

class PickedIdentityImage extends StatelessWidget {
  final int index;
  const PickedIdentityImage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicemanSetupController>(builder: (ctrl) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: Dimensions.fontSizeExtraSmall),
        child: Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(ctrl.selectedIdentityImageList[index].file.path),
              fit: BoxFit.cover, height: 120, width: Get.width,
            ),
          ),
          Positioned(
            top: -10, right: -10,
            child: IconButton(
              onPressed: () => ctrl.pickIdentityImage(true, index: index),
              icon: const Icon(Icons.highlight_remove_rounded,
                  color: Colors.red, size: 25),
            ),
          ),
        ]),
      );
    });
  }
}
