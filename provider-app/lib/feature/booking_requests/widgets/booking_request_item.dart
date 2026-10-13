import 'package:jassdbx_provider/helper/booking_helper.dart';
import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class BookingRequestItem extends StatelessWidget {
  final BookingRequestModel booking;
  const BookingRequestItem({
    super.key, required this.booking,});

  @override
  Widget build(BuildContext context) {

    final String serviceName = booking.subCategory?.name ?? "";
    final String code = "#${booking.readableId ?? ""}";
    final String bookingTypeLabel = booking.isRepeatBooking == 1 ? "repeat_booking".tr : "regular_booking".tr;
    final DateTime? schedule = _scheduleOf(booking);
    final bool isPending = (booking.bookingStatus ?? "") == "pending";

    return InkCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => _openBookingDetails(booking),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkAvatar(name: serviceName.isNotEmpty ? serviceName : "${'booking'.tr} $code", size: 40),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            serviceName.isNotEmpty ? serviceName : "${'booking'.tr} $code",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          code,
                          maxLines: 1,
                          style: robotoRegular.copyWith(fontSize: 10, height: 1.3, color: InkColors.mutedForeground),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bookingTypeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(fontSize: 12.5, height: 1.3, color: InkColors.mutedForeground),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              InkStatusChip(status: booking.bookingStatus ?? ""),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            decoration:  BoxDecoration(
              border: Border(top: BorderSide(color: InkColors.border)),
            ),
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    schedule != null
                        ? "${DateConverter.dateStringMonthYear(schedule, format: 'd MMM, y')} · ${DateConverter.convertDateTimeToTime(schedule)}"
                        : "-",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: 12, height: 1.3, color: InkColors.mutedForeground),
                  ),
                ),
                InkMoney(
                  booking.totalBookingAmount ?? 0,
                  style:  TextStyle(fontSize: 15, height: 1.2, color: InkColors.foreground),
                ),
              ],
            ),
          ),

          // SPEC: provider kabhi accept/decline nahi karega — booking automatic
          // nearest serviceman ko jaati hai. Sirf status chip + details.
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.autorenew, size: 14, color: InkColors.mutedForeground),
                const SizedBox(width: 6),
                Text(
                  'serviceman_searching'.tr,
                  style: robotoMedium.copyWith(fontSize: 12, color: InkColors.mutedForeground),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  DateTime? _scheduleOf(BookingRequestModel booking){
    try{
      final String? currentSchedule = BookingHelper.getRepeatBookingCurrentSchedule(booking);
      final DateTime? parsed = currentSchedule != null ? DateTime.tryParse(currentSchedule) : null;
      if(parsed != null) return parsed;
    }catch(_){}
    try{
      if(booking.createdAt != null) return DateConverter.isoUtcStringToLocalDate(booking.createdAt!);
    }catch(_){}
    return null;
  }

  void _openBookingDetails(BookingRequestModel booking){
    if(booking.isRepeatBooking == 1){
      Get.toNamed(RouteHelper.getRepeatBookingDetailsRoute(bookingId : booking.id!));
    }else{
      Get.toNamed(RouteHelper.getBookingDetailsRoute(bookingId : booking.id!));
    }
  }
}
