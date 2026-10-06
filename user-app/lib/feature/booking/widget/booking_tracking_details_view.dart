import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/feature/booking/widget/regular/booking_summery_widget.dart';
import 'package:jdds/feature/booking/widget/booking_screen_shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mobile booking detail layout based on the customer tracking reference.
class BookingTrackingDetailsView extends StatelessWidget {
  final String? bookingId;
  final bool isSubBooking;

  const BookingTrackingDetailsView({
    super.key,
    required this.bookingId,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFF1F1F1) : const Color(0xFF111111);
    final muted = dark ? const Color(0xFFB3B3B3) : const Color(0xFF777777);
    final border = dark ? const Color(0xFF353535) : const Color(0xFFE2E2E2);
    return GetBuilder<BookingDetailsController>(
      builder: (controller) {
        final booking = isSubBooking
            ? controller.subBookingDetailsContent
            : controller.bookingDetailsContent;
        if (booking == null) return const Center(child: BookingScreenShimmer());

        final status = _normalizeBookingStatus(booking.bookingStatus ?? 'pending');
        final schedule = _formatDate(booking.serviceSchedule);
        final provider = booking.provider;
        final serviceman = booking.serviceman?.user;
        final professionalName = serviceman == null
            ? (provider?.contactPersonName ??
                  provider?.companyName ??
                  'no_provider_assigned'.tr)
            : '${serviceman.firstName ?? ''} ${serviceman.lastName ?? ''}'
                  .trim();
        final professionalImage =
            serviceman?.profileImageFullPath ?? provider?.logoFullPath ?? '';
        final phone =
            serviceman?.phone ??
            provider?.contactPersonPhone ??
            provider?.companyPhone;
        final address =
            booking.serviceAddress?.address ?? 'no_address_found'.tr;
        final scheduleTitle = schedule.isEmpty ? 'Schedule pending' : schedule;
        final cancelable =
            status == 'pending' || status == 'accepted' || status == 'ongoing';
        final repeatable = status == 'completed' && !isSubBooking;

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final id = bookingId;
                  if (id == null) return;
                  if (isSubBooking) {
                    await controller.getSubBookingDetails(bookingId: id);
                  } else {
                    await controller.getBookingDetails(bookingId: id);
                  }
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _statusEyebrow(status),
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _statusHeadline(status),
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            schedule.isEmpty
                                ? 'Your schedule will be shared soon'
                                : '$professionalName will arrive $schedule',
                            style: GoogleFonts.dmSans(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _StatusTimeline(
                      booking: booking,
                      ink: ink,
                      muted: muted,
                      border: border,
                    ),
                    const SizedBox(height: 20),
                    if (provider != null || serviceman != null) ...[
                      _ProfessionalCard(
                        name: professionalName,
                        image: professionalImage,
                        phone: phone,
                        isSubBooking: isSubBooking,
                        hasProvider: provider != null,
                        rating: provider?.avgRating,
                        jobs: provider?.totalServiceServed,
                        ink: ink,
                        muted: muted,
                        border: border,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _DetailsCard(
                      schedule: scheduleTitle,
                      address: address,
                      payment: (booking.paymentMethod ?? 'not_available').tr,
                      ink: ink,
                      muted: muted,
                      border: border,
                    ),
                    const SizedBox(height: 20),
                    BookingSummeryWidget(bookingDetails: booking),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (cancelable || repeatable)
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(top: BorderSide(color: border)),
                  ),
                  child: Row(
                    children: [
                      if (cancelable)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _confirmCancel(
                              context,
                              controller,
                              booking.id ?? '',
                              isSubBooking,
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              foregroundColor: ink,
                              side: BorderSide(color: border),
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              'cancel_booking'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      if (cancelable && repeatable) const SizedBox(width: 10),
                      if (repeatable)
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (booking.id != null &&
                                  booking.subCategoryId != null) {
                                Get.find<ServiceBookingController>()
                                    .checkCartSubcategory(
                                      booking.id!,
                                      booking.subCategoryId!,
                                    );
                              }
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              backgroundColor: const Color(0xFF111111),
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              'repeat'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    BookingDetailsController controller,
    String id,
    bool sub,
  ) async {
    if (id.isEmpty) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('cancel_booking'.tr),
        content: Text('are_you_sure_to_cancel_your_order'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('not_now'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('yes_cancel'.tr),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      if (sub) {
        await controller.subBookingCancel(subBookingId: id);
      } else {
        await controller.bookingCancel(bookingId: id);
      }
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  String _statusEyebrow(String status) => status == 'pending'
      ? 'BOOKING RECEIVED'
      : status == 'completed'
      ? 'SERVICE COMPLETED'
      : status == 'canceled' || status == 'cancelled'
      ? 'BOOKING CANCELED'
      : 'PROFESSIONAL ASSIGNED';

  String _statusHeadline(String status) => status == 'pending'
      ? 'Your booking is confirmed'
      : status == 'completed'
      ? 'Service completed'
      : status == 'canceled' || status == 'cancelled'
      ? 'Booking canceled'
      : 'Everythingâ€™s on track';

  String _formatDate(String? value) {
    final date = value == null ? null : DateTime.tryParse(value);
    if (date == null) return '';
    return DateConverter.dateMonthYearTimeTwentyFourFormat(date);
  }
}

class _StatusTimeline extends StatelessWidget {
  final BookingDetailsContent booking;
  final Color ink, muted, border;
  const _StatusTimeline({
    required this.booking,
    required this.ink,
    required this.muted,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Booking confirmed',
      'Professional assigned',
      'Service in progress',
      'Completed',
    ];
    const fallbackStamps = ['Confirmed', 'Assigned', 'In progress', 'Completed'];
    final histories = booking.statusHistories ?? const <StatusHistories>[];
    final historyByStep = <int, StatusHistories>{};
    final currentStatusStep =
        _bookingTimelineStep(booking.bookingStatus ?? 'pending');
    var lastKnownStep = currentStatusStep ?? 0;
    for (final history in histories) {
      final step = _bookingTimelineStep(history.bookingStatus ?? '');
      if (step != null) {
        historyByStep[step] = history;
        if (step > lastKnownStep) lastKnownStep = step;
      }
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    final completedStepColor =
        dark ? const Color(0xFFF1F1F1) : const Color(0xFF111111);
    final completedStepIconColor = dark ? const Color(0xFF111111) : Colors.white;

    return Column(
      children: List.generate(labels.length, (index) {
        final history = historyByStep[index];
        final done = index <= lastKnownStep || history != null;
        final eventDate = history?.createdAt ??
            (currentStatusStep != null && index == currentStatusStep
                ? booking.updatedAt
                : null) ??
            (index == 0 ? booking.createdAt : null);
        final stamp = eventDate != null && eventDate.isNotEmpty
            ? _shortDate(eventDate)
            : done
            ? fallbackStamps[index]
            : 'Pending';
        return SizedBox(
          width: double.infinity,
          height: index == labels.length - 1 ? 70 : 81,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              if (index < labels.length - 1)
                Positioned(
                  left: 13,
                  top: 29,
                  bottom: 0,
                  child: Container(width: 1, color: border),
                ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? completedStepColor : Colors.transparent,
                  border: Border.all(
                    color: done ? completedStepColor : border,
                  ),
                ),
              ),
              if (done)
                Positioned(
                  left: 7,
                  top: 7,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: completedStepIconColor,
                  ),
                ),
              Positioned(
                left: 44,
                top: 1,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels[index],
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stamp,
                      style: GoogleFonts.dmSans(fontSize: 11, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _shortDate(String value) {
    final date = DateTime.tryParse(value);
    return date == null
        ? value
        : DateConverter.dateMonthYearTimeTwentyFourFormat(date);
  }
}

String _normalizeBookingStatus(String status) => status
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[\s-]+'), '_');

int? _bookingTimelineStep(String status) {
  switch (_normalizeBookingStatus(status)) {
    case 'pending':
    case 'confirmed':
      return 0;
    case 'accepted':
    case 'assigned':
    case 'provider_assigned':
    case 'serviceman_assigned':
      return 1;
    case 'ongoing':
    case 'in_progress':
    case 'in_service':
    case 'service_in_progress':
    case 'processing':
      return 2;
    case 'completed':
      return 3;
    default:
      return null;
  }
}

class _ProfessionalCard extends StatelessWidget {
  final String name, image;
  final String? phone;
  final bool isSubBooking, hasProvider;
  final double? rating;
  final int? jobs;
  final Color ink, muted, border;
  const _ProfessionalCard({
    required this.name,
    required this.image,
    this.phone,
    required this.isSubBooking,
    required this.hasProvider,
    this.rating,
    this.jobs,
    required this.ink,
    required this.muted,
    required this.border,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 54,
            height: 54,
            child: image.isEmpty
                ? Container(
                    color: ink,
                    alignment: Alignment.center,
                    child: Text(
                      _inttials(name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : CustomImage(
                    image: image,
                    fit: BoxFit.cover,
                    placeholder: Images.userPlaceHolder,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR PROFESSIONAL',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: muted,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'â˜… ${(rating ?? 0).toStringAsFixed(2)} Â· ${jobs ?? 0} jobs',
                style: GoogleFonts.dmSans(fontSize: 11, color: muted),
              ),
            ],
          ),
        ),
        _roundAction(
          context,
          Icons.call_outlined,
          () {
            if (phone != null && phone!.isNotEmpty) {
              launchUrl(Uri(scheme: 'tel', path: phone));
            }
          },
          ink,
          border,
        ),
        const SizedBox(width: 8),
        _roundAction(
          context,
          Icons.chat_bubble_outline,
          () {
            if (!hasProvider) {
              customSnackBar(
                'provider_or_service_man_assigned'.tr,
                type: ToasterMessageType.info,
              );
              return;
            }
            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => CreateChannelDialog(isSubBooking: isSubBooking),
            );
          },
          ink,
          border,
        ),
      ],
    ),
  );

  String _inttials(String name) => name.trim().isEmpty
      ? 'â€”'
      : name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();

  Widget _roundAction(
    BuildContext context,
    IconData icon,
    VoidCallback tap,
    Color ink,
    Color border,
  ) => InkWell(
    onTap: tap,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: border),
      ),
      child: Icon(icon, color: ink, size: 19),
    ),
  );
}

class _DetailsCard extends StatelessWidget {
  final String schedule, address, payment;
  final Color ink, muted, border;
  const _DetailsCard({
    required this.schedule,
    required this.address,
    required this.payment,
    required this.ink,
    required this.muted,
    required this.border,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: BoxDecoration(
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        _detailRow(
          Icons.calendar_month_outlined,
          'SCHEDULE',
          schedule,
          ink,
          muted,
        ),
        Divider(height: 1, color: border),
        _detailRow(Icons.location_on_outlined, 'ADDRESS', address, ink, muted),
        Divider(height: 1, color: border),
        _detailRow(Icons.credit_card_outlined, 'PAYMENT', payment, ink, muted),
      ],
    ),
  );

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
    Color ink,
    Color muted,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: ink, size: 21),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.dmSans(
                  color: muted,
                  fontSize: 9,
                  letterSpacing: .4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.manrope(
                  color: ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}



