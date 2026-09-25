import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final String? redirectRoute;
  const SignInScreen({super.key, required this.exitFromApp, this.redirectRoute});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var signInPhoneController = TextEditingController();
  var signInPasswordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final GlobalKey<FormState> customerSignInKey = GlobalKey<FormState>();

  @override
  void initState() {
    _initializeController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GetBuilder<SplashController>(builder: (splashController) {
          return GetBuilder<AuthController>(builder: (authController) {
            var config = splashController.configModel.content;
            var otpLogin = config?.customerLogin?.loginOption?.otpLogin;
            var manualLogin = config?.customerLogin?.loginOption?.manualLogin ?? 1;
            var socialLogin = config?.customerLogin?.loginOption?.socialMediaLogin;

            return Form(
              key: customerSignInKey,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff101828), size: 20),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          Text(
                            "Let's Sign You In",
                            style: robotoBold.copyWith(
                              fontSize: 28,
                              color: const Color(0xff101828),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Welcome back, you've been missed!",
                            style: robotoRegular.copyWith(
                              fontSize: 15,
                              color: const Color(0xff98A2B3),
                            ),
                          ),
                          const SizedBox(height: 40),

                          if (manualLogin == 1 || otpLogin == 1) ...[
                            CustomTextField(
                              onCountryChanged: (countryCode) => authController.countryDialCode = countryCode.dialCode!,
                              countryDialCode: authController.isNumberLogin || (manualLogin == 0 && otpLogin == 1) ? authController.countryDialCode : null,
                              title: authController.isNumberLogin ? 'phone_number'.tr : 'Email Address',
                              hintText: authController.selectedLoginMedium == LoginMedium.otp || (manualLogin == 0 && otpLogin == 1)
                                  ? "please_enter_phone_number".tr
                                  : 'Email Address',
                              controller: signInPhoneController,
                              focusNode: _phoneFocus,
                              nextFocus: _passwordFocus,
                              capitalization: TextCapitalization.words,
                              onChanged: (String text) {
                                if (authController.selectedLoginMedium != LoginMedium.otp) {
                                  final numberRegExp = RegExp(r'^[+]?[0-9]+$');
                                  if (text.isEmpty && authController.isNumberLogin) {
                                    authController.toggleIsNumberLogin();
                                  }
                                  if (text.startsWith(numberRegExp) && !authController.isNumberLogin && manualLogin == 1) {
                                    authController.toggleIsNumberLogin();
                                    final cursorPosition = signInPhoneController.selection.baseOffset;
                                    signInPhoneController.text = text.replaceAll("+", "");
                                    signInPhoneController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));
                                  }
                                  final emailRegExp = RegExp(r'@');
                                  if (text.contains(emailRegExp) && authController.isNumberLogin && manualLogin == 1) {
                                    authController.toggleIsNumberLogin();
                                  }
                                  _phoneFocus.requestFocus();
                                }
                              },
                              onValidate: (String? value) {
                                if (otpLogin == 1 && manualLogin == 0 && PhoneVerificationHelper.getValidPhoneNumber(authController.countryDialCode + signInPhoneController.text.trim(), withCountryCode: true) == "") {
                                  return "enter_valid_phone_number".tr;
                                }
                                if (authController.isNumberLogin && PhoneVerificationHelper.getValidPhoneNumber(authController.countryDialCode + signInPhoneController.text.trim(), withCountryCode: true) == "") {
                                  return "enter_valid_phone_number".tr;
                                }
                                return (PhoneVerificationHelper.getValidPhoneNumber(authController.countryDialCode + signInPhoneController.text.trim(), withCountryCode: true) != "" || GetUtils.isEmail(value ?? ""))
                                    ? null
                                    : 'enter_email_or_phone'.tr;
                              },
                            ),
                            const SizedBox(height: 25),
                          ],

                          if (manualLogin == 1 && authController.selectedLoginMedium == LoginMedium.manual) ...[
                            CustomTextField(
                              title: 'password'.tr,
                              hintText: 'enter_password'.tr,
                              controller: signInPasswordController,
                              focusNode: _passwordFocus,
                              inputType: TextInputType.visiblePassword,
                              isPassword: true,
                              onValidate: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'please_enter_password'.tr;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 13),
                          ],

                          if (manualLogin == 1 || otpLogin == 1) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child:                             CheckboxListTile(
                                    checkColor: Colors.white,
                                    activeColor: const Color(0xffFF6B2C),
                                    contentPadding: const EdgeInsets.all(0),
                                    title: Text(
                                      'remember_me'.tr,
                                      style: robotoRegular.copyWith(
                                        color: const Color(0xff475467),
                                        fontSize: 14,
                                      ),
                                    ),
                                    value: authController.isActiveRememberMe,
                                    onChanged: (newValue) {
                                      authController.toggleRememberMe();
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                  ),
                                ),
                                if (manualLogin == 1 && authController.selectedLoginMedium == LoginMedium.manual)
                                  InkWell(
                                    onTap: () {
                                      Get.toNamed(RouteHelper.getSendOtpScreen(redirectUrl: widget.redirectRoute));
                                    },
                                    child: Text(
                                      'forgot_password'.tr,
                                      style: robotoSemiBold.copyWith(
                                        fontSize: 14,
                                        color: const Color(0xffFF6B2C),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 13),
                          ],

                          if (manualLogin == 1 || otpLogin == 1)
                            CustomButton(
                              buttonText: (authController.selectedLoginMedium == LoginMedium.otp) || (manualLogin == 0 && otpLogin == 1) ? "get_otp".tr : 'Login',
                              isLoading: authController.isLoading,
                              backgroundColor: const Color(0xffFF6B2C),
                              textColor: Colors.white,
                              onPressed: () {
                                if (customerSignInKey.currentState!.validate()) {
                                  _login(authController, manualLogin, otpLogin);
                                }
                              },
                            ),

                          const SizedBox(height: 25),

                          if ((manualLogin == 1 || otpLogin == 1) && socialLogin == 1) ...[
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: const Color(0xffD0D5DD))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'or'.tr,
                                    style: robotoSemiBold.copyWith(color: const Color(0xff98A2B3), fontSize: 14),
                                  ),
                                ),
                                Expanded(child: Container(height: 1, color: const Color(0xffD0D5DD))),
                              ],
                            ),
                            const SizedBox(height: 25),
                          ],

                          if (socialLogin == 1) SocialLoginWidget(redirectUrl: widget.redirectRoute),

                          const SizedBox(height: 25),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: '${'do_not_have_an_account'.tr}  ',
                                  style: const TextStyle(color: Color(0xff646464), fontSize: 14),
                                  children: [
                                    TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          signInPhoneController.clear();
                                          signInPasswordController.clear();
                                          Get.toNamed(RouteHelper.getSignUpRoute(redirectUrl: widget.redirectRoute));
                                        },
                                      text: 'sign_up'.tr,
                                      style: robotoSemiBold.copyWith(fontSize: 14, color: const Color(0xffFF6B2C)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        }),
      ),
    );
  }

  void _initializeController() {
    var authController = Get.find<AuthController>();
    String phoneWithoutCountryCode = PhoneVerificationHelper.getValidPhoneNumber(Get.find<AuthController>().getUserNumber());
    String countryCode = PhoneVerificationHelper.getCountryCode(Get.find<AuthController>().getUserNumber());

    var config = Get.find<SplashController>().configModel.content;
    var manualLogin = config?.customerLogin?.loginOption?.manualLogin ?? 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (countryCode != "" && phoneWithoutCountryCode != "") {
        authController.toggleIsNumberLogin(value: true);
      } else {
        authController.toggleIsNumberLogin(value: false);
      }
      authController.toggleSelectedLoginMedium(loginMedium: LoginMedium.manual);
      authController.initCountryCode(countryCode: countryCode != "" ? countryCode : null);

      signInPhoneController.text = phoneWithoutCountryCode != "" ? phoneWithoutCountryCode : authController.isNumberLogin ? "" : Get.find<AuthController>().getUserNumber();
      signInPasswordController.text = Get.find<AuthController>().getUserPassword();

      if (manualLogin == 1 && signInPasswordController.text.isEmpty) {
        signInPhoneController.text = "";
        authController.initCountryCode();
        authController.toggleIsNumberLogin(value: false);
      }
    });
    authController.toggleRememberMe(value: false, shouldUpdate: false);
  }

  void _login(AuthController authController, var manualLogin, var otpLogin) async {
    if (customerSignInKey.currentState!.validate()) {
      var config = Get.find<SplashController>().configModel.content;
      SendOtpType type = config?.firebaseOtpVerification == 1 ? SendOtpType.firebase : SendOtpType.verification;
      String phone = PhoneVerificationHelper.getValidPhoneNumber(authController.countryDialCode + signInPhoneController.text.trim(), withCountryCode: true);

      if ((authController.selectedLoginMedium == LoginMedium.otp) || (manualLogin == 0 && otpLogin == 1)) {
        authController.sendVerificationCode(
          identity: phone,
          identityType: "phone",
          type: type,
          checkUser: 0,
          redirectUrl: widget.redirectRoute,
        ).then((status) {
          if (status != null) {
            if (status.isSuccess!) {
              Get.toNamed(RouteHelper.getVerificationRoute(
                identity: phone,
                identityType: "phone",
                fromPage: config?.firebaseOtpVerification == 1 ? "firebase-otp" : "otp-login",
                firebaseSession: type == SendOtpType.firebase ? status.message : null,
                redirectUrl: widget.redirectRoute,
              ));
            } else {
              customSnackBar(status.message.toString().capitalizeFirst);
            }
          }
        });
      } else {
        authController.login(
          redirectRoute: widget.redirectRoute,
          emailPhone: phone != "" ? phone : signInPhoneController.text.trim(),
          password: signInPasswordController.text.trim(),
          type: phone != "" ? "phone" : "email",
        );
      }
    }
  }
}
