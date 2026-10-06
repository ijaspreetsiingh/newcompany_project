import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/util/core_export.dart';

/// Checkout step 1 (Address & Schedule) ke "Continue" par slide-up sheet jo
/// HOME DETAILS (house, floor, street, pincode, contact) confirm/fill karwata
/// hai. Confirm karne par hi (addressModel copy me values set karke) result
/// wapas bhejta hai — caller in-memory selected address update + saved address
/// ke liye server save karta hai.
class HomeDetailsPopup extends StatefulWidget {
  const HomeDetailsPopup({super.key, required this.address});

  final AddressModel address;

  static Future<AddressModel?> show(
    BuildContext context, {
    required AddressModel address,
  }) {
    return showGeneralDialog<AddressModel>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierLabel: 'home_details'.tr,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, _) => PopScope(
        canPop: false,
        child: HomeDetailsPopup(address: address),
      ),
    );
  }

  @override
  State<HomeDetailsPopup> createState() => _HomeDetailsPopupState();
}

class _HomeDetailsPopupState extends State<HomeDetailsPopup>
    with SingleTickerProviderStateMixin {
  Color get _primary => NestInk.primary;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  late final TextEditingController _houseController;
  late final TextEditingController _floorController;
  late final TextEditingController _streetController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _contactNumberController;

  static String _prefill(String? value) =>
      (value == null || value == 'null') ? '' : value;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _slideController.forward();

    _houseController = TextEditingController(text: _prefill(widget.address.house));
    _floorController = TextEditingController(text: _prefill(widget.address.floor));
    _streetController = TextEditingController(text: _prefill(widget.address.street));
    _zipCodeController = TextEditingController(text: _prefill(widget.address.zipCode));
    _contactNameController =
        TextEditingController(text: _prefill(widget.address.contactPersonName));
    _contactNumberController =
        TextEditingController(text: _prefill(widget.address.contactPersonNumber));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _houseController.dispose();
    _floorController.dispose();
    _streetController.dispose();
    _zipCodeController.dispose();
    _contactNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  void _cancel() {
    Navigator.of(context).pop(null);
  }

  void _confirm() {
    final String contactName = _contactNameController.text.trim();
    final String contactNumber = _contactNumberController.text.trim();

    if (contactName.isEmpty ||
        contactName == 'null' ||
        contactNumber.isEmpty ||
        contactNumber == 'null') {
      customSnackBar(
        'please_input_contact_person_name_and_phone_number'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    widget.address.house = _houseController.text.trim();
    widget.address.floor = _floorController.text.trim();
    widget.address.street = _streetController.text.trim();
    widget.address.zipCode = _zipCodeController.text.trim();
    widget.address.contactPersonName = contactName;
    widget.address.contactPersonNumber = contactNumber;

    Navigator.of(context).pop(widget.address);
  }

  Widget _field({
    required String title,
    required String hintText,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    FocusNode? focusNode,
    FocusNode? nextFocus,
  }) {
    return CustomTextField(
      title: title,
      hintText: hintText,
      controller: controller,
      inputType: inputType,
      capitalization: capitalization,
      focusNode: focusNode,
      nextFocus: nextFocus,
      isrequired: false,
    );
  }

  Widget _buildModalSheet(double maxWidth) {
    final MediaQueryData media = MediaQuery.of(context);

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: NestInk.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          28,
          24,
          28 + media.padding.bottom + media.viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Drag handle
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: NestInk.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              /// Title + close
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'home_details'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: NestInk.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'home_details_subtitle'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            height: 1.4,
                            color: NestInk.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _cancel,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: NestInk.mutedText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              /// House + Floor
              Row(
                children: [
                  Expanded(
                    child: _field(
                      title: 'house'.tr,
                      hintText: 'enter_house_no'.tr,
                      controller: _houseController,
                      inputType: TextInputType.streetAddress,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: _field(
                      title: 'floor'.tr,
                      hintText: 'enter_floor_no'.tr,
                      controller: _floorController,
                      inputType: TextInputType.streetAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              /// Street + Zip
              Row(
                children: [
                  Expanded(
                    child: _field(
                      title: 'street'.tr,
                      hintText: 'enter_street'.tr,
                      controller: _streetController,
                      inputType: TextInputType.streetAddress,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: _field(
                      title: 'zip_code'.tr,
                      hintText: 'enter_zip_code'.tr,
                      controller: _zipCodeController,
                      inputType: TextInputType.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              /// Contact name
              _field(
                title: 'contact_person_name'.tr,
                hintText: 'contact_person_name'.tr,
                controller: _contactNameController,
                inputType: TextInputType.name,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              /// Contact number
              _field(
                title: 'contact_person_number'.tr,
                hintText: 'contact_person_number'.tr,
                controller: _contactNumberController,
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 22),

              /// Confirm button
              SizedBox(
                width: maxWidth,
                height: 46,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: NestInk.background,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'confirm'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: NestInk.background,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black.withValues(alpha: 0.2),
        width: double.infinity,
        height: double.infinity,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildModalSheet(screenWidth),
          ),
        ),
      ),
    );
  }
}
