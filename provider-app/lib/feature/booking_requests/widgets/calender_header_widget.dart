import 'package:jassdbx_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:jassdbx_provider/feature/booking_requests/widgets/month_picker_widget.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Compact month navigation row rendered on top of the calendar card:
/// previous month — selectable month/year (month picker) — next month.
///
/// Keeps the existing controller navigation + filter date range guards.
class CalenderHeaderWidget extends StatelessWidget {
  const CalenderHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingCalendarController>(builder: (controller) {
      return Row(
        children: [
          _NavigationButton(
            icon: Icons.chevron_left_rounded,
            enabled: controller.canNavigatePrevious(),
            onTap: controller.canNavigatePrevious() ? () => controller.navigatePrevious() : null,
          ),

          Expanded(
            child: PopupMenuButton<DateTime>(
              onSelected: (DateTime selectedDate) => controller.navigateToMonth(selectedDate),
              itemBuilder: (BuildContext context) => buildMonthPickerItems(
                currentSelectedDate: controller.selectedDate,
                context: context,
              ),
              offset: const Offset(0, 40),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        controller.getFormattedDateRange(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: displayBold.copyWith(fontSize: 14, height: 1.2, color: InkColors.foreground),
                      ),
                    ),
                     Icon(Icons.arrow_drop_down, size: 20, color: InkColors.mutedForeground),
                  ],
                ),
              ),
            ),
          ),

          _NavigationButton(
            icon: Icons.chevron_right_rounded,
            enabled: controller.canNavigateNext(),
            onTap: controller.canNavigateNext() ? () => controller.navigateNext() : null,
          ),
        ],
      );
    });
  }
}

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _NavigationButton({required this.icon, required this.enabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.3,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          height: 32,
          width: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: InkColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: InkColors.border),
          ),
          child: Icon(icon, size: 18, color: InkColors.foreground),
        ),
      ),
    );
  }
}
