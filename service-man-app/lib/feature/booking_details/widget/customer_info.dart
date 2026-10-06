import 'package:demandium_serviceman/helper/booking_helper.dart';
import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class BookingDetailsCustomerInfo extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingDetailsCustomerInfo({super.key, required this.bookingDetails}) ;

  @override
  Widget build(BuildContext context) {


    return GetBuilder<BookingDetailsController>(
        builder: (bookingDetailsController) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CaptionTitle("customer_info".tr),
            const SizedBox(height: 12),
            KCard(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: BottomCard(
                name: bookingDetails.serviceAddress?.contactPersonName ??  bookingDetails.subBooking?.serviceAddress?.contactPersonName ?? "${ bookingDetails.customer?.firstName??""} ${bookingDetails.customer?.lastName??""}",
                phone:  bookingDetails.serviceAddress?.contactPersonNumber ?? bookingDetails.subBooking?.serviceAddress?.contactPersonNumber ?? bookingDetails.customer?.phone?? bookingDetails.customer?.email??"",
                image: bookingDetails.customer?.profileImageFullPath ??  bookingDetails.subBooking?.customer?.profileImageFullPath ?? "",
                address: BookingHelper.composeServiceAddress(
                  bookingDetails.serviceAddress ?? bookingDetails.subBooking?.serviceAddress,
                  fallback: 'address_not_found'.tr,
                ),
              ),
            )
          ]);
        });
  }
}
