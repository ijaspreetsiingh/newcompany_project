import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

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

  String _badgeStatus(BookingTimerController controller) {
    if (controller.accepted) return 'accepted';
    if (controller.rejected) return 'rejected';
    if (controller.expired) return 'expired';
    return 'pending';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // back button se popup dismiss na ho
      child: Scaffold(
        backgroundColor: context.kBackground,
        body: SafeArea(
          child: GetBuilder<BookingTimerController>(
            builder: (controller) {
              final bool active = !controller.expired && !controller.accepted && !controller.rejected;

              return Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(children: [

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.notifications_active_rounded, size: 20, color: context.kForeground),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Flexible(
                      child: Text(
                        'new_booking_request'.tr,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: robotoBold.copyWith(fontSize: 16, color: context.kForeground),
                      ),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.kCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: context.kBorder, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            if (controller.bookingDetails != null)
                              _BookingSummaryCard(
                                bookingDetails: controller.bookingDetails!,
                                bookingId: widget.bookingId,
                                status: _badgeStatus(controller),
                              )
                            else if (active)
                              const SizedBox(
                                height: 160,
                                child: Center(child: CustomLoader()),
                              )
                            else
                              _StatusCard(controller: controller),

                            // AUTO-ASSIGN: team members (1 se zyada ho toh)
                            if (active && controller.team.length > 1)
                              _TeamSection(team: controller.team),

                            if (active) ...[
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              _CountdownTimer(seconds: controller.remainingSeconds),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              Row(children: [
                                Expanded(
                                  child: Opacity(
                                    opacity: controller.isLoading ? 0.6 : 1,
                                    child: KButton(
                                      label: 'reject'.tr,
                                      outline: true,
                                      onTap: controller.isLoading ? null : () => controller.rejectBooking(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Opacity(
                                    opacity: controller.isLoading ? 0.6 : 1,
                                    child: KButton(
                                      label: 'accept_job'.tr,
                                      onTap: controller.isLoading ? null : () => controller.acceptBooking(),
                                    ),
                                  ),
                                ),
                              ]),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (!active) ...[
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    KButton(
                      label: 'ok'.tr,
                      onTap: () {
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
  final String bookingId;
  final String status;
  const _BookingSummaryCard({
    required this.bookingDetails,
    required this.bookingId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final String readableId = bookingDetails.readableId ?? '';
    final String displayId = readableId.isNotEmpty && readableId != 'null'
        ? '#$readableId'
        : '#$bookingId';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Row(children: [
        StatusBadge(status: status),
        const Spacer(),
        Text(
          displayId,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: robotoMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.kMutedForeground,
          ),
        ),
      ]),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusMd),
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
              style: robotoBold.copyWith(fontSize: 16, color: context.kForeground),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              bookingDetails.totalBookingAmount != null
                  ? PriceConverter.convertPrice(bookingDetails.totalBookingAmount)
                  : '',
              style: robotoBold.copyWith(fontSize: 16, color: context.kForeground),
            ),
          ]),
        ),
      ]),

      const SizedBox(height: Dimensions.paddingSizeDefault),
      Container(height: 1, color: context.kBorder),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      _InfoRow(icon: Icons.location_on_outlined, label: 'address'.tr, value: bookingDetails.serviceAddress?.address ?? ''),
      _InfoRow(icon: Icons.category_outlined, label: 'service'.tr, value: bookingDetails.details?[0].serviceName ?? bookingDetails.details?[0].service?.name ?? ''),
      _InfoRow(icon: Icons.calendar_today_outlined, label: 'schedule'.tr, value: bookingDetails.serviceSchedule ?? ''),
      _InfoRow(icon: Icons.payments_outlined, label: 'payment_method'.tr, value: (bookingDetails.paymentMethod ?? '').replaceAll('_', ' ')),
    ]);
  }
}

/// AUTO-ASSIGN: team members list (jab 1 se zyada servicemen assigned ho)
class _TeamSection extends StatelessWidget {
  final List<dynamic> team;
  const _TeamSection({required this.team});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 1, color: context.kBorder),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Row(children: [
          Icon(Icons.groups_outlined, size: 16, color: context.kMutedForeground),
          const SizedBox(width: 6),
          Text('${'team'.tr} (${team.length})',
              style: robotoBold.copyWith(fontSize: 13, color: context.kForeground)),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        ...team.map((member) {
          final String name = member['name']?.toString() ?? '';
          final String status = member['status']?.toString() ?? '';
          final bool isMe = member['is_me'] == true;
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CustomImage(
                  height: 24, width: 24, fit: BoxFit.cover,
                  image: member['image']?.toString() ?? '',
                  placeholder: Images.userPlaceHolder,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Text(
                  isMe ? '$name (You)' : name,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: robotoMedium.copyWith(fontSize: 13, color: context.kForeground),
                ),
              ),
              StatusBadge(status: status),
            ]),
          );
        }),
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
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: context.kMutedForeground),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: '$label: ',
                style: robotoRegular.copyWith(fontSize: 13, color: context.kMutedForeground),
              ),
              TextSpan(
                text: value,
                style: robotoMedium.copyWith(fontSize: 14, color: context.kForeground),
              ),
            ]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }
}

class _CountdownTimer extends StatelessWidget {
  final int seconds;
  const _CountdownTimer({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final bool warning = seconds <= 10;
    final Color color = warning ? context.kDestructive : context.kForeground;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.kMuted,
        borderRadius: BorderRadius.circular(kRadiusMd),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.timer_outlined, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          '${seconds}s',
          style: robotoBold.copyWith(fontSize: 18, color: color),
        ),
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
        ? Icons.check_circle_rounded
        : controller.rejected
            ? Icons.cancel_rounded
            : Icons.timer_off_rounded;

    final Color color = controller.accepted
        ? context.kSuccess
        : (controller.rejected ? context.kDestructive : Ios27Tokens.systemOrange);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: SizedBox(
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Icon(icon, color: color, size: 64),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            message,
            textAlign: TextAlign.center,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: context.kForeground,
            ),
          ),
        ]),
      ),
    );
  }
}
