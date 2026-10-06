import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class BookingDetailsProviderInfo extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingDetailsProviderInfo({super.key, required this.bookingDetails}) ;

  @override
  Widget build(BuildContext context) {
    return Column( crossAxisAlignment: CrossAxisAlignment.start ,children: [

      CaptionTitle('zone_admin'.tr),
      const SizedBox(height: 12),

      KCard(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: BottomCard(
          name: bookingDetails.provider?.companyName ??  bookingDetails.subBooking?.provider?.companyName ?? "",
          phone: bookingDetails.provider?.companyPhone ?? bookingDetails.subBooking?.provider?.companyPhone ?? "",
          image:  bookingDetails.provider?.logoFullPath ?? bookingDetails.subBooking?.provider?.logoFullPath ?? "",
        ),
      ),

    ]);
  }
}
