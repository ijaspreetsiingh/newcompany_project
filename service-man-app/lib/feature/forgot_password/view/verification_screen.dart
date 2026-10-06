import 'package:demandium_serviceman/helper/string_parser.dart';
import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class VerificationScreen extends StatefulWidget {
  final String? identity;
  final String identityType;
  final String? firebaseSession;
  const VerificationScreen({super.key, this.identity, required this.identityType, this.firebaseSession});

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
    Get.find<AuthController>().updateWrongVerificationCodeStatus();

    if( (widget.identityType == "phone" && !widget.identity!.startsWith('+'))){
      _identity = '+${widget.identity!.substring(1, widget.identity!.length)}';
    } else{
      _identity = widget.identity;
    }

    _startTimer();
  }

  void _startTimer() {
    _seconds = Get.find<SplashController>().configModel?.content?.sendOtpTimer ?? 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if(_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  String _formatSeconds() {
    final int seconds = _seconds ?? 0;
    final String minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final String remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    final bool isDemo =
        Get.find<SplashController>().configModel?.content?.appEnvironment == "demo";
    final String subtitle = isDemo
        ? 'for_demo_purpose'.tr
        : '${'we_have_sent_a_verification_code_to'.tr}\n${StringParser.obfuscateMiddle(_identity ?? "")}';

    return GetBuilder<AuthController>(builder: (authController) {
      return AuthShell(
        title: 'enter_verification'.tr,
        subtitle: subtitle,
        onBack: () {
          if (Navigator.canPop(context)) {
            Get.back();
          } else {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
        },
        children: [
          PinCodeTextField(
            length: 6,
            appContext: context,
            keyboardType: TextInputType.number,
            animationType: AnimationType.slide,
            mainAxisAlignment: MainAxisAlignment.center,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              fieldHeight: 48,
              fieldWidth: (width - 88) / 6,
              borderWidth: 1,
              activeBorderWidth: 1,
              inactiveBorderWidth: 1,
              errorBorderWidth: 1,
              selectedBorderWidth: 1,
              borderRadius: BorderRadius.circular(kRadiusMd),
              selectedColor: authController.isWrongOtpSubmitted ? context.kDestructive : context.kForeground,
              selectedFillColor: context.kCard,
              inactiveFillColor: context.kCard,
              inactiveColor: context.kInputBorder,
              activeColor: authController.isWrongOtpSubmitted ? context.kDestructive : context.kForeground,
              activeFillColor: context.kCard,
              errorBorderColor: context.kDestructive,
            ),
            textStyle: robotoBold.copyWith(
              fontSize: 18,
              color: context.kForeground,
            ),
            animationDuration: const Duration(milliseconds: 300),
            backgroundColor: Colors.transparent,
            enableActiveFill: true,
            onChanged: authController.updateVerificationCode,
            beforeTextPaste: (text) => true,
            pastedTextStyle: robotoRegular.copyWith(color: context.kForeground),
            separatorBuilder: (context, index){
              return const SizedBox(width: 8,);
            },
          ),

          if (authController.isWrongOtpSubmitted)
            Text('incorrect_otp'.tr,
              style: robotoRegular.copyWith(fontSize: 12, color: context.kDestructive),
              textAlign: TextAlign.center,
            ),

          if (widget.identity != null && widget.identity!.isNotEmpty && _seconds! > 0)
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                children: [
                  TextSpan(
                    text: '${'resend_code'.tr} ',
                    style: robotoRegular.copyWith(
                      fontSize: 12,
                      color: context.kMutedForeground,
                    ),
                  ),
                  TextSpan(
                    text: _formatSeconds(),
                    style: robotoBold.copyWith(
                      fontSize: 12,
                      color: context.kForeground,
                    ),
                  ),
                ],
              ),
            ),

          KButton(
            label: (authController.isLoading ?? false) ? 'loading'.tr : 'verify_code'.tr,
            height: 48,
            onTap: authController.verificationCode.length == 6 && !(authController.isLoading ?? false)
                ? (){
                    _otpVerify(_identity!,widget.identityType, authController.verificationCode,authController);
                  }
                : null,
          ),

          if (widget.identity != null && widget.identity!.isNotEmpty)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _seconds! < 1 ? () {

                  var config = Get.find<SplashController>().configModel?.content;
                  SendOtpType  type = config?.firebaseOtpVerification == 1 && widget.identityType == "phone"
                      ? SendOtpType.firebase : SendOtpType.forgetPassword;

                  authController.sendVerificationCode(identity: _identity!, identityType: widget.identityType, type: type, resendOtp: true).then((status){
                    if(status !=null){
                      if (status.isSuccess!) {
                        _startTimer();
                        showCustomSnackBar('resend_code_successful'.tr, type : ToasterMessageType.success);
                      } else {
                        showCustomSnackBar(status.message);
                      }
                    }
                  });

                } : null,
                borderRadius: BorderRadius.circular(kRadiusMd),
                child: SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      'resend_code'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: 14,
                        color: _seconds! < 1 ? context.kForeground : context.kMutedForeground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  void _otpVerify(String identity,String identityType,String otp, AuthController authController) async {

    var config = Get.find<SplashController>().configModel?.content;
    var firebaseOtp = (config?.firebaseOtpVerification == 1) && identityType == "phone";

   if(firebaseOtp){
     authController.verifyOtpForFirebaseOtp(session: widget.firebaseSession, phone: identity, code: otp).then((status){
       if (status.isSuccess!) {
         Get.offNamed(RouteHelper.getChangePasswordRoute(identity,identityType,otp,1));
       }else {
         showCustomSnackBar(status.message);
       }
     });
   }else{
     authController.verifyOtpForForgetPasswordScreen(identity,identityType,otp).then((status) async {
       if (status.isSuccess!) {
         Get.offNamed(RouteHelper.getChangePasswordRoute(identity,identityType,otp,0));
       }else {
         showCustomSnackBar(status.message);
       }
     });
   }
  }
}
