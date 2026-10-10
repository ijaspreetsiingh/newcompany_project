import 'package:jassdbx_provider/common/widgets/loading_overlay_widget.dart';
import 'package:jassdbx_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:jassdbx_provider/feature/booking_requests/controller/calender_order_filter_controller.dart';
import 'package:jassdbx_provider/feature/booking_requests/widgets/active_filters_display_widget.dart';
import 'package:jassdbx_provider/feature/booking_requests/widgets/calendar_filter_bottom_sheet.dart';
import 'package:jassdbx_provider/feature/booking_requests/widgets/calender_order_list_dialog_widget.dart';
import 'package:jassdbx_provider/feature/booking_requests/widgets/month_calendar_grid_widget.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class CalendarOrderScreen extends StatefulWidget {
  const CalendarOrderScreen({super.key});

  @override
  State<CalendarOrderScreen> createState() => _CalendarOrderScreenState();
}

class _CalendarOrderScreenState extends State<CalendarOrderScreen> {

  /// Selected day of the displayed month (pure view state — the real booking
  /// data of the month is already loaded by the controller).
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<BookingCalendarController>();

    // Reset to initial state (month view, current date)
    controller.resetToInitialState();
    Get.find<CalenderOrderFilterController>().resetFilter();

    controller.loadBookingsForCurrentView();
  }

  DateTime _effectiveSelectedDay(BookingCalendarController controller){
    final DateTime displayedMonth = controller.selectedDate;
    final DateTime? stored = _selectedDay;
    if(stored != null && stored.year == displayedMonth.year && stored.month == displayedMonth.month){
      return stored;
    }
    final DateTime now = DateTime.now();
    if(now.year == displayedMonth.year && now.month == displayedMonth.month){
      return now;
    }
    return displayedMonth;
  }

  void _openBookingDetails(CalenderBooking booking){
    if(booking.isRepeatBooking ?? false){
      Get.toNamed(RouteHelper.getRepeatBookingDetailsRoute(bookingId : booking.id));
    }else{
      Get.toNamed(RouteHelper.getBookingDetailsRoute(bookingId : booking.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        child: GetBuilder<BookingCalendarController>(
          builder: (controller) {
            final DateTime selectedDay = _effectiveSelectedDay(controller);
            final List<CalenderBooking> dayBookings = controller.getBookingsForDate(selectedDay);
            final List<CalenderBooking> visibleBookings = dayBookings.length > 4
                ? dayBookings.sublist(0, 4)
                : dayBookings;

            return LoadingOverlayWidget(
              isLoading: controller.isLoading,
              child: Column(
                children: [

                  InkTopBar(
                    title: controller.getFormattedDateRange(),
                    onBack: () => Navigator.of(context).canPop()
                        ? Navigator.pop(context)
                        : Get.offAllNamed(RouteHelper.getInitialRoute()),
                    right: InkIconButton(
                      icon: Icons.filter_list,
                      filled: controller.hasActiveFilters(),
                      onTap: () => showCustomBottomSheet(child: const CalendarFilterBottomSheet()),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 8),
                      children: [

                        const ActiveFiltersDisplayWidget(),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MonthCalendarGridWidget(
                            controller: controller,
                            selectedDay: selectedDay,
                            onSelectDay: (day) => setState(() => _selectedDay = day),
                          ),
                        ),

                        const SizedBox(height: 24),

                        InkSection(
                          title: "${selectedDay.day} ${DateConverter.dateStringMonthYear(selectedDay, format: 'MMMM')} · ${dayBookings.length} jobs",
                          action: dayBookings.length > visibleBookings.length ? 'view_all'.tr : null,
                          onAction: () => showCustomBottomSheet(
                            child: CalenderOrderListDialogWidget(bookings: dayBookings),
                          ),
                          child: dayBookings.isEmpty
                              ? InkEmptyState('no_bookings'.tr)
                              : Column(
                                  children: [
                                    for (final CalenderBooking booking in visibleBookings)
                                      _buildBookingRow(context, booking),
                                  ],
                                ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingRow(BuildContext context, CalenderBooking booking){
    final String timeLabel = DateConverter.convertDateTimeToTime(booking.serviceSchedule);
    final List<String> timeParts = timeLabel.split(' ');

    return InkCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => _openBookingDetails(booking),
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
