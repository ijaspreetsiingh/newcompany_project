import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  const SignInScreen({super.key, required this.exitFromApp});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  bool _canExit = GetPlatform.isWeb ? true : false;
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    _initializeController();
    _requestNotificationPermission();
    super.initState();
  }

  Future<void> _requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Future.delayed(Duration(seconds: 1));
      await FirebaseMessaging.instance.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      onPopInvoked: () {
        if (_canExit) {
          SystemNavigator.pop();
        } else {
          showCustomSnackBar(
            'back_press_again_to_exit'.tr,
            type: ToasterMessageType.info,
          );
          _canExit = true;
          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GetBuilder<SplashController>(
          builder: (splashController) {
            return GetBuilder<AuthController>(
              builder: (authController) {
                return Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 10),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xff101828),
                          size: 20,
                        ),
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Form(
                          key: signInFormKey,
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

                              _buildFieldLabel('email_or_phone'.tr),
                              CustomTextField(
                                onCountryChanged: (countryCode) =>
                                    authController.countryDialCode =
                                        countryCode.dialCode!,
                                countryDialCode: authController.isNumberLogin
                                    ? authController.countryDialCode
                                    : null,
                                hintText: 'enter_email_or_password'.tr,
                                controller: _emailController,
                                focusNode: _emailFocus,
                                nextFocus: _passwordFocus,
                                inputType: TextInputType.emailAddress,
                                onChanged: (String text) {
                                  final numberRegExp = RegExp(r'^[+]?[0-9]+$');
                                  if (text.isEmpty &&
                                      authController.isNumberLogin) {
                                    authController.toggleIsNumberLogin();
                                  }
                                  if (text.startsWith(numberRegExp) &&
                                      !authController.isNumberLogin) {
                                    authController.toggleIsNumberLogin();
                                    _emailController.text = text.replaceAll(
                                      "+",
                                      "",
                                    );
                                  }
                                  final emailRegExp = RegExp(r'@');
                                  if (text.contains(emailRegExp) &&
                                      authController.isNumberLogin) {
                                    authController.toggleIsNumberLogin();
                                  }
                                },
                                onValidate: (String? value) {
                                  if (authController.isNumberLogin &&
                                      ValidationHelper.getValidPhone(
                                            authController.countryDialCode +
                                                value!,
                                          ) ==
                                          "") {
                                    return "enter_valid_phone_number".tr;
                                  }
                                  return (GetUtils.isPhoneNumber(value!.tr) ||
                                          GetUtils.isEmail(value.tr))
                                      ? null
                                      : 'enter_email_address_or_phone_number'
                                            .tr;
                                },
                              ),

                              const SizedBox(height: 25),

                              _buildFieldLabel('password'.tr),
                              CustomTextField(
                                hintText: '********'.tr,
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                inputType: TextInputType.visiblePassword,
                                isPassword: true,
                                inputAction: TextInputAction.done,
                                onValidate: (String? value) {
                                  return FormValidationHelper().isValidPassword(
                                    value,
                                  );
                                },
                              ),

                              const SizedBox(height: 13),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: CheckboxListTile(
                                      checkColor: Colors.white,
                                      activeColor: const Color(0xFF2563EB),
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
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(1, 40),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      if (Get.find<SplashController>()
                                                  .configModel
                                                  .content
                                                  ?.forgetPasswordVerificationMethod
                                                  ?.phone ==
                                              0 &&
                                          Get.find<SplashController>()
                                                  .configModel
                                                  .content
                                                  ?.forgetPasswordVerificationMethod
                                                  ?.email ==
                                              0) {
                                        showCustomSnackBar(
                                          'no_verification_method_found'.tr,
                                        );
                                      } else {
                                        Get.toNamed(
                                          RouteHelper.getSendOtpScreen(),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'forgot_password?'.tr,
                                      style: robotoSemiBold.copyWith(
                                        fontSize: 14,
                                        color: const Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 13),

                              CustomButton(
                                btnTxt: 'sign_in'.tr,
                                isLoading: authController.isLoading ?? false,
                                color: const Color(0xFF2563EB),
                                textColor: Colors.white,
                                onPressed: () => _login(authController),
                              ),

                              const SizedBox(height: 25),

                              if (Get.find<SplashController>()
                                      .configModel
                                      .content
                                      ?.providerSelfRegistration ==
                                  1) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: const Color(0xffD0D5DD),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        'or'.tr,
                                        style: robotoSemiBold.copyWith(
                                          color: const Color(0xff98A2B3),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: const Color(0xffD0D5DD),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text:
                                            '${'do_not_have_an_account'.tr}  ',
                                        style: const TextStyle(
                                          color: Color(0xff646464),
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                _emailController.clear();
                                                _passwordController.clear();
                                                Get.toNamed(RouteHelper.signUp);
                                              },
                                            text: 'register_here'.tr,
                                            style: robotoSemiBold.copyWith(
                                              fontSize: 14,
                                              color: const Color(0xFF2563EB),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],

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
    );
  }

  Widget _buildFieldLabel(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: robotoSemiBold.copyWith(
          color: const Color(0xff344054),
          fontSize: 14,
        ),
      ),
    );
  }

  void _initializeController() {
    var authController = Get.find<AuthController>();
    String phoneWithoutCountryCode = ValidationHelper.getValidPhone(
      Get.find<AuthController>().getUserNumber(),
    );
    String countryCode = ValidationHelper.getCountryCode(
      Get.find<AuthController>().getUserNumber(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (countryCode != "" && phoneWithoutCountryCode != "") {
        authController.toggleIsNumberLogin(value: true);
      } else {
        authController.toggleIsNumberLogin(value: false);
      }
      authController.initCountryCode(
        countryCode: countryCode != "" ? countryCode : null,
      );
    });

    _emailController.text = phoneWithoutCountryCode != ""
        ? phoneWithoutCountryCode
        : authController.isNumberLogin
        ? ""
        : Get.find<AuthController>().getUserNumber();
    _passwordController.text = Get.find<AuthController>().getUserPassword();
  }

  void _login(AuthController authController) async {
    if (signInFormKey.currentState!.validate()) {
      String phone = ValidationHelper.getValidPhone(
        authController.countryDialCode + _emailController.text.trim(),
        withCountryCode: true,
      );
      await authController.login(
        phone != "" ? phone : _emailController.text.trim(),
        _passwordController.text.trim(),
        phone != "" ? "phone" : "email",
      );
    }
  }
}
