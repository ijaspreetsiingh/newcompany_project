import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/booking_details/model/bookings_details_model.dart';
import 'package:demandium_provider/feature/booking_details/model/assign_suggestion_model.dart';
import 'package:demandium_provider/feature/booking_requests/controller/booking_timer_controller.dart';

/// AUTO-ASSIGN: full-screen booking popup jab provider ko new booking request aati hai.
/// Decision window ke andar provider distance-sorted serviceman list se
/// 1-5 servicemen select karke assign kar sakta hai, ya reject kar sakta hai.
class IncomingBookingPopup extends StatefulWidget {
  final String bookingId;
  const IncomingBookingPopup({super.key, required this.bookingId});

  @override
  State<IncomingBookingPopup> createState() => _IncomingBookingPopupState();
}

class _IncomingBookingPopupState extends State<IncomingBookingPopup> {
  @override
  void initState() {
    super.initState();
    final BookingTimerController controller = Get.put(BookingTimerController(bookingDetailsRepo: Get.find()));
    controller.startTimer(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // back button se popup dismiss na ho
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.95),
        body: SafeArea(
          child: GetBuilder<BookingTimerController>(
            builder: (controller) {
              return Container(
                margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(children: [

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.notifications_active, color: Theme.of(context).primaryColor),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text('new_booking_request'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Expanded(
                    child: controller.bookingDetails != null
                        ? SingleChildScrollView(child: Column(children: [
                            _BookingSummaryCard(bookingDetails: controller.bookingDetails!),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            if (!controller.expired && !controller.assigned && !controller.rejected)
                              _TeamAssignSection(controller: controller),
                          ]))
                        : (controller.expired || controller.assigned || controller.rejected)
                            ? _StatusCard(controller: controller)
                            : const Center(child: CustomLoader()),
                  ),

                  // countdown timer
                  if (!controller.expired && !controller.assigned && !controller.rejected) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.timer, color: controller.remainingSeconds <= 10 ? Colors.red : Theme.of(context).primaryColor),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          _formatDuration(controller.remainingSeconds),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeOverLarge,
                            color: controller.remainingSeconds <= 10 ? Colors.red : Theme.of(context).primaryColor,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],

                  // action buttons: Reject (auto-assign chalu) | Assign team
                  if (!controller.expired && !controller.assigned && !controller.rejected)
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                          ),
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: Text('reject'.tr, style: robotoMedium.copyWith(color: Colors.red)),
                          onPressed: () => controller.rejectBooking(),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                          ),
                          icon: controller.assigning
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.group_add, color: Colors.white),
                          label: Text(
                            controller.selectedIds.isEmpty
                                ? 'select_serviceman'.tr
                                : '${'assign'.tr} (${controller.selectedIds.length})',
                            style: robotoMedium.copyWith(color: Colors.white),
                          ),
                          onPressed: (controller.assigning || controller.selectedIds.isEmpty)
                              ? null
                              : () => controller.assignSelected(),
                        ),
                      ),
                    ]),

                  if (controller.expired || controller.assigned || controller.rejected) ...[
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    CustomButton(
                      btnTxt: 'ok'.tr,
                      onPressed: () {
                        final BookingRequestController bookingRequestController = Get.find<BookingRequestController>();
                        bookingRequestController.getBookingRequestList(bookingRequestController.bookingStatus, 1, reload: true);
                        Get.back();
                      },
                    ),
                  ],
                ]),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Distance-sorted serviceman list + multi-select (team 1-5)
class _TeamAssignSection extends StatelessWidget {
  final BookingTimerController controller;
  const _TeamAssignSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.group_outlined, size: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text('${'select_serviceman'.tr} (${controller.selectedIds.length}/5)',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
        ]),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text('select_team_hint'.tr,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor)),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        if (controller.suggestionsLoading)
          const Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Center(child: CustomLoader()),
          )
        else if (controller.suggestions.isEmpty)
          Text('no_serviceman_available'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor))
        else
          ...controller.suggestions.map((s) => _ServicemanTile(suggestion: s, controller: controller)),
      ]),
    );
  }
}

class _ServicemanTile extends StatelessWidget {
  final AssignSuggestion suggestion;
  final BookingTimerController controller;
  const _ServicemanTile({required this.suggestion, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool selected = controller.selectedIds.contains(suggestion.id);

    return InkWell(
      onTap: () => controller.toggleSuggestion(suggestion.id),
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).primaryColor.withValues(alpha: 0.07) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: selected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor),
        ),
        child: Row(children: [
          Checkbox(
            value: selected,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (_) => controller.toggleSuggestion(suggestion.id),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CustomImage(
              height: 36, width: 36, fit: BoxFit.cover,
              image: suggestion.image,
              placeholder: Images.userPlaceHolder,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(suggestion.name, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (suggestion.slotStatus != null && suggestion.slotStatus!.isNotEmpty)
                Text(suggestion.slotStatus!.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: _slotStatusColor(context, suggestion.slotStatus!))),
            ]),
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Row(children: [
              const Icon(Icons.near_me, size: 11),
              const SizedBox(width: 3),
              Text(
                suggestion.distanceKm != null ? '${suggestion.distanceKm} km' : '--',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Color _slotStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return Theme.of(context).hintColor;
    }
  }
}

class _BookingSummaryCard extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const _BookingSummaryCard({required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImage(
              height: 60, width: 60, fit: BoxFit.cover,
              image: bookingDetails.details?[0].service?.thumbnailFullPath ?? '',
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                bookingDetails.details?[0].serviceName ?? bookingDetails.details?[0].service?.name ?? '',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                bookingDetails.totalBookingAmount != null
                    ? PriceConverter.convertPrice(bookingDetails.totalBookingAmount)
                    : '',
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
              ),
            ]),
          ),
        ]),

        const SizedBox(height: Dimensions.paddingSizeDefault),
        Divider(color: Theme.of(context).dividerColor),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        _InfoRow(icon: Icons.location_on_outlined, label: 'address'.tr, value: bookingDetails.serviceAddress?.address ?? ''),
        _InfoRow(icon: Icons.category_outlined, label: 'service'.tr, value: bookingDetails.details?[0].serviceName ?? bookingDetails.details?[0].service?.name ?? ''),
        _InfoRow(icon: Icons.calendar_today_outlined, label: 'schedule'.tr, value: bookingDetails.serviceSchedule ?? ''),
        _InfoRow(icon: Icons.payments_outlined, label: 'payment_method'.tr, value: (bookingDetails.paymentMethod ?? '').replaceAll('_', ' ')),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Text('$label: ', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
        Expanded(child: Text(value, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), maxLines: 2, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final BookingTimerController controller;
  const _StatusCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final String message = controller.assigned
        ? 'assigned_successfully'.tr
        : controller.accepted
            ? 'booking_accepted_successfully'.tr
            : controller.rejected
                ? 'booking_rejected'.tr
                : 'booking_request_expired'.tr;

    final IconData icon = controller.assigned
        ? Icons.group_add
        : controller.accepted
            ? Icons.check_circle
            : controller.rejected
                ? Icons.cancel
                : Icons.timer_off;

    final Color color = (controller.assigned || controller.accepted)
        ? Colors.green
        : (controller.rejected ? Colors.red : Colors.orange);

    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 64),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Text(message, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center),
      ]),
    );
  }
}
