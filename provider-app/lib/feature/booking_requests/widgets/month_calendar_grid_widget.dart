import 'package:jassdbx_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:jassdbx_provider/feature/booking_requests/widgets/calender_header_widget.dart';
import 'package:jassdbx_provider/feature/booking_requests/widgets/month_cell_order_count_widget.dart';
import 'package:jassdbx_provider/util/core_export.dart';

/// Design month grid card: weekday header, day cells with per-day booking
/// status dots driven by the real month data of [BookingCalendarController]
/// and the Confirmed / Completed / Cancelled legend.
class MonthCalendarGridWidget extends StatelessWidget {
  final BookingCalendarController controller;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectDay;

  const MonthCalendarGridWidget({
    super.key,
    required this.controller,
    required this.selectedDay,
    required this.onSelectDay,
  });

  static const List<String> _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  Color _dotColorForStatus(String? status) {
    switch ((status ?? "").toLowerCase()) {
      case 'canceled':
      case 'cancelled':
        return InkColors.destructive;
      case 'completed':
        return InkColors.mutedForeground;
      default:
        return InkColors.foreground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime displayedMonth = controller.selectedDate;
    final DateTime firstOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final int daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final int leadingBlanks = firstOfMonth.weekday % 7;

    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(displayedMonth.year, displayedMonth.month, day);
      final List<CalenderBooking> bookings = controller.getBookingsForDate(date);
      final List<Color> dots = <Color>[];
      for (final CalenderBooking booking in bookings) {
        if (dots.length >= 3) break;
        dots.add(_dotColorForStatus(booking.bookingStatus));
      }

      cells.add(MonthCellOrderCountWidget(
        day: date,
        isSelected: date.year == selectedDay.year &&
            date.month == selectedDay.month &&
            date.day == selectedDay.day,
        dotColors: dots,
        isWithinFilterRange: DateConverter.isDateWithinRange(
          date,
          startDate: controller.filterStartDate,
          endDate: controller.filterEndDate,
        ),
        onTap: () => onSelectDay(date),
      ));
    }

    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        final double velocity = details.primaryVelocity ?? 0;
        if (velocity < -60 && controller.canNavigateNext()) {
          controller.navigateNext();
        } else if (velocity > 60 && controller.canNavigatePrevious()) {
          controller.navigatePrevious();
        }
      },
      child: InkCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CalenderHeaderWidget(),
            const SizedBox(height: 12),

            Row(
              children: [
                for (final String dayLabel in _weekDays)
                  Expanded(
                    child: Center(
                      child: Text(
                        dayLabel,
                        style: robotoBold.copyWith(
                          fontSize: 11,
                          height: 1.2,
                          letterSpacing: 1,
                          color: InkColors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
              children: cells,
            ),

            const SizedBox(height: 16),

            Container(
              decoration:  BoxDecoration(
                border: Border(top: BorderSide(color: InkColors.border)),
              ),
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children:  [
  _LegendItem(color: InkColors.foreground, label: 'Confirmed'),
                  _LegendItem(color: InkColors.mutedForeground, label: 'Completed'),
                  _LegendItem(color: InkColors.destructive, label: 'Cancelled'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: robotoRegular.copyWith(fontSize: 10.5, height: 1.3, color: InkColors.mutedForeground),
        ),
      ],
    );
  }
}
