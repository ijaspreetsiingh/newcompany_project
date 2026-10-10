import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  const SignInScreen({super.key, required this.exitFromApp});

  @override
  SignInScreenState createState() => SignInScreenState();
}

/// Shared auth layout matching the reference `AuthShell` (optional back
/// button, brand mark, display title + muted subtitle, stacked fields) with a
/// subtle fade/slide entrance.
class AuthShell extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final List<Widget> children;

  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    required this.children,
  });

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.03),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              children: [
                if (widget.onBack != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: KIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: widget.onBack,
                    ),
                  ),
                const SizedBox(height: 64),
                Text(
                  widget.title,
                  style: robotoBold.copyWith(
                    fontSize: 32,
                    height: 1.15,
                    letterSpacing: -0.5,
                    color: context.kForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  style: robotoRegular.copyWith(
                    fontSize: 14,
                    height: 24 / 14,
                    color: context.kMutedForeground,
                  ),
                ),
                const SizedBox(height: 32),
                for (int i = 0; i < widget.children.length; i++) ...[
                  if (i > 0) const SizedBox(height: 20),
                  widget.children[i],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
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
      child: GetBuilder<SplashController>(
        builder: (splashController) {
          return GetBuilder<AuthController>(
            builder: (authController) {
              return AuthShell(
                title: 'welcome_back'.tr,
                subtitle: 'sign_in_subtitle'.tr,
                children: [
                  TextFieldTitle(title: 'email_or_phone'.tr),
                  CustomTextField(
                    onCountryChanged: (countryCode) =>
                        authController.countryDialCode =
                            countryCode.dialCode!,
                    countryDialCode: authController.isNumberLogin
                        ? authController.countryDialCode
                        : null,
                    hintText:
                        'enter_email_address_or_phone_number'.tr,
                    prefixIcon: authController.isNumberLogin
                        ? Icons.phone_outlined
                        : Icons.mail_outline_rounded,
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
                  TextFieldTitle(title: 'password'.tr),
                  CustomTextField(
                    hintText: '********',
                    prefixIcon: Icons.lock_outline_rounded,
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    inputType: TextInputType.visiblePassword,
                    isPassword: true,
                    inputAction: TextInputAction.done,
                    onSubmit: (_) => _login(authController),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => authController.toggleRememberMe(),
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: authController.isActiveRememberMe,
                              onChanged: (newValue) {
                                authController.toggleRememberMe();
                              },
                              activeColor: context.kPrimary,
                              checkColor: context.kPrimaryForeground,
                              side: BorderSide(
                                color: context.kInputBorder,
                                width: 1.5,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'remember_me'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                color: context.kForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Get.to(const ForgetPassScreen()),
                        borderRadius: BorderRadius.circular(kRadiusSm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          child: Text(
                            'forgot_password'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.kForeground,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  KButton(
                    label: (authController.isLoading ?? false)
                        ? 'loading'.tr
                        : 'sign_in'.tr,
                    height: 48,
                    onTap: (authController.isLoading ?? false)
                        ? null
                        : () => _login(authController),
                  ),
                ],
              );
            },
          );
        },
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
