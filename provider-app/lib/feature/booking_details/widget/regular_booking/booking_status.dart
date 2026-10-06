import 'package:demandium_provider/feature/booking_details/widget/ink_booking_sections.dart';
import 'package:demandium_provider/feature/booking_details/widget/timeline/connectors.dart';
import 'package:demandium_provider/feature/booking_details/widget/timeline/indicator_theme.dart';
import 'package:demandium_provider/feature/booking_details/widget/timeline/indicators.dart';
import 'package:demandium_provider/feature/booking_details/widget/timeline/timeline_theme.dart';
import 'package:demandium_provider/feature/booking_details/widget/timeline/timeline_tile_builder.dart';
import 'package:demandium_provider/feature/booking_details/widget/timeline/timelines.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class BookingStatus extends StatefulWidget {
  final String? bookingId;
  final bool isSubBooking;
  const BookingStatus({super.key,  this.bookingId, required this.isSubBooking});

  @override
  State<BookingStatus> createState() => _BookingStatusState();
}

class _BookingStatusState extends State<BookingStatus> {

  @override
  void initState() {
    super.initState();
    Get.find<BookingDetailsController>().updateServicePageCurrentState(BookingDetailsTabControllerState.status, shouldUpdate: false);
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(builder: (bookingDetailsController){

      final bookingDetailsContent = widget.isSubBooking ? bookingDetailsController.subBookingDetails : bookingDetailsController.bookingDetails;

      if(bookingDetailsContent == null){
        return const Center(child: BookingDetailsShimmer());
      } else if( bookingDetailsContent.content == null){
        return SizedBox(height: Get.height * 0.7, child: BookingEmptyScreen (bookingId: widget.bookingId,));
      }else{
        final bookingDetails = bookingDetailsContent.content!;

        final DateTime? createdAt = bookingDetails.createdAt != null
            ? DateConverter.isoUtcStringToLocalDate(bookingDetails.createdAt!)
            : null;
        final DateTime? schedule = bookingDetails.serviceSchedule != null
            ? DateTime.tryParse(bookingDetails.serviceSchedule!)
            : null;

        final List<StatusHistories> statusHistories = bookingDetails.statusHistories ?? <StatusHistories>[];
        final List<ScheduleHistories> scheduleHistories = bookingDetails.scheduleHistories ?? <ScheduleHistories>[];

        final int increment = scheduleHistories.length > 1 && statusHistories.isNotEmpty ? 2 : 1;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: InkCard(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(children: [

              InkInfoRow(
                label: 'booking_date'.tr,
                value: createdAt != null ? DateConverter.dateMonthYearTime(createdAt) : "-",
              ),
               Divider(height: 1, color: InkColors.border),

              InkInfoRow(
                label: 'scheduled_date'.tr,
                value: schedule != null ? DateConverter.dateMonthYearTime(schedule) : "-",
              ),
               Divider(height: 1, color: InkColors.border),

              InkInfoRow(
                label: 'payment_status'.tr,
                value: bookingDetails.isPaid == 1 ? 'paid'.tr : 'unpaid'.tr,
                valueColor: bookingDetails.isPaid == 1 ? Colors.green : InkColors.destructive,
              ),
               Divider(height: 1, color: InkColors.border),

              InkInfoRow(
                label: 'Booking_Status'.tr,
                value: (bookingDetails.bookingStatus ?? "").tr,
                valueColor: context.customThemeColors.buttonTextColorMap[bookingDetails.bookingStatus],
              ),

               Divider(height: 1, color: InkColors.border),

              Timeline1(
                bookingDetails: bookingDetails,
                statusHistories: statusHistories,
                scheduleHistories: scheduleHistories,
                increment: increment,
              ),

            ]),
          ),
        );
      }
    });
  }
}

class Timeline1 extends StatelessWidget {
  final BookingDetailsContent? bookingDetails;
 final List<StatusHistories>? statusHistories;
 final List<ScheduleHistories>? scheduleHistories;
 final int increment;
 const Timeline1({super.key, required this.statusHistories, this.scheduleHistories, required this.increment, this.bookingDetails});

  /// Safe accessor: never throws when the API returns fewer entries than the
  /// tile layout expects (empty / shorter history lists).
  StatusHistories? _statusAt(int index) {
    final List<StatusHistories>? list = statusHistories;
    if (list == null || index < 0 || index >= list.length) return null;
    return list[index];
  }

  ScheduleHistories? _scheduleAt(int index) {
    final List<ScheduleHistories>? list = scheduleHistories;
    if (list == null || index < 0 || index >= list.length) return null;
    return list[index];
  }

  String _userLabel(User? user, {String? fallbackFirstName, String? fallbackLastName, String fallback = ""}) {
    if (user != null) {
      return '${user.firstName ?? ""} ${user.lastName ?? ""}'.trim();
    }
    final String fallbackName = '${fallbackFirstName ?? ""} ${fallbackLastName ?? ""}'.trim();
    return fallbackName.isEmpty ? fallback : fallbackName;
  }

  String? _readableTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    final DateTime? parsed = DateTime.tryParse(isoString);
    if (parsed == null) return null;
    return DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(parsed.toIso8601String()));
  }

  /// index 0 -> "booking placed by ..." (falls back to the customer record
  /// when schedule history is missing).
  Widget _placedByRow() {
    final ScheduleHistories? firstSchedule = _scheduleAt(0);
    final User? scheduleUser = firstSchedule?.user;

    final String name = scheduleUser != null
        ? _userLabel(scheduleUser)
        : _userLabel(
            null,
            fallbackFirstName: bookingDetails?.customer?.firstName,
            fallbackLastName: bookingDetails?.customer?.lastName,
            fallback: 'customer'.tr,
          );

    final String? time = _readableTime(firstSchedule?.createdAt ?? bookingDetails?.createdAt);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${'booking_placed_by'.tr} ${name.isEmpty ? 'customer'.tr : name}",
          style: robotoRegular.copyWith(fontSize: 13, height: 1.4, color: InkColors.foreground),
        ),
        const SizedBox(height: 6),
        if (time != null)
          Text(
            time,
            style: robotoRegular.copyWith(fontSize: 11, color: InkColors.mutedForeground),
            textDirection: TextDirection.ltr,
          ),
        const SizedBox(height: 4),
      ],
    );
  }

  /// index 1 -> first status change.
  Widget _firstStatusRow() {
    final StatusHistories? status = _statusAt(0);
    if (status == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${'booking'.tr} ${status.bookingStatus.toString().tr.toLowerCase()} ${'by'.tr} "
          "${status.user?.userType.toString().tr} ",
          style: robotoRegular.copyWith(fontSize: 13, height: 1.4, color: InkColors.foreground),
        ),
        const SizedBox(height: 6),
        Text(
          status.user?.userType != 'provider-admin'
              ? _userLabel(status.user)
              : (Get.find<UserProfileController>().providerModel?.content?.providerInfo?.companyName ?? ""),
          style: robotoRegular.copyWith(fontSize: 11, color: InkColors.mutedForeground),
        ),
        const SizedBox(height: 6,),
        if (status.updatedAt != null)
          Text(
            _readableTime(status.updatedAt) ?? "",
            style: robotoRegular.copyWith(fontSize: 11, color: InkColors.mutedForeground),
            textDirection: TextDirection.ltr,
          ),
        const SizedBox(height: 14,),
      ],
    );
  }

  /// index 2 -> every schedule change after the first booking schedule.
  Widget _scheduleChangesRow() {
    final List<ScheduleHistories> schedules = scheduleHistories ?? const <ScheduleHistories>[];
    final int changes = schedules.length - 1;
    if (changes <= 0) return const SizedBox.shrink();

    return SizedBox(
      height: changes * 80,
      child: ListView.builder(
        itemBuilder: (context, i) {
          final ScheduleHistories? entry = _scheduleAt(i + 1);
          if (entry == null) return const SizedBox.shrink();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${'booking_schedule_changed_by'.tr} ${entry.user?.userType.toString().tr ?? ""}",
                style: robotoRegular.copyWith(fontSize: 13, height: 1.4, color: InkColors.foreground),
              ),
              const SizedBox(height: 6,),
              if (entry.user?.userType != 'provider-admin')
                Text(
                  _userLabel(entry.user),
                  style: robotoRegular.copyWith(fontSize: 11, color: InkColors.mutedForeground),
                  textDirection: TextDirection.ltr,
                ),
              if (entry.user?.userType == 'provider-admin')
                Text(
                  "${bookingDetails?.provider?.companyName ?? ""} ",
                  style: robotoRegular.copyWith(fontSize: 11, color: InkColors.mutedForeground),
                  textDirection: TextDirection.ltr,
                ),
              const SizedBox(height: 6,),
              if (entry.schedule != null)
                Text(
                  _readableTime(entry.schedule) ?? "",
                  style: robotoRegular.copyWith(fontSize: 11, color: InkColors.mutedForeground),
                  textDirection: TextDirection.ltr,
                ),
              const SizedBox(height: 4,),
            ],
          );
        },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: changes,
      ),
    );
  }

  /// every remaining tile -> one status change.
  Widget _statusRow(int index) {
    final StatusHistories? status = _statusAt(index - increment);
    if (status == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${'booking'.tr} ${status.bookingStatus.toString().tr.toLowerCase()} ${'by'.tr} "
          "${status.user?.userType.toString().tr} ",
          style: robotoRegular.copyWith(fontSize: 13, height: 1.4, color: InkColors.foreground),
        ),
        const SizedBox(height: 6),
        Text(
          status.user?.userType != 'provider-admin'
              ? _userLabel(status.user)
              : (Get.find<UserProfileController>().providerModel?.content?.providerInfo?.companyName ?? ""),
          style: robotoRegular.copyWith(fontSize: 11, color: InkColors.mutedForeground),
        ),
        const SizedBox(height: 6),
        if (status.updatedAt != null)
          Text(
            _readableTime(status.updatedAt) ?? "",
            style: robotoRegular.copyWith(fontSize: 11, color: InkColors.mutedForeground),
            textDirection: TextDirection.ltr,
          ),
        const SizedBox(height: 14,),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final int items = (statusHistories?.length ?? 0) + increment;

    return Timeline.tileBuilder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      theme: TimelineThemeData(
      nodePosition: 0,
      indicatorTheme: const IndicatorThemeData(position: 0, size: 30.0)),
      padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: Get.find<LocalizationController>().isLtr?14:24),
      builder: TimelineTileBuilder.connected(connectionDirection: ConnectionDirection.before,

        itemCount: items,

        contentsBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20.0, top: 7, right: 10),
            child: index == 0
                ? _placedByRow()
                : (index == 1 && _statusAt(0) != null)
                    ? _firstStatusRow()
                    : (index == 2 && _scheduleAt(1) != null)
                        ? _scheduleChangesRow()
                        : _statusRow(index),
          );
        },

        connectorBuilder: (_, index, _) =>  SolidLineConnector(color: InkColors.border),

        indicatorBuilder: (_, index) {
          return  DotIndicator(
            color: InkColors.foreground,
            child: Center(child : Icon(Icons.check,color: InkColors.background, size: 16,)),
          );
        },
      ),
    );
  }
}
