import 'package:jassdbx_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Compact booking row used inside the calendar day list dialog.
///
/// Mirrors the design calendar row: time block, avatar, booking code,
/// amount and status chip. Tapping opens the existing booking details route.
class BookingItemCard extends StatelessWidget {
  /// The booking data to display
  final CalenderBooking booking;

  /// Controller for managing booking-related logic
  final BookingCalendarController controller;

  const BookingItemCard({
    super.key,
    required this.booking,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final String timeLabel = DateConverter.convertDateTimeToTime(booking.serviceSchedule);
    final List<String> timeParts = timeLabel.split(' ');

    return InkCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: (){
        if(booking.isRepeatBooking ?? false){
          Get.toNamed(RouteHelper.getRepeatBookingDetailsRoute(bookingId : booking.id));
        }else{
          Get.toNamed(RouteHelper.getBookingDetailsRoute(bookingId : booking.id));
        }
      },
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeParts.first,
                  style: displayBold.copyWith(fontSize: 13, height: 1.1, color: InkColors.foreground),
                ),
                if (timeParts.length > 1)
                  Text(
                    timeParts.sublist(1).join(' '),
                    style: robotoRegular.copyWith(fontSize: 10, height: 1.2, color: InkColors.mutedForeground),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          InkAvatar(name: booking.readableId.toString(), size: 36),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${'booking'.tr} # ${booking.readableId}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoSemiBold.copyWith(fontSize: 13.5, height: 1.25, color: InkColors.foreground),
                ),
                Text(
                  (booking.isRepeatBooking ?? false) ? "repeat_booking".tr : "regular_booking".tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(fontSize: 11.5, height: 1.3, color: InkColors.mutedForeground),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkMoney(
                booking.totalBookingAmount,
                style:  TextStyle(fontSize: 13, height: 1.2, color: InkColors.foreground),
              ),
              const SizedBox(height: 4),
              InkStatusChip(status: booking.bookingStatus),
            ],
          ),
        ],
      ),
    );
  }
}
