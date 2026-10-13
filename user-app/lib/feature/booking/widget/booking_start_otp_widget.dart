import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

/// SPEC: serviceman 300m radius me pahuncha to backend ne START OTP generate
/// kiya — customer ko ye OTP serviceman ko dena hai service start karne se pehle.
class BookingStartOtpWidget extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingStartOtpWidget({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: Get.find<ThemeController>().darkTheme ? null : searchBoxShadow,
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),

      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text('service_start_otp'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7))),
        Text('serviceman_arrived_share_otp'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 5),
          child: RichText(text: TextSpan(text: "${'your_otp_is'.tr} : ",
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 1)),
            children: <TextSpan>[
              TextSpan(
                text: bookingDetails.startOtp?.replaceAll("null", " ") ?? "",
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              )
            ],
          )),
        ),
        const Row(),
      ]),
    );
  }
}
