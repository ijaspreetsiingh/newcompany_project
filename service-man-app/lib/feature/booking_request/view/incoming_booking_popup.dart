import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:demandium_serviceman/feature/booking_details/model/booking_details_model.dart';
import 'package:demandium_serviceman/feature/booking_request/controller/booking_timer_controller.dart';

/// AUTO-ASSIGN: serviceman ko new booking assignment aane par full-screen popup
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
    final BookingTimerController controller = Get.put(BookingTimerController(
      bookingRequestRepo: Get.find(),
      bookingDetailsRepo: Get.find(),
    ));
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
                        ? SingleChildScrollView(child: _BookingSummaryCard(bookingDetails: controller.bookingDetails!))
                        : (controller.expired || controller.accepted || controller.rejected)
                            ? _StatusCard(controller: controller)
                            : const Center(child: CustomLoader()),
                  ),

                  // countdown timer
                  if (!controller.expired && !controller.accepted && !controller.rejected) ...[
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
                          '${controller.remainingSeconds}s',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeOverLarge,
                            color: controller.remainingSeconds <= 10 ? Colors.red : Theme.of(context).primaryColor,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],

                  // action buttons
                  if (!controller.expired && !controller.accepted && !controller.rejected)
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
                          onPressed: controller.isLoading ? null : () => controller.rejectBooking(),
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
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: Text('accept'.tr, style: robotoMedium.copyWith(color: Colors.white)),
                          onPressed: controller.isLoading ? null : () => controller.acceptBooking(),
                        ),
                      ),
                    ]),

                  if (controller.expired || controller.accepted || controller.rejected) ...[
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    CustomButton(
                      btnTxt: 'ok'.tr,
                      onPressed: () {
                        final BookingRequestController bookingRequestController = Get.find<BookingRequestController>();
                        bookingRequestController.getBookingList(
                          bookingRequestController.bookingStatusState.name.toLowerCase(), 1,
                        );
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
    final String message = controller.accepted
        ? 'booking_accepted_successfully'.tr
        : controller.rejected
            ? 'booking_rejected'.tr
            : 'booking_request_expired'.tr;

    final IconData icon = controller.accepted
        ? Icons.check_circle
        : controller.rejected
            ? Icons.cancel
            : Icons.timer_off;

    final Color color = controller.accepted ? Colors.green : (controller.rejected ? Colors.red : Colors.orange);

    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 64),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Text(message, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center),
      ]),
    );
  }
}
