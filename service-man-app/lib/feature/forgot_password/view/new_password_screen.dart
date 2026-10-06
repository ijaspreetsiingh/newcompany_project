import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';


class NewPassScreen extends StatefulWidget {
  final String identity;
  final String identityType;
  final String otp;
  final int isFirebaseOtp;
  const NewPassScreen({super.key, required this.identity,required this.otp, required this.identityType, required this.isFirebaseOtp});

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  String _identity='';

  @override
  void initState() {
    super.initState();
    _identity = widget.identity;

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller){
      return AuthShell(
        title: "create_new_password".tr,
        subtitle: "new_password_subtitle".tr,
        onBack: () {
          if (Navigator.canPop(context)) {
            Get.back();
          } else {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
        },
        children: [
          TextFieldTitle(title: 'New_Password'.tr),
          CustomTextField(
            hintText: "********",
            controller: _newPasswordController,
            focusNode: _newPasswordFocus,
            nextFocus: _confirmPasswordFocus,
            inputType: TextInputType.visiblePassword,
            isPassword: true,
          ),

          TextFieldTitle(title: "Confirm_New_Password".tr),
          CustomTextField(
            hintText: "********",
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            inputAction: TextInputAction.done,
            inputType: TextInputType.visiblePassword,
            isPassword: true,
          ),

          KButton(
            label: (controller.isLoading ?? false) ? 'loading'.tr : "change_password_btn".tr,
            height: 48,
            onTap: (controller.isLoading ?? false)
                ? null
                : ()=> _resetPassword(
                _identity,widget.otp,_newPasswordController.text.trim(),_confirmPasswordController.text.trim()
            ),
          ),
        ],
      );
    });
  }
  void _resetPassword(String identity,String otp,String password,String conPassword){
    String password0 = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    if (password0.isEmpty) {
      showCustomSnackBar('enter_password'.tr, type: ToasterMessageType.info);
    }else if (password0.length < 8) {
      showCustomSnackBar('password_should_be'.tr);
    }else if(confirmPassword.isEmpty){
      showCustomSnackBar("enter_confirm_password".tr, type: ToasterMessageType.info);
    }else if(password0 != confirmPassword) {
      showCustomSnackBar('confirm_password_does_not_matched'.tr);
    }else {
      Get.find<AuthController>().resetPassword(identity,widget.identityType,otp,password,conPassword, widget.isFirebaseOtp);
    }
  }
}
