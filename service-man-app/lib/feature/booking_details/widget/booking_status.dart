import 'package:jassdbx_serviceman/feature/booking_details/widget/booking_details_widget.dart';
import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';

class BookingStatus extends StatelessWidget {
  final String? bookingId;
  const BookingStatus({super.key, this.bookingId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(builder: (bookingDetailsController) {

      final bookingDetailsModel = bookingDetailsController.bookingDetails;
      final bookingDetails = bookingDetailsModel?.bookingContent?.bookingDetailsContent;

      if (bookingDetailsModel == null && bookingDetails == null) {
        return const Center(child: BookingDetailsShimmer());
      } else if (bookingDetailsModel != null && bookingDetails == null) {
        return SizedBox(height: Get.height * 0.7, child: BookingEmptyScreen(bookingId: bookingId));
      }

      final statusHistories = bookingDetails!.statusHistories ?? [];
      final scheduleHistories = bookingDetails.scheduleHistories ?? [];

      String createdAtText = '';
      if (bookingDetails.createdAt != null) {
        createdAtText = DateConverter.dateMonthYearTime(
            DateConverter.isoUtcStringToLocalDate(bookingDetails.createdAt!));
      }

      String scheduleText = '-';
      final DateTime? scheduleAt = bookingDetails.serviceSchedule != null
          ? DateTime.tryParse(bookingDetails.serviceSchedule!)
          : null;
      if (scheduleAt != null) {
        scheduleText = DateConverter.dateMonthYearTime(scheduleAt);
      }

      final bool isPartial = bookingDetails.partialPayments != null &&
          bookingDetails.partialPayments!.isNotEmpty;
      final String paidLabel = isPartial && bookingDetails.isPaid == 0
          ? 'partially_paid'.tr
          : bookingDetails.isPaid == 0 ? 'unpaid'.tr : 'paid'.tr;
      final Color paidColor = isPartial && bookingDetails.isPaid == 0
          ? context.kPrimary
          : bookingDetails.isPaid == 0 ? context.kDestructive : context.kSuccess;

      final List<_TimelineStep> steps = _buildSteps(
        bookingDetails: bookingDetails,
        statusHistories: statusHistories,
        scheduleHistories: scheduleHistories,
      );

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            KCard(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _summaryRow(
                  context,
                  'booking_date'.tr,
                  Text(createdAtText.isNotEmpty ? createdAtText : '-',
                      textDirection: TextDirection.ltr,
                      style: robotoMedium.copyWith(fontSize: 14, color: context.kForeground)),
                ),
                _divider(context),
                _summaryRow(
                  context,
                  'schedule_date'.tr,
                  Text(scheduleText,
                      textDirection: TextDirection.ltr,
                      style: robotoMedium.copyWith(fontSize: 14, color: context.kForeground)),
                ),
                _divider(context),
                _summaryRow(
                  context,
                  'payment_status'.tr.trimRight(),
                  Text(paidLabel,
                      style: robotoMedium.copyWith(fontSize: 14, color: paidColor)),
                ),
                _divider(context),
                _summaryRow(
                  context,
                  'booking_status'.tr,
                  StatusBadge(status: bookingDetails.bookingStatus ?? ''),
                ),
              ]),
            ),

            if (statusHistories.isNotEmpty) ...[
              const SizedBox(height: 20),
              for (int i = 0; i < steps.length; i++)
                _timelineStep(context, steps[i], i + 1, i == steps.length - 1),
            ],

          ]),
        ),
      );
    });
  }

  Widget _divider(BuildContext context) {
    return Container(height: 1, color: context.kBorder, margin: const EdgeInsets.symmetric(vertical: 4));
  }

  Widget _summaryRow(BuildContext context, String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(
          child: Text(label,
              style: robotoRegular.copyWith(fontSize: 12, color: context.kMutedForeground)),
        ),
        const SizedBox(width: 12),
        value,
      ]),
    );
  }

  List<_TimelineStep> _buildSteps({
    required BookingDetailsContent bookingDetails,
    required List<StatusHistories> statusHistories,
    required List<ScheduleHistories> scheduleHistories,
  }) {

    final List<_TimelineStep> steps = [];

    String placedName = 'customer'.tr;
    String placedDate = '';
    if (scheduleHistories.isNotEmpty) {
      final user = scheduleHistories[0].user;
      placedName = user != null
          ? "${user.firstName ?? ''} ${user.lastName ?? ''}".trim()
          : 'customer'.tr;
      if (scheduleHistories[0].createdAt != null) {
        placedDate = DateConverter.dateMonthYearTime(
            DateConverter.isoUtcStringToLocalDate(scheduleHistories[0].createdAt!));
      }
    }
    if (placedDate.isEmpty && bookingDetails.createdAt != null) {
      placedDate = DateConverter.dateMonthYearTime(
          DateConverter.isoUtcStringToLocalDate(bookingDetails.createdAt!));
    }
    steps.add(_TimelineStep(
      title: "${'booking_placed_by'.tr} $placedName",
      time: placedDate,
      done: true,
      sortKey: _parse(bookingDetails.createdAt),
    ));

    final List<_TimelineStep> events = [];

    for (final history in statusHistories) {
      final isProviderAdmin = history.user?.userType == 'provider-admin';
      final name = isProviderAdmin
          ? (bookingDetails.provider?.companyName ??
              bookingDetails.subBooking?.provider?.companyName ??
              '')
          : "${history.user?.firstName ?? ''} ${history.user?.lastName ?? ''}".trim();
      String date = '';
      if (history.updatedAt != null) {
        date = DateConverter.dateMonthYearTime(
            DateConverter.isoUtcStringToLocalDate(history.updatedAt!));
      }
      events.add(_TimelineStep(
        title: "${'booking'.tr} ${history.bookingStatus.toString().tr.toLowerCase()} ${'by'.tr} ${history.user?.userType?.tr ?? ''}".trim(),
        name: name,
        time: date,
        done: true,
        sortKey: _parse(history.updatedAt) ?? _parse(history.createdAt),
      ));
    }

    if (scheduleHistories.length > 1) {
      for (int i = 1; i < scheduleHistories.length; i++) {
        final history = scheduleHistories[i];
        final isProviderAdmin = history.user?.userType == 'provider-admin';
        final name = isProviderAdmin
            ? (bookingDetails.provider?.companyName ?? '')
            : "${history.user?.firstName ?? ''} ${history.user?.lastName ?? ''}".trim();
        String date = '';
        if (history.schedule != null) {
          date = DateConverter.dateMonthYearTime(DateTime.tryParse(history.schedule!));
        }
        events.add(_TimelineStep(
          title: "${'booking_schedule_changed_by'.tr} ${history.user?.userType?.tr ?? ''}".trim(),
          name: name,
          time: date,
          done: true,
          sortKey: _parse(history.createdAt) ?? _parse(history.schedule),
        ));
      }
    }

    events.sort((a, b) => (a.sortKey ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(b.sortKey ?? DateTime.fromMillisecondsSinceEpoch(0)));
    steps.addAll(events);

    const List<String> statusOrder = ['pending', 'accepted', 'ongoing', 'completed'];
    final String currentStatus = bookingDetails.bookingStatus?.toLowerCase() ?? '';
    final int currentIndex = statusOrder.indexOf(currentStatus);
    final Set<String> seen = statusHistories
        .map((e) => (e.bookingStatus ?? '').toLowerCase())
        .toSet();

    if (currentIndex >= 0) {
      for (int i = currentIndex + 1; i < statusOrder.length; i++) {
        final String status = statusOrder[i];
        if (!seen.contains(status)) {
          steps.add(_TimelineStep(
            title: "${'booking'.tr} ${status.tr.toLowerCase()}",
            time: 'pending'.tr,
            done: false,
          ));
        }
      }
    }

    return steps;
  }

  DateTime? _parse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  Widget _timelineStep(BuildContext context, _TimelineStep step, int number, bool isLast) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 27,
          height: 27,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: step.done ? context.kSuccess : context.kCard,
            border: step.done ? null : Border.all(color: context.kBorder, width: 1),
          ),
          child: step.done
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : Text('$number',
                  style: robotoBold.copyWith(fontSize: 12, color: context.kForeground)),
        ),
        if (!isLast) Container(width: 1, height: 48, color: context.kBorder),
      ]),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(step.title,
                style: robotoMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.kForeground)),
            if (step.name.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(step.name,
                  style: robotoRegular.copyWith(
                      fontSize: 12, color: context.kMutedForeground)),
            ],
            if (step.time.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(step.time,
                  textDirection: TextDirection.ltr,
                  style: robotoRegular.copyWith(
                      fontSize: 12, color: context.kMutedForeground)),
            ],
          ]),
        ),
      ),
    ]);
  }
}

class _TimelineStep {
  final String title;
  final String name;
  final String time;
  final bool done;
  final DateTime? sortKey;

  const _TimelineStep({
    required this.title,
    this.name = '',
    this.time = '',
    required this.done,
    this.sortKey,
  });
}
