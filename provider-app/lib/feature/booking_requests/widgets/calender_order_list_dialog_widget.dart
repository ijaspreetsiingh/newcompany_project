import 'package:jassdbx_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:jassdbx_provider/feature/booking_requests/widgets/booking_item_card.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class CalenderOrderListDialogWidget extends StatelessWidget {
  final List<CalenderBooking> bookings;

  const CalenderOrderListDialogWidget({
    super.key,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final BookingCalendarController controller = Get.find<BookingCalendarController>();


    return Container(
      constraints: BoxConstraints(
        maxHeight: size.height * 0.8,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: InkColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Title
          Text(
            '${'booking_list'.tr} · ${DateConverter.dateStringMonthYear(bookings.isEmpty ? null : bookings.first.serviceSchedule, format: 'd MMM, y')}',
            style: robotoBold.copyWith(
              fontSize: 15,
              height: 1.3,
              letterSpacing: -0.2,
              color: InkColors.foreground,
            ),
          ),
          const SizedBox(height: 16),

          // Bookings List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                return BookingItemCard(
                  booking: bookings[index],
                  controller: controller,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
