import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class OtpVerificationBottomSheet extends StatefulWidget {
  final String? bookingId;
  final bool isSubBooking;
  const OtpVerificationBottomSheet({super.key, this.bookingId, required this.isSubBooking});

  @override
  State<OtpVerificationBottomSheet> createState() => _OtpVerificationBottomSheetState();
}

class _OtpVerificationBottomSheetState extends State<OtpVerificationBottomSheet> {
  @override
  void initState() {
    super.initState();
    Get.find<BookingDetailsController>().setOtp('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.kCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusLg)),
        border: Border(top: BorderSide(color: context.kBorder, width: 1)),
      ),
      child: GetBuilder<BookingDetailsController>(builder: (bookingDetailsController) {
        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Container(
              height: 5, width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kRadiusMd),
                color: context.kMuted,
              ),
            ),

            Column(children: [
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('otp_verification'.tr,
                style: robotoBold.copyWith(
                  color: context.kForeground,
                  fontSize: Dimensions.fontSizeLarge ,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('enter_otp_number'.tr, style: robotoRegular.copyWith(color: context.kMutedForeground), textAlign: TextAlign.center),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              SizedBox(
                width: 260,
                child: PinCodeTextField(
                  length: 6,
                  appContext: context,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.slide,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    fieldHeight: 30,
                    fieldWidth: 30,
                    borderWidth: 2,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    selectedColor: bookingDetailsController.isWrongOtpSubmitted ? context.kDestructive : context.kPrimary,
                    selectedFillColor: context.kCard,
                    inactiveFillColor: context.kCard,
                    inactiveColor: context.kInputBorder,
                    activeColor: bookingDetailsController.isWrongOtpSubmitted ? context.kDestructive : context.kPrimary.withValues(alpha:0.7),
                    activeFillColor: context.kCard,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  onChanged: (String text) => bookingDetailsController.setOtp(text),
                  beforeTextPaste: (text) => true,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              bookingDetailsController.isWrongOtpSubmitted ?
              Text('wrong_otp_number'.tr, style: robotoRegular.copyWith(color: context.kDestructive), textAlign: TextAlign.center) :
              !bookingDetailsController.isWrongOtpSubmitted  && !bookingDetailsController.isUpdate ? Text('collect_otp_from_customer'.tr, style: robotoRegular.copyWith(color: context.kMutedForeground), textAlign: TextAlign.center):
              const Text(""),
              const SizedBox(height: Dimensions.paddingSizeLarge),

            ]) ,

            CustomButton(
              btnTxt:  'submit'.tr, radius: Dimensions.radiusDefault,
              isLoading: bookingDetailsController.isUpdate,
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              onPressed: (bookingDetailsController.otp.length != 6) ? null : () async {
                bookingDetailsController.resetWrongOtpValue();
                bookingDetailsController.changeBookingStatus( bookingId: widget.bookingId!, bookingStatus:  "completed", isSubBooking: widget.isSubBooking,isBack: true);
              },
            ),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'did_not_get_any_OTP'.tr,
                style: robotoRegular.copyWith(color: context.kMutedForeground, fontSize: Dimensions.fontSizeDefault),
              ),
              bookingDetailsController.hideResendButton ?  Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: SizedBox(height: Dimensions.fontSizeLarge, width:  Dimensions.fontSizeLarge, child: const CircularProgressIndicator(),),
              ) : InkWell(
                onTap: () async {
                  bool resend = await bookingDetailsController.sendBookingOTPNotification(widget.bookingId);

                  if(resend){
                    showCustomSnackBar("otp_resend_successfully".tr, type : ToasterMessageType.success);
                  }else{

                  }
                },
                child: Text(
                  'resend_it'.tr,
                  style: robotoMedium.copyWith(color: context.kPrimary, fontSize: Dimensions.fontSizeDefault),
                ),
              )
            ]),

            const SizedBox(height: Dimensions.paddingSizeLarge),
          ]),
        );
      }),
    );
  }
}
