import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

class VerificationScreen extends StatefulWidget {
  final String? identity;
  final String fromPage;
  final String identityType;
  final String? firebaseSession;
  final String? redirectRoute;
  const VerificationScreen({super.key, this.identity, required this.fromPage, required this.identityType, this.firebaseSession, this.redirectRoute});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _identity;
  Timer? _timer;
  int? _seconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.identityType == "phone" && !widget.identity!.startsWith('+')) {
      _identity = '+${widget.identity!.substring(1, widget.identity!.length)}';
    } else {
      _identity = widget.identity;
    }
    Get.find<AuthController>().setWrongOtpSubmitted(false);
    _startTimer();
  }

  void _startTimer() {
    _seconds = Get.find<SplashController>().configModel.content?.resentOtpTime ?? 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
        endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      'OTP Verification',
                      style: robotoSemiBold.copyWith(fontSize: 17, color: const Color(0xff101828)),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: GetBuilder<AuthController>(builder: (authController) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        const SizedBox(height: 36),
                        Container(
                          height: 88.0,
                          width: 88.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xffFFF1EB),
                            border: Border.all(color: const Color(0xffFFD9C7), width: 1),
                          ),
                          child: const Icon(Icons.mark_email_read_outlined, color: Color(0xffFF6B2C), size: 40),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'enter_the_4_digit_code'.tr,
                          textAlign: TextAlign.center,
                          style: robotoBold.copyWith(fontSize: 20, color: const Color(0xff101828), height: 1.3),
                        ),
                        const SizedBox(height: 10),
                        if (Get.find<SplashController>().configModel.content?.appEnvironment == "demo")
                          Text(
                            'for_demo_purpose'.tr,
                            textAlign: TextAlign.center,
                            style: robotoRegular.copyWith(color: const Color(0xff667085)),
                          )
                        else
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                TextSpan(
                                  text: "We've sent a verification code to\n",
                                  style: robotoRegular.copyWith(color: const Color(0xff667085), fontSize: 14, height: 1.5),
                                ),
                                TextSpan(
                                  text: StringParser.obfuscateMiddle(_identity ?? ""),
                                  style: robotoBold.copyWith(color: const Color(0xff101828), fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 32),
                        Form(
                          child: PinCodeTextField(
                            appContext: context,
                            length: 6,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.fade,
                            showCursor: true,
                            cursorColor: const Color(0xffFF6B2C),
                            enableActiveFill: true,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(12),
                              fieldHeight: 52,
                              fieldWidth: 48,
                              borderWidth: 1.5,
                              activeBorderWidth: 1.5,
                              inactiveBorderWidth: 1.5,
                              errorBorderWidth: 1.5,
                              selectedColor: authController.isWrongOtpSubmitted
                                  ? const Color(0xffF05454)
                                  : const Color(0xffFF6B2C),
                              activeColor: authController.isWrongOtpSubmitted
                                  ? const Color(0xffF05454)
                                  : const Color(0xffFF6B2C),
                              inactiveColor: const Color(0xffD0D5DD),
                              activeFillColor: Colors.white,
                              selectedFillColor: Colors.white,
                              inactiveFillColor: Color(0xffF9FAFB),
                            ),
                            animationDuration: const Duration(milliseconds: 200),
                            backgroundColor: Colors.transparent,
                            onChanged: authController.updateVerificationCode,
                            beforeTextPaste: (text) => true,
                            pastedTextStyle: robotoRegular.copyWith(color: const Color(0xff101828)),
                            textStyle: robotoMedium,
                          ),
                        ),
                        if (authController.isWrongOtpSubmitted)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'incorrect_otp'.tr,
                              style: robotoMedium.copyWith(color: const Color(0xffF05454), fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          const SizedBox(height: 24),
                        const SizedBox(height: 8),
                        Container(
                          height: 52,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xffFF6B2C),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xffFF6B2C).withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: (authController.verificationCode.length == 6 && !authController.isResendLoading)
                                ? () {
                                    _otpVerify(_identity!, widget.identityType, authController.verificationCode, authController);
                                  }
                                : null,
                            child: authController.isLoading
                                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : Text(
                                    'Verify',
                                    style: robotoSemiBold.copyWith(fontSize: 16, color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (widget.identity != null && widget.identity!.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'did_not_receive'.tr,
                                style: robotoRegular.copyWith(color: const Color(0xff646464), fontSize: 14),
                              ),
                              authController.isResendLoading
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xffFF6B2C)),
                                    )
                                  : TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(1, 30),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: (_seconds! < 1 && !authController.isResendLoading)
                                          ? () {
                                              var config = Get.find<SplashController>().configModel.content;
                                              SendOtpType type = config?.firebaseOtpVerification == 1 && widget.identityType == "phone"
                                                  ? SendOtpType.firebase
                                                  : widget.fromPage == "verification"
                                                      ? SendOtpType.verification
                                                      : SendOtpType.forgetPassword;
                                              authController.sendVerificationCode(
                                                identity: _identity!,
                                                identityType: widget.identityType,
                                                type: type,
                                                isResend: true,
                                              ).then((status) {
                                                if (status != null) {
                                                  if (status.isSuccess!) {
                                                    _startTimer();
                                                    customSnackBar('resend_code_successful'.tr, type: ToasterMessageType.success);
                                                  } else {
                                                    customSnackBar(status.message);
                                                  }
                                                }
                                              });
                                            }
                                          : null,
                                      child: Text(
                                        '${'send_again'.tr}${_seconds! > 0 ? ' ($_seconds)' : ''}',
                                        style: robotoSemiBold.copyWith(fontSize: 14, color: const Color(0xffFF6B2C)),
                                      ),
                                    ),
                            ],
                          ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _otpVerify(String identity, String identityType, String otp, AuthController authController) async {
    if (widget.fromPage == "verification" || widget.fromPage == "profile") {
      authController.verifyOtpForVerificationScreen(
        identity: identity,
        identityType: identityType,
        otp: otp,
        fromPage: widget.fromPage,
        redirectUrl: widget.redirectRoute,
      );
    } else if (widget.fromPage == "otp-login") {
      authController.verifyOtpForPhoneOtpLogin(phone: identity, otp: otp, redirectUrl: widget.redirectRoute);
    } else if (widget.fromPage == "firebase-otp" || (widget.fromPage == "forget-password" && identityType == "phone") && (widget.firebaseSession ?? '').isNotEmpty) {
      authController.verifyOtpForFirebaseOtp(
        session: widget.firebaseSession,
        phone: identity,
        code: otp,
        fromPage: widget.fromPage,
        redirectUrl: widget.redirectRoute,
      );
    } else {
      authController.updateForgetPasswordUrlSessionExpiredStatus(status: false);
      authController.verifyOtpForForgetPasswordScreen(identity, identityType, otp).then((status) async {
        if (status.isSuccess!) {
          Get.offNamed(RouteHelper.getChangePasswordRoute(
            body: ForgetPasswordBody(
              identity: identity,
              identityType: identityType,
              otp: otp,
              fromUrl: 0,
            ),
            redirectUrl: widget.redirectRoute,
          ));
        } else {
          customSnackBar(status.message.toString().capitalizeFirst);
        }
      });
    }
  }
}
