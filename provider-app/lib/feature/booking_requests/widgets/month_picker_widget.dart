import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/feature/booking_requests/controller/calendar_controller.dart';

/// Builds PopupMenuItems for month selection
/// Returns a list of `PopupMenuItem<DateTime>` for all 12 months of the given year
List<PopupMenuItem<DateTime>> buildMonthPickerItems({
  required DateTime currentSelectedDate,
  required BuildContext context,
  double? containerWidth,
}) {
  final List<PopupMenuItem<DateTime>> items = [];
  final controller = Get.find<BookingCalendarController>();

  for (int month = 1; month <= 12; month++) {
    final monthDate = DateTime(currentSelectedDate.year, month, 1);
    final isSelected = monthDate.month == currentSelectedDate.month &&
        monthDate.year == currentSelectedDate.year;

    final isDisabled = controller.isPeriodDisabled(
      monthDate,
      DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59),
    );

    items.add(
      PopupMenuItem<DateTime>(
        value: monthDate,
        padding: EdgeInsets.zero,
        enabled: !isDisabled,
        child: SizedBox(
          width: containerWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Text(
              DateConverter.dateStringMonthYear(monthDate, format: 'MMMM y'),
              style: robotoMedium.copyWith(
                fontSize: 13,
                height: 1.3,
                color: isDisabled
                    ? InkColors.accent
                    : isSelected
                    ? InkColors.foreground
                    : InkColors.mutedForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  return items;
}
