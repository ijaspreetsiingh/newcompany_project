import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';

class SignUpScreen extends StatefulWidget {
  final String? referralCode;
  final String? redtrectRoute;

  const SignUpScreen({super.key, this.referralCode, this.redtrectRoute});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var firstNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var referCodeController = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();

  late final GlobalKey<FormState> customerSignUpKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().inttCountryCode();
    Get.find<AuthController>().toggleTerms(value: false, shouldUpdate: false);
    final ConfigModel config = Get.find<SplashController>().configModel;
    if (config.content?.referEarnStatus == 1 &&
        (widget.referralCode?.isNotEmpty ?? false)) {
      referCodeController.text = widget.referralCode ?? '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _clearControllerValue();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return CustomPopWidget(
      onPopInvoked: () {
        AuthController authController = Get.find();
        authController.acceptTerms == true
            ? authController.toggleTerms()
            : authController.acceptTerms;
      },
      child: Scaffold(
        backgroundColor: NestInk.background,
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        body: GetBuilder<AuthController>(
          builder: (authController) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 6,
                    bottom: 12,
                  ),
                  decoration: BoxDecoration(
                    color: NestInk.background,
                    border: Border(
                      bottom: BorderSide(color: NestInk.border, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: NestInk.primary,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Register',
                        style: robotoSemiBold.copyWith(
                          fontSize: 17,
                          color: NestInk.primary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            Get.offAllNamed(RouteHelper.getMainRoute("home")),
                        child: Text(
                          'skip'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: NestInk.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Form(
                      key: customerSignUpKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          RichText(
                            text: TextSpan(
                              text: 'Getting ',
                              style: robotoBold.copyWith(
                                fontSize: 30,
                                height: 1.2,
                                color: NestInk.primary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Started',
                                  style: robotoBold.copyWith(
                                    fontSize: 30,
                                    height: 1.2,
                                    color: NestInk.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Seems you are new here,\nLet's set up your profile.",
                            style: robotoRegular.copyWith(
                              fontSize: 15,
                              height: 1.5,
                              color: NestInk.mutedText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: NestInk.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Takes less than a minute',
                                style: robotoMedium.copyWith(
                                  fontSize: 13,
                                  color: NestInk.mutedText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),

                          _buildSectionTitle('Personal Information'),
                          const SizedBox(height: 16),

                          _buildFieldLabel('Full Name'),
                          CustomTextField(
                            hintText: 'e.g. Rahul Sharma',
                            controller: firstNameController,
                            focusNode: _firstNameFocus,
                            nextFocus: _emailFocus,
                            inputType: TextInputType.name,
                            capitalization: TextCapitalization.words,
                            isShowBorder: true,
                            borderRadius: 12,
                            onValidate: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your full name';
                              }
                              if (value.trim().length < 2) {
                                return 'Name is too short';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('Contact Details'),
                          const SizedBox(height: 16),

                          _buildFieldLabel('email_address'.tr),
                          CustomTextField(
                            hintText: 'enter_email_address'.tr,
                            controller: emailController,
                            focusNode: _emailFocus,
                            nextFocus: _phoneFocus,
                            inputType: TextInputType.emailAddress,
                            isShowBorder: true,
                            borderRadius: 12,
                            onValidate: (String? value) {
                              return FormValidation().isValidEmail(value);
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildFieldLabel('phone_number'.tr),
                          CustomTextField(
                            onCountryChanged: (CountryCode countryCode) {
                              authController.countryDialCode =
                                  countryCode.dialCode!;
                            },
                            countryDialCode: authController.countryDialCode,
                            hintText: 'enter_phone_number'.tr,
                            controller: phoneController,
                            focusNode: _phoneFocus,
                            nextFocus: _passwordFocus,
                            inputType: TextInputType.phone,
                            isrequired: false,
                            isShowBorder: true,
                            borderRadius: 12,
                            onValidate: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'enter_phone_number'.tr;
                              } else {
                                return FormValidation().isValidPhone(
                                  authController.countryDialCode + (value),
                                  fromAuthPage: true,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('Security'),
                          const SizedBox(height: 16),

                          _buildFieldLabel('password'.tr),
                          CustomTextField(
                            hintText: 'enter_password'.tr,
                            controller: passwordController,
                            focusNode: _passwordFocus,
                            nextFocus: _referCodeFocus,
                            inputType: TextInputType.visiblePassword,
                            isPassword: true,
                            isShowBorder: true,
                            borderRadius: 12,
                            onValidate: (String? value) {
                              return FormValidation().isValidPassword(value!);
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildFieldLabel('referral_code'.tr),
                          CustomTextField(
                            hintText: 'optional'.tr,
                            controller: referCodeController,
                            focusNode: _referCodeFocus,
                            inputType: TextInputType.text,
                            inputAction: TextInputAction.done,
                            isrequired: false,
                            isShowBorder: true,
                            borderRadius: 12,
                          ),
                          const SizedBox(height: 8),

                          ConditionCheckBox(
                            checkBoxValue: authController.acceptTerms,
                            onTap: (bool? value) {
                              if (customerSignUpKey.currentState?.validate() ==
                                  true) {
                                authController.toggleTerms(value: true);
                              } else {
                                authController.toggleTerms(value: false);
                              }
                            },
                          ),

                          const SizedBox(height: 24),

                          CustomButton(
                            buttonText: 'Create Account',
                            isLoading: authController.isLoading,
                            backgroundColor: NestInk.primary,
                            textColor: Theme.of(context).colorScheme.onPrimary,
                            height: 52,
                            radius: 12,
                            fontSize: 16,
                            onPressed:
                                authController.acceptTerms &&
                                    customerSignUpKey.currentState
                                            ?.validate() ==
                                        true
                                ? () => _register(authController)
                                : null,
                          ),

                          const SizedBox(height: 24),

                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: NestInk.soft,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: NestInk.border),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: '${'already_have_an_account'.tr}  ',
                                  style: TextStyle(
                                    color: NestInk.mutedText,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.toNamed(
                                            RouteHelper.getSignInRoute(),
                                          );
                                        },
                                      text: 'sign_in'.tr,
                                      style: robotoSemiBold.copyWith(
                                        fontSize: 14,
                                        color: NestInk.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: robotoSemiBold.copyWith(color: NestInk.primary, fontSize: 14),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: NestInk.soft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NestInk.border),
      ),
      child: Text(
        text,
        style: robotoSemiBold.copyWith(
          fontSize: 13,
          letterSpacing: 0.4,
          color: NestInk.primary,
        ),
      ),
    );
  }

  void _register(AuthController authController) async {
    if (customerSignUpKey.currentState!.validate()) {
      String numberWithCountryCode =
          PhoneVerificationHelper.getValidPhoneNumber(
            authController.countryDialCode + phoneController.value.text,
            withCountryCode: true,
          );

      String fullName = firstNameController.value.text.trim();
      List<String> nameParts = fullName.split(RegExp(r'\s+'));
      String fName = nameParts.first;
      String lName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : nameParts.first;

      SignUpBody signUpBody = SignUpBody(
        fName: fName,
        lName: lName,
        email: emailController.value.text.trim(),
        phone: numberWithCountryCode.trim(),
        password: passwordController.value.text.trim(),
        confirmPassword: passwordController.value.text.trim(),
        referCode: referCodeController.text.trim().isEmpty
            ? null
            : referCodeController.text.trim(),
      );
      authController.registration(
        signUpBody: signUpBody,
        redtrectUrl: widget.redtrectRoute,
      );
    }
  }

  void _clearControllerValue() {
    firstNameController.text = "";
    emailController.text = "";
    phoneController.text = "";
    passwordController.text = "";
    referCodeController.text = "";
  }
}
