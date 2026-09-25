import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

class SignUpScreen extends StatefulWidget {
  final String? referralCode;
  final String? redirectRoute;

  const SignUpScreen({super.key, this.referralCode, this.redirectRoute});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var referCodeController = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();

  late final GlobalKey<FormState> customerSignUpKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().initCountryCode();
    Get.find<AuthController>().toggleTerms(value: false, shouldUpdate: false);
    final ConfigModel config = Get.find<SplashController>().configModel;
    if (config.content?.referEarnStatus == 1 && (widget.referralCode?.isNotEmpty ?? false)) {
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
    return CustomPopWidget(
      onPopInvoked: () {
        AuthController authController = Get.find();
        authController.acceptTerms == true ? authController.toggleTerms() : authController.acceptTerms;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
        endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        body: GetBuilder<AuthController>(
          builder: (authController) {
            var config = Get.find<SplashController>().configModel.content;
            var socialLogin = config?.customerLogin?.loginOption?.socialMediaLogin;

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 6,
                    bottom: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xffEAECF0), width: 1)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff101828), size: 20),
                      ),
                      const Spacer(),
                      Text(
                        'Register',
                        style: robotoSemiBold.copyWith(fontSize: 17, color: const Color(0xff101828)),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
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
                                color: const Color(0xff101828),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Started',
                                  style: robotoBold.copyWith(
                                    fontSize: 30,
                                    height: 1.2,
                                    color: const Color(0xffFF6B2C),
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
                              color: const Color(0xff98A2B3),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.check_circle, size: 16, color: Color(0xffFF6B2C)),
                              const SizedBox(width: 6),
                              Text(
                                'Takes less than a minute',
                                style: robotoMedium.copyWith(
                                  fontSize: 13,
                                  color: const Color(0xff667085),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),

                          _buildSectionTitle('Personal Information'),
                          const SizedBox(height: 16),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('first_name'.tr),
                                    CustomTextField(
                                      hintText: 'enter_your_first_name'.tr,
                                      controller: firstNameController,
                                      focusNode: _firstNameFocus,
                                      nextFocus: _lastNameFocus,
                                      inputType: TextInputType.name,
                                      capitalization: TextCapitalization.words,
                                      isShowBorder: true,
                                      borderRadius: 12,
                                      onValidate: (String? value) {
                                        return FormValidation().isValidFirstName(value!);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('last_name'.tr),
                                    CustomTextField(
                                      hintText: 'enter_your_last_name'.tr,
                                      controller: lastNameController,
                                      focusNode: _lastNameFocus,
                                      nextFocus: _emailFocus,
                                      inputType: TextInputType.name,
                                      capitalization: TextCapitalization.words,
                                      isShowBorder: true,
                                      borderRadius: 12,
                                      onValidate: (String? value) {
                                        return FormValidation().isValidLastName(value!);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                              authController.countryDialCode = countryCode.dialCode!;
                            },
                            countryDialCode: authController.countryDialCode,
                            hintText: 'enter_phone_number'.tr,
                            controller: phoneController,
                            focusNode: _phoneFocus,
                            nextFocus: _passwordFocus,
                            inputType: TextInputType.phone,
                            isRequired: false,
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
                            nextFocus: _confirmPasswordFocus,
                            inputType: TextInputType.visiblePassword,
                            isPassword: true,
                            isShowBorder: true,
                            borderRadius: 12,
                            onValidate: (String? value) {
                              return FormValidation().isValidPassword(value!);
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildFieldLabel('confirm_password'.tr),
                          CustomTextField(
                            hintText: 'enter_confirm_password'.tr,
                            controller: confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            nextFocus: _referCodeFocus,
                            inputType: TextInputType.visiblePassword,
                            isPassword: true,
                            isShowBorder: true,
                            borderRadius: 12,
                            onValidate: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'this_field_can_not_empty'.tr;
                              } else {
                                return FormValidation().isValidConfirmPassword(
                                  passwordController.text,
                                  confirmPasswordController.text,
                                );
                              }
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
                            isRequired: false,
                            isShowBorder: true,
                            borderRadius: 12,
                          ),
                          const SizedBox(height: 8),

                          ConditionCheckBox(
                            checkBoxValue: authController.acceptTerms,
                            onTap: (bool? value) {
                              if (customerSignUpKey.currentState?.validate() == true) {
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
                            backgroundColor: const Color(0xffFF6B2C),
                            textColor: Colors.white,
                            height: 52,
                            radius: 12,
                            fontSize: 16,
                            onPressed: authController.acceptTerms && customerSignUpKey.currentState?.validate() == true
                                ? () => _register(authController)
                                : null,
                          ),

                          const SizedBox(height: 24),

                          if (socialLogin == 1) ...[
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: const Color(0xffEAECF0))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'or'.tr,
                                    style: robotoSemiBold.copyWith(color: const Color(0xff98A2B3), fontSize: 14),
                                  ),
                                ),
                                Expanded(child: Container(height: 1, color: const Color(0xffEAECF0))),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SocialLoginWidget(redirectUrl: widget.redirectRoute),
                            const SizedBox(height: 24),
                          ],

                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                              decoration: BoxDecoration(
                                color: const Color(0xffF9FAFB),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: const Color(0xffEAECF0)),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: '${'already_have_an_account'.tr}  ',
                                  style: const TextStyle(color: Color(0xff646464), fontSize: 14),
                                  children: [
                                    TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.toNamed(RouteHelper.getSignInRoute());
                                        },
                                      text: 'sign_in'.tr,
                                      style: robotoSemiBold.copyWith(fontSize: 14, color: const Color(0xffFF6B2C)),
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
        style: robotoSemiBold.copyWith(
          color: const Color(0xff344054),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffEAECF0)),
      ),
      child: Text(
        text,
        style: robotoSemiBold.copyWith(
          fontSize: 13,
          letterSpacing: 0.4,
          color: const Color(0xff344054),
        ),
      ),
    );
  }

  void _register(AuthController authController) async {
    if (customerSignUpKey.currentState!.validate()) {
      SignUpBody signUpBody;
      String numberWithCountryCode = PhoneVerificationHelper.getValidPhoneNumber(
        authController.countryDialCode + phoneController.value.text,
        withCountryCode: true,
      );

      if (referCodeController.text != "") {
        signUpBody = SignUpBody(
          fName: firstNameController.value.text.trim(),
          lName: lastNameController.value.text.trim(),
          email: emailController.value.text.trim(),
          phone: numberWithCountryCode.trim(),
          password: passwordController.value.text.trim(),
          confirmPassword: confirmPasswordController.value.text.trim(),
          referCode: referCodeController.text.trim(),
        );
      } else {
        signUpBody = SignUpBody(
          fName: firstNameController.value.text.trim(),
          lName: lastNameController.value.text.trim(),
          email: emailController.value.text.trim(),
          phone: numberWithCountryCode.trim(),
          password: passwordController.value.text.trim(),
          confirmPassword: confirmPasswordController.value.text.trim(),
        );
      }
      authController.registration(signUpBody: signUpBody, redirectUrl: widget.redirectRoute);
    }
  }

  void _clearControllerValue() {
    firstNameController.text = "";
    lastNameController.text = "";
    emailController.text = "";
    phoneController.text = "";
    passwordController.text = "";
    confirmPasswordController.text = "";
    referCodeController.text = "";
  }
}
