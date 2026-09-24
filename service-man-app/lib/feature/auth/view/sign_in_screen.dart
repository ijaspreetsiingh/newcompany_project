import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  const SignInScreen({super.key, required this.exitFromApp});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final TextEditingController _identityController = TextEditingController();
  final FocusNode _identityFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  bool _canExit = GetPlatform.isWeb ? true : false;

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
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              "welcome_to".tr,
                              style: robotoBold.copyWith(
                                fontSize: 28,
                                color: const Color(0xff101828),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "sign_in_subtitle".tr,
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
                              hintText:
                                  'enter_email_address_or_phone_number'.tr,
                              controller: _identityController,
                              focusNode: _identityFocus,
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
                                  _identityController.text = text.replaceAll(
                                    "+",
                                    "",
                                  );
                                }
                                if (text.contains("@") &&
                                    authController.isNumberLogin) {
                                  authController.toggleIsNumberLogin();
                                }
                              },
                            ),
                            const SizedBox(height: 25),
                            _buildFieldLabel('password'.tr),
                            CustomTextField(
                              hintText: '********',
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              inputType: TextInputType.visiblePassword,
                              isPassword: true,
                              inputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 13),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  onPressed: () =>
                                      Get.to(const ForgetPassScreen()),
                                  child: Text(
                                    'forgot_password?'.tr,
                                    style: robotoMedium.copyWith(
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
                              onPressed: () => _login(authController),
                            ),
                            const SizedBox(height: 30),
                          ],
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
        style: robotoMedium.copyWith(
          color: const Color(0xff344054),
          fontSize: 14,
        ),
      ),
    );
  }

  void _initializeController() {
    var authController = Get.find<AuthController>();
    String savedNumber = authController.getUserNumber();
    String savedCountryCode = authController.getUserCountryCode();
    String savedPassword = authController.getUserPassword();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (savedNumber != "" && !savedNumber.contains("@")) {
        authController.toggleIsNumberLogin(value: true);
        authController.initCountryCode(
          countryCode: savedCountryCode != "" ? savedCountryCode : null,
        );
      } else {
        authController.toggleIsNumberLogin(value: false);
        authController.initCountryCode();
      }
    });

    if (savedNumber.contains("@")) {
      _identityController.text = savedNumber;
    } else if (savedNumber != "") {
      _identityController.text = savedCountryCode != ""
          ? savedNumber.replaceFirst(savedCountryCode, '')
          : savedNumber;
    }
    _passwordController.text = savedPassword;

    if (savedPassword != "" && savedNumber != "") {
      authController.toggleRememberMe(newValue: true, shouldUpdate: false);
    } else {
      authController.toggleRememberMe(newValue: false, shouldUpdate: false);
    }
  }

  void _login(AuthController authController) async {
    String identity = _identityController.text.trim();
    String password = _passwordController.text.trim();

    if (identity.isEmpty) {
      showCustomSnackBar(
        'enter_email_address_or_phone_number'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }
    if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr, type: ToasterMessageType.info);
      return;
    }
    if (password.length < 8) {
      showCustomSnackBar(
        'password_should_be'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    if (authController.isNumberLogin) {
      String phone = ValidationHelper.getValidPhone(
        authController.countryDialCode + identity,
        withCountryCode: true,
      );
      if (phone == "") {
        showCustomSnackBar(
          'invalid_phone_number'.tr,
          type: ToasterMessageType.info,
        );
        return;
      }
      await authController.login(
        phone,
        password,
        "phone",
        countryCode: authController.countryDialCode,
      );
    } else {
      if (!GetUtils.isEmail(identity)) {
        showCustomSnackBar(
          'enter_email_address'.tr,
          type: ToasterMessageType.info,
        );
        return;
      }
      await authController.login(identity, password, "email");
    }
  }
}
