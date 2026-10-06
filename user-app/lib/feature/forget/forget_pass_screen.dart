import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';

class ForgetPassScreen extends StatefulWidget {
  final String? redtrectUrl;
  const ForgetPassScreen({super.key, this.redtrectUrl});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _identityController = TextEditingController();
  String countryDialCode = "";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode _identityFocus = FocusNode();
  bool _isNumberLogin = false;
  String _forgetPasswordMethod = "phone";

  @override
  void initState() {
    super.initState();
    countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel.content!.countryCode!).dialCode ?? "+880";
    var config = Get.find<SplashController>().configModel.content;
    if (config?.forgetPasswordVerificationMethod?.phone == 1 && config?.forgetPasswordVerificationMethod?.email == 1) {
      _forgetPasswordMethod = "both";
    } else if (config?.forgetPasswordVerificationMethod?.phone == 1) {
      _forgetPasswordMethod = "phone";
    } else {
      _forgetPasswordMethod = "email";
    }
    toggleIsNumberLogin(value: false, isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        backgroundColor: NestInk.background,
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
        endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        body: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: NestInk.primary,
              onPrimary: NestInk.background,
            ),
          ),
          child: GetBuilder<SplashController>(
            builder: (splashController) {
            return GetBuilder<AuthController>(
              builder: (authController) {
                return Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 10),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Get.back();
                          } else {
                            Get.toNamed(RouteHelper.getSignInRoute());
                          }
                        },
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: NestInk.primary, size: 20),
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),

                              Text(
                                "Forget Password",
                                style: robotoBold.copyWith(
                                  fontSize: 28,
                                  color: NestInk.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Enter your email address\nto reset password.",
                                style: robotoRegular.copyWith(
                                  fontSize: 15,
                                  color: NestInk.mutedText,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 40),

                              _buildFieldLabel('Email Address'),
                              CustomTextField(
                                onCountryChanged: (countryCode) => countryDialCode = countryCode.dialCode!,
                                countryDialCode: (_forgetPasswordMethod != "email" && _isNumberLogin) ? countryDialCode : null,
                                hintText: 'hannah.turin@email.com',
                                controller: _identityController,
                                focusNode: _identityFocus,
                                inputType: TextInputType.emailAddress,
                                onChanged: (String text) {
                                  final numberRegExp = RegExp(r'^-?[0-9]+$');
                                  if (text.isEmpty && _isNumberLogin) {
                                    toggleIsNumberLogin();
                                  }
                                  if (text.startsWith(numberRegExp) && !_isNumberLogin) {
                                    toggleIsNumberLogin();
                                  }
                                  final emailRegExp = RegExp(r'@');
                                  if (text.contains(emailRegExp) && _isNumberLogin) {
                                    toggleIsNumberLogin();
                                  }
                                },
                                onValidate: (String? value) {
                                  if (_isNumberLogin && (_forgetPasswordMethod == "phone" || _forgetPasswordMethod == "both") && PhoneVerificationHelper.getValidPhoneNumber(countryDialCode + value!) == "") {
                                    return "enter_valid_phone_number".tr;
                                  }
                                  if (_forgetPasswordMethod == "email" && !GetUtils.isEmail(value!)) {
                                    return "enter_valid_email_address".tr;
                                  }
                                  return (GetUtils.isPhoneNumber(value!.tr) || GetUtils.isEmail(value.tr)) ? null : 'enter_email_or_phone'.tr;
                                },
                              ),

                              const SizedBox(height: 40),

                              CustomButton(
                                buttonText: 'Reset Password',
                                isLoading: authController.isLoading,
                                backgroundColor: NestInk.primary,
                                textColor: NestInk.background,
                                onPressed: () => formKey.currentState!.validate() ? _forgetPass(countryDialCode, authController) : null,
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: robotoSemiBold.copyWith(
          color: NestInk.primary,
          fontSize: 14,
        ),
      ),
    );
  }

  void _forgetPass(String countryDialCode, AuthController authController) async {
    String phone = PhoneVerificationHelper.getValidPhoneNumber(countryDialCode + _identityController.text.trim(), withCountryCode: true);
    String identity = phone != "" ? phone : _identityController.text.trim();

    var config = Get.find<SplashController>().configModel.content;
    SendOtpType type = config?.firebaseOtpVerification == 1 && phone != "" ? SendOtpType.firebase : SendOtpType.forgetPassword;

    authController.sendVerificationCode(
      identity: identity,
      identityType: phone != "" ? "phone" : "email",
      type: type,
      fromPage: "forget-password",
      redtrectUrl: widget.redtrectUrl,
    ).then((status) {
      if (status != null) {
        if (status.isSuccess!) {
          Get.toNamed(RouteHelper.getVerificationRoute(
            identity: identity,
            identityType: phone != "" ? "phone" : "email",
            fromPage: "forget-password",
            firebaseSession: type == SendOtpType.firebase ? status.message : null,
            redtrectUrl: widget.redtrectUrl,
          ));
        } else {
          customSnackBar(status.message.toString().capitalizeFirst ?? "");
        }
      }
    });
  }

  void toggleIsNumberLogin({bool? value, bool isUpdate = true}) {
    if (_forgetPasswordMethod == "both") {
      if (isUpdate) {
        setState(() {
          if (value == null) {
            _isNumberLogin = !_isNumberLogin;
          } else {
            _isNumberLogin = value;
          }
        });
      } else {
        if (value == null) {
          _isNumberLogin = !_isNumberLogin;
        } else {
          _isNumberLogin = value;
        }
      }
    } else if (_forgetPasswordMethod == "phone") {
      _isNumberLogin = true;
    }
  }
}


