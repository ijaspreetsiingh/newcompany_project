import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key,});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}



class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _identityController = TextEditingController();
  final FocusNode _identityFocus = FocusNode();
  String countryDialCode = "";
  bool _isNumberLogin = false;
  String _forgetPasswordMethod = "both";

  @override
  void initState() {
    super.initState();

    countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel?.content?.countryCode?? "BD").dialCode?? "+880";
    var config = Get.find<SplashController>().configModel?.content;
    if(config?.forgetPasswordVerificationMethod?.phone == 1 && config?.forgetPasswordVerificationMethod?.email == 1){
      _forgetPasswordMethod = "both";
    }else if(config?.forgetPasswordVerificationMethod?.phone == 1){
      _forgetPasswordMethod = "phone";
    }else{
      _forgetPasswordMethod = "email";
    }
    toggleIsNumberLogin(value: false,isUpdate: false);

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return AuthShell(
        title: "forgot_password".tr,
        subtitle: "forgot_password_subtitle".tr,
        onBack: () {
          if (Navigator.canPop(context)) {
            Get.back();
          } else {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
        },
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.kMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 38,
                color: context.kMutedForeground,
              ),
            ),
          ),
          TextFieldTitle(
            title: _forgetPasswordMethod == "email"
                ? "email".tr
                : _forgetPasswordMethod == "phone"
                    ? "phone_number".tr
                    : 'email_or_phone'.tr,
          ),
          CustomTextField(
            onCountryChanged: (countryCode) => countryDialCode = countryCode.dialCode!,
            countryDialCode: (_forgetPasswordMethod != "email" && _isNumberLogin)  ? countryDialCode : null,
            hintText: _forgetPasswordMethod == "email" ? "enter_email_address".tr : _forgetPasswordMethod == "phone" ? 'ex : 1234567890'.tr : 'enter_email_address_or_phone_number'.tr,
            controller: _identityController,
            focusNode: _identityFocus,
            inputType: TextInputType.emailAddress,
            onChanged: (String text){
              final numberRegExp = RegExp(r'^-?[0-9]+$');

              if(text.isEmpty && _isNumberLogin){
                toggleIsNumberLogin();
              }
              if(text.startsWith(numberRegExp) && !_isNumberLogin ){
                toggleIsNumberLogin();
              }
              final emailRegExp = RegExp(r'@');
              if(text.contains(emailRegExp) && _isNumberLogin){
                toggleIsNumberLogin();
              }

            },
          ),
          KButton(
            label: (authController.isLoading ?? false) ? 'loading'.tr : "send_otp".tr,
            height: 48,
            onTap: (authController.isLoading ?? false)
                ? null
                : () {
                    _forgetPass(countryDialCode, authController);
                  },
          ),
        ],
      );
    });
  }

  void _forgetPass(String countryDialCode,AuthController authController) async {
    String phone = ValidationHelper.getValidPhone(countryDialCode + _identityController.text.trim(), withCountryCode: true);
    String identity = phone !="" ? phone : _identityController.text.trim();

    var config = Get.find<SplashController>().configModel?.content;
    SendOtpType  type = config?.firebaseOtpVerification == 1 && phone != "" ? SendOtpType.firebase : SendOtpType.forgetPassword;


    if (_identityController.text.isEmpty && _forgetPasswordMethod == "email") {
      showCustomSnackBar('enter_email_address'.tr, type: ToasterMessageType.info);
    } else if(_identityController.text.isNotEmpty && _forgetPasswordMethod == "email" && !GetUtils.isEmail(_identityController.text)){
      showCustomSnackBar('enter_valid_email_address'.tr, type: ToasterMessageType.info);
    }
    else if(_identityController.text.isEmpty && _forgetPasswordMethod == "phone"){
      showCustomSnackBar('phone_humber_hint'.tr, type: ToasterMessageType.info);
    }
    else if(_identityController.text.isNotEmpty && _forgetPasswordMethod == "phone" && phone == ""){
      showCustomSnackBar('invalid_phone_number'.tr);
    }
    else if((_identityController.text.isEmpty && _forgetPasswordMethod == "both") || (_identityController.text.isNotEmpty && _forgetPasswordMethod == "both" && !_isNumberLogin && !GetUtils.isEmail(_identityController.text))){
      showCustomSnackBar('enter_email_address_or_phone_number'.tr, type: ToasterMessageType.info);
    }
    else if(_identityController.text.isNotEmpty && _forgetPasswordMethod == "both" && _isNumberLogin && phone == ""){
      showCustomSnackBar('invalid_phone_number'.tr);
    }
    else {
      authController.sendVerificationCode(identity: identity,  identityType: phone !="" ? "phone" : "email", type: type).then((status){
        if(status != null){
          if(status.isSuccess!){
            Get.toNamed(RouteHelper.getVerificationRoute(
              identity: identity, identityType: phone !="" ? "phone" : "email",
              firebaseSession: type == SendOtpType.firebase ? status.message : null,
            ));
          }else{
            showCustomSnackBar(status.message.toString().capitalizeFirst ?? "" );
          }
        }
      });
      }
    }

  void toggleIsNumberLogin ({bool? value, bool isUpdate = true}){
    if(_forgetPasswordMethod == "both"){
      if(isUpdate){
        setState(() {
          if(value == null){
            _isNumberLogin = !_isNumberLogin;
          }else{
            _isNumberLogin = value;
          }
        });
      }else{
        if(value == null){
          _isNumberLogin = !_isNumberLogin;
        }else{
          _isNumberLogin = value;
        }
      }
    } else if(_forgetPasswordMethod == "phone"){
      _isNumberLogin= true;
    }
  }
}
