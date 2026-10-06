import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class EditProfileAccountInfo extends StatelessWidget {
  const EditProfileAccountInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: GetBuilder<UserController>(
          builder: (controller) {
            return Form(
              key: controller.passUpdateKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel(context, "phone_number".tr, requiredMark: true),
                  _readOnlyField(context, controller.userInfo.phone ?? ""),
                  const SizedBox(height: 20),
                  _fieldLabel(
                    context,
                    "new_password".tr,
                    requiredMark: true,
                  ),
                  CustomTextFormField(
                    isShowSuffixIcon: true,
                    isPassword: true,
                    controller: controller.passController,
                    hintText: "enter_new_password".tr,
                    isShowBorder: true,
                  ),
                  const SizedBox(height: 20),
                  _fieldLabel(
                    context,
                    "Confirm_New_Password".tr,
                    requiredMark: true,
                  ),
                  CustomTextFormField(
                    isShowSuffixIcon: true,
                    isPassword: true,
                    controller: controller.confirmPassController,
                    hintText: "enter_confirm_password".tr,
                    isShowBorder: true,
                  ),
                  const SizedBox(height: 20),
                  _saveButton(
                    context,
                    isLoading: controller.isLoading,
                    onPressed: () => _updatePassword(controller),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _fieldLabel(
    BuildContext context,
    String title, {
    bool requiredMark = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: title,
              style: robotoMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.kForeground,
              ),
            ),
            if (requiredMark)
              TextSpan(
                text: ' *',
                style: robotoMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.kDestructive,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _readOnlyField(BuildContext context, String text) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: context.kCard,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: context.kInputBorder, width: 1),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: robotoMedium.copyWith(
          fontSize: 14,
          color: context.kForeground,
        ),
      ),
    );
  }

  Widget _saveButton(
    BuildContext context, {
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.kPrimary,
          borderRadius: BorderRadius.circular(kRadiusMd),
        ),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.kPrimaryForeground,
          ),
        ),
      );
    }
    return KButton(label: 'save'.tr, height: 48, onTap: onPressed);
  }

  void _updatePassword(UserController controller) {
    if (controller.passController!.text.isEmpty) {
      showCustomSnackBar(
        'enter_new_password'.tr,
        type: ToasterMessageType.info,
      );
    } else if (controller.passController!.text.length < 8) {
      showCustomSnackBar('password_should_be'.tr);
    } else if (controller.confirmPassController!.text.isEmpty) {
      showCustomSnackBar(
        'enter_confirm_password'.tr,
        type: ToasterMessageType.info,
      );
    } else if (controller.passController!.text !=
        controller.confirmPassController!.text) {
      showCustomSnackBar('confirm_password_does_not_matched'.tr);
    } else {
      controller.updatePassword();
    }
  }
}
