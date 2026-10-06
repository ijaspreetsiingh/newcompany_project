import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class BookingRequestItem extends StatelessWidget {
  final BookingRequestModel? bookingRequestModel;
  final RepeatBooking? repeatBooking;
  final VoidCallback? onDecline;
  final VoidCallback? onAccept;
  const BookingRequestItem({
    super.key,  this.bookingRequestModel, this.repeatBooking, this.onDecline, this.onAccept});

  @override
  Widget build(BuildContext context) {
    final String createdAt =
        repeatBooking?.createdAt ?? bookingRequestModel?.createdAt ?? '';
    String bookingDateText = '';
    if (createdAt.isNotEmpty) {
      bookingDateText = DateConverter.dateMonthYearTime(
        DateConverter.isoUtcStringToLocalDate(createdAt),
      );
    }

    final String serviceLocation =
        repeatBooking?.serviceLocation ?? bookingRequestModel?.serviceLocation ?? '';
    final String location = serviceLocation == 'provider'
        ? 'provider_location'.tr
        : 'customer_location'.tr;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: BookingCard(
        status: repeatBooking?.bookingStatus ??
            bookingRequestModel?.bookingStatus ??
            '',
        id: '#${repeatBooking?.readableId ?? bookingRequestModel?.readableId ?? ''}',
        title: bookingRequestModel?.subCategory?.name ?? '',
        schedule: bookingDateText,
        location: location,
        amount: PriceConverter.convertPrice(
          repeatBooking?.totalBookingAmount ??
              bookingRequestModel?.totalBookingAmount ??
              0,
        ),
        onTap: () => Get.toNamed(
          RouteHelper.getBookingDetailsRoute(
            bookingId: repeatBooking?.id ?? bookingRequestModel!.id!,
            isSubBooking: repeatBooking != null,
          ),
        ),
        onDecline: onDecline,
        onAccept: onAccept,
      ),
    );
  }
}

Widget bookingDate(String dateType,String date){
  return Builder(
    builder: (context) {
      return Row(
        children: [
          Text(dateType, style: robotoRegularLow.copyWith(color: Theme.of(context).secondaryHeaderColor)),
          Text(
            textDirection: TextDirection.ltr,
            DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(date)),
            style: robotoRegularLow.copyWith(color: Theme.of(context).secondaryHeaderColor)
          ),
        ],
      );
    }
  );
}
