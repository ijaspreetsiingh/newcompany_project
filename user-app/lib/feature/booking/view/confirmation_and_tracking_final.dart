import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jdds/common/design_system/nest_brand.dart';
import 'package:jdds/util/core_export.dart';

// ============= CONFIRMATION SCREEN (Success) =============

/// Compact green tick badge — scale-in + delayed tick fade (hero ke upar).
class _AnimatedSuccessBadge extends StatefulWidget {
  const _AnimatedSuccessBadge();

  @override
  State<_AnimatedSuccessBadge> createState() => _AnimatedSuccessBadgeState();
}

class _AnimatedSuccessBadgeState extends State<_AnimatedSuccessBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  )..forward();

  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );

  late final Animation<double> _tickOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF16A34A),
        ),
        child: FadeTransition(
          opacity: _tickOpacity,
          child: const Icon(Icons.check_rounded, size: 26, color: Colors.white),
        ),
      ),
    );
  }
}

/// Shows real booking id / schedule / address after placeBookingRequest success.
class ConfirmationScreenFinal extends StatelessWidget {
  const ConfirmationScreenFinal({super.key});

  String _bookingId() {
    try {
      final String readableId = Get.find<CheckOutController>().bookingReadableId;
      if (readableId.isNotEmpty) return readableId;
    } catch (_) {}
    return '-';
  }

  /// Tracking API ko actual booking (UUID) chahiye — readable (#1234) nahi chalta.
  String _internalBookingId() {
    try {
      final String? bookingId = Get.find<CheckOutController>().bookingId;
      if (bookingId != null && bookingId.isNotEmpty) return bookingId;
    } catch (_) {}
    return '';
  }

  String _scheduleText() {
    try {
      final String? scheduleTime = Get.find<ScheduleController>().scheduleTime;
      if (scheduleTime == null || scheduleTime.isEmpty) return 'as_soon_as_possible'.tr;
      final DateTime schedule = DateFormat('yyyy-MM-dd HH:mm:ss').parse(scheduleTime);
      return '${DateFormat('d MMM, yyyy').format(schedule)}, ${DateFormat('h:mm a').format(schedule)}';
    } catch (_) {
      return '-';
    }
  }

  String _addressText() {
    try {
      // Friend/relative booking ho to friend ka selected address dikhana chahiye,
      // customer ke apne saved address se address overwrite mat karo
      final FriendLocationController friendController =
          Get.find<FriendLocationController>();
      if (friendController.isBookingForOther) {
        return friendController.selectedFriendAddress?.address ?? '';
      }
      final LocationController locationController = Get.find<LocationController>();
      final AddressModel? address = CheckoutHelper.selectedAddressModel(
        selectedAddress: locationController.selectedAddress,
        pickedAddress: locationController.getUserAddress(),
        selectedLocationType: locationController.selectedServiceLocationType,
      );
      return address?.address ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Schedule ka chhota text — progress subtitle + ticket dono me.
  String _scheduleShort() {
    try {
      final String? scheduleTime = Get.find<ScheduleController>().scheduleTime;
      if (scheduleTime == null || scheduleTime.isEmpty) return 'as_soon_as_possible'.tr;
      final DateTime schedule = DateFormat('yyyy-MM-dd HH:mm:ss').parse(scheduleTime);
      return '${DateFormat('d MMM').format(schedule)}, ${DateFormat('h:mm a').format(schedule)}';
    } catch (_) {
      return '-';
    }
  }

  /// Order place hote waqt cart se capture kiya gaya service name.
  String _serviceName() {
    try {
      final String name = Get.find<CheckOutController>().placedServiceName;
      if (name.isNotEmpty) return name;
    } catch (_) {}
    return '-';
  }

  /// Order amount (place-time capture) — "₹499 Paid" subtitle.
  String _paidText() {
    try {
      final double amount = Get.find<CheckOutController>().placedBookingAmount;
      if (amount > 0) return '${PriceConverter.convertPrice(amount)} ${'paid'.tr}';
    } catch (_) {}
    return 'paid'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final String bookingId = _bookingId();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color ink = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF111111);
    final Color muted = isDark ? Colors.white54 : Colors.black45;
    final Color chipBg = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF3F3F3);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // BRAND HEADER — home wala Jass logo + support chip
              Row(
                children: [
                  const NestBrand(fontSize: 20),
                  const Spacer(),
                  InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getSupportRoute()),
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? Colors.white24 : Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.support_agent_outlined, size: 16, color: ink),
                          const SizedBox(width: 5),
                          Text(
                            'support'.tr,
                            style: robotoMedium.copyWith(fontSize: 12, color: ink),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // STEP 3/3 — subtitle ke saath custom progress
              _buildProgress(context, bookingId, ink, muted),
              const SizedBox(height: 24),

              // HERO — green tick + heading + note (left), book.png (right)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    // image ko overlap se bachane ke liye right side reserve
                    padding: const EdgeInsets.only(right: 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _AnimatedSuccessBadge(),
                        const SizedBox(height: 14),
                        Text(
                          'booking_confirmed'.tr,
                          style: GoogleFonts.manrope(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: ink,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'your_home_is_in_good_hands'.tr,
                          style: GoogleFonts.manrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'professional_will_be_assigned_shortly'.tr,
                          style: robotoRegular.copyWith(fontSize: 12.5, color: muted, height: 1.45),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'confirmation_updates_note'.tr,
                          style: robotoRegular.copyWith(fontSize: 12.5, color: muted, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  // Decorative house illustration (transparent bg — light+dark dono)
                  Positioned(
                    top: 8,
                    right: -6,
                    child: IgnorePointer(
                      child: Image.asset(
                        'assets/images/book.png',
                        width: 158,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // BOOKING TICKET — id + confirmed pill + dashed divider + rows
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'booking_id'.tr.toUpperCase(),
                                style: robotoSmall.copyWith(
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                  color: muted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '#$bookingId',
                                style: GoogleFonts.manrope(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: ink,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF16A34A)),
                                const SizedBox(width: 4),
                                Text(
                                  'confirmed'.tr,
                                  style: robotoBold.copyWith(fontSize: 11, color: const Color(0xFF15803D)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dashed divider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: _dashedLine(isDark),
                    ),

                    // Details
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeSmall,
                      ),
                      child: Column(
                        children: [
                          _ticketRow(context, Icons.event_available_outlined, 'schedule'.tr, _scheduleText(), chipBg, ink, muted),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          _ticketRow(context, Icons.home_repair_service_outlined, 'service'.tr, _serviceName(), chipBg, ink, muted),
                          if (_addressText().isNotEmpty) ...[
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            _ticketRow(context, Icons.location_on_outlined, 'address'.tr, _addressText(), chipBg, ink, muted),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Track Booking — black button + chevron (reference style)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    final String id = _internalBookingId();
                    if (id.isEmpty) return;
                    Get.toNamed(RouteHelper.getBookingDetailsScreen(
                      bookingID: id,
                      fromPage: 'tracking',
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ink,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.my_location, size: 18, color: isDark ? const Color(0xFF0D0D0D) : Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'track_booking'.tr,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF0D0D0D) : Colors.white,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: 22, color: isDark ? const Color(0xFF0D0D0D) : Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back to Home — outlined + home icon
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed(RouteHelper.getMainRoute('home')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    side: BorderSide(color: isDark ? Colors.white24 : Colors.grey[350]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_outlined, size: 19, color: ink),
                      const SizedBox(width: 8),
                      Text(
                        'back_to_home'.tr,
                        style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: ink),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // TRUST STRIP — Verified / Secure / 24x7
              Container(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    _trustItem(context, Icons.verified_user_outlined, 'verified_professionals'.tr,
                        'trusted_background_checked'.tr, ink, muted),
                    _trustItem(context, Icons.lock_outline, 'secure_payments'.tr, 'safe_encrypted'.tr,
                        ink, muted),
                    _trustItem(context, Icons.support_agent, 'support_247'.tr, 'always_here_to_help'.tr,
                        ink, muted),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // FOOTER tagline
              Text(
                'better_homes_better_living'.tr.toUpperCase(),
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                  fontSize: 9.5,
                  letterSpacing: 2,
                  color: muted.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],
          ),
        ),
      ),
    );
  }

  /// Schedule → Payment → Confirmed — subtitle ke saath step indicator.
  Widget _buildProgress(BuildContext context, String bookingId, Color ink, Color muted) {
    final List<Map<String, String>> steps = [
      {'label': 'schedule'.tr, 'sub': _scheduleShort()},
      {'label': 'payment'.tr, 'sub': _paidText()},
      {'label': 'confirmed'.tr, 'sub': '${'booking'.tr} #$bookingId'},
    ];

    Widget stepCircle(int index) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(shape: BoxShape.circle, color: ink),
        child: Icon(
          index == 2 ? Icons.check_circle : Icons.check,
          size: index == 2 ? 20 : 16,
          color: index == 2 ? ink : (Theme.of(context).scaffoldBackgroundColor),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: muted.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, left: 6, right: 6),
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: ink),
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                stepCircle(i),
                const SizedBox(height: 6),
                Text(
                  steps[i]['label']!,
                  style: robotoMedium.copyWith(fontSize: 10.5, color: ink),
                ),
                const SizedBox(height: 2),
                Text(
                  steps[i]['sub']!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(fontSize: 8.5, color: muted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Trust strip ka ek item — icon + title + subtitle.
  Widget _trustItem(BuildContext context, IconData icon, String title, String subtitle,
      Color ink, Color muted) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: ink),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoBold.copyWith(fontSize: 10, color: ink),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(fontSize: 8.5, color: muted, height: 1.25),
          ),
        ],
      ),
    );
  }

  /// Ticket row — grey icon chip + caps label + bold value.
  Widget _ticketRow(BuildContext context, IconData icon, String label, String value,
      Color chipBg, Color ink, Color muted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: ink, size: 19),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: robotoSmall.copyWith(fontSize: 10, letterSpacing: 0.6, color: muted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: ink),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dashedLine(bool isDark) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double dashWidth = 6;
        const double dashSpace = 4;
        final int dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(
            dashCount,
            (_) => SizedBox(
              width: dashWidth,
              height: 1.5,
              child: ColoredBox(color: isDark ? Colors.white24 : const Color(0xFFD0D0D0)),
            ),
          ),
        );
      },
    );
  }
}

// ============= BOOKING TRACKING SCREEN =============
/// Live booking status via BookingDetailsController.getBookingDetails API.
class BookingTrackingScreenFinal extends StatefulWidget {
  const BookingTrackingScreenFinal({super.key});

  @override
  State<BookingTrackingScreenFinal> createState() => _BookingTrackingScreenFinalState();
}

class _BookingTrackingScreenFinalState extends State<BookingTrackingScreenFinal> {
  Timer? _pollTimer;
  String? _bookingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bookingId = Get.parameters['id'];
      if (_bookingId != null && _bookingId!.isNotEmpty && _bookingId != 'null') {
        Get.find<BookingDetailsController>().getBookingDetails(bookingId: _bookingId!);
        _startPolling();
      }
    });
  }

  // Live status + extra-service bill update (serviceman active hai tab tak).
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _pollBooking());
  }

  void _pollBooking() {
    if (!mounted) return;
    final controller = Get.find<BookingDetailsController>();
    final details = controller.bookingDetailsContent;
    if (details?.id == null) return;

    final String status = details?.bookingStatus ?? '';
    if (status == 'completed' || status == 'canceled' || status == 'cancelled') {
      _pollTimer?.cancel();
      return;
    }
    controller.getBookingDetails(bookingId: details!.id!, reload: false);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  /// Map booking status -> ordered timeline steps (done / pending)
  List<Map<String, dynamic>> _buildSteps(BookingDetailsContent? details) {
    final String status = details?.bookingStatus ?? '';
    final List<StatusHistories> histories = details?.statusHistories ?? [];

    String? _timeFor(String stepStatus) {
      for (StatusHistories history in histories) {
        if (history.bookingStatus == stepStatus && history.createdAt != null) {
          try {
            final DateTime createdAt = DateTime.parse(history.createdAt!);
            return '${DateFormat('d MMM').format(createdAt)}, ${DateFormat('h:mm a').format(createdAt)}';
          } catch (_) {
            return history.createdAt;
          }
        }
      }
      return null;
    }

    bool _done(String stepStatus) {
      if (status == 'canceled' || status == 'cancelled') {
        // Only confirmed step remains done when booking cancelled
        return stepStatus == 'pending';
      }
      if (stepStatus == 'pending') return true;
      return histories.any((history) => history.bookingStatus == stepStatus);
    }

    return [
      {
        'title': 'booking_confirmed'.tr,
        'time': _timeFor('pending') ?? 'done'.tr,
        'done': true,
      },
      {
        'title': 'accepted'.tr,
        'time': _timeFor('accepted') ?? (_done('accepted') ? 'done'.tr : 'pending'.tr),
        'done': _done('accepted'),
      },
      {
        'title': 'ongoing'.tr,
        'time': _timeFor('ongoing') ?? (_done('ongoing') ? 'done'.tr : 'pending'.tr),
        'done': _done('ongoing'),
      },
      {
        'title': 'completed'.tr,
        'time': _timeFor('completed') ?? (_done('completed') ? 'done'.tr : 'pending'.tr),
        'done': _done('completed'),
      },
    ];
  }

  String _statusTitle(String? status) {
    switch (status) {
      case 'accepted':
        return 'professional_assigned'.tr;
      case 'ongoing':
        return 'service_in_progress'.tr;
      case 'completed':
        return 'booking_completed'.tr;
      case 'canceled':
      case 'cancelled':
        return 'booking_canceled'.tr;
      default:
        return 'booking_confirmed'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge!.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'booking_details'.tr,
          style: robotoBold.copyWith(fontSize: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<BookingDetailsController>(
        builder: (bookingDetailsController) {
          if (bookingDetailsController.bookingDetailsContent == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final BookingDetailsContent details = bookingDetailsController.bookingDetailsContent!;
          final List<Map<String, dynamic>> steps = _buildSteps(details);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Hero (real booking status)
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusTitle(details.bookingStatus).toUpperCase(),
                        style: robotoSmall.copyWith(fontSize: 10, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        details.bookingStatus == 'completed'
                            ? 'booking_completed'.tr
                            : 'everythings_on_track'.tr,
                        style: robotoBold.copyWith(
                            fontSize: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                      const SizedBox(height: 4),
                      if (details.serviceSchedule != null && details.serviceSchedule!.isNotEmpty)
                        Text(
                          _formatSchedule(details.serviceSchedule),
                          style: robotoRegular.copyWith(fontSize: 14, color: Colors.black54),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Booking ID + Amount
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      _infoRow(context, 'booking_id'.tr, '#${details.readableId ?? '-'}'),
                      const Divider(height: 16),
                      _infoRow(context, 'amount'.tr,
                          PriceConverter.convertPrice(details.totalBookingAmount)),
                      if (details.serviceAddress?.address != null) ...[
                        const Divider(height: 16),
                        _infoRow(context, 'address'.tr, details.serviceAddress!.address ?? ''),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Timeline steps (real status)
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      for (int index = 0; index < steps.length; index++) ...[
                        _buildStepItem(context, steps[index], index == steps.length - 1),
                        if (index != steps.length - 1)
                          _buildStepConnector(context, steps[index + 1]['done'] == true),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // View full booking details (old working details screen)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(RouteHelper.getBookingDetailsScreen(
                      bookingID: details.id,
                      fromPage: 'tracking',
                    )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    ),
                    child: Text(
                      'view_booking_details'.tr,
                      style: robotoBold.copyWith(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(RouteHelper.getMainRoute('home')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    ),
                    child: Text(
                      'back_to_home'.tr,
                      style: robotoBold.copyWith(
                          fontSize: 16, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatSchedule(String? schedule) {
    if (schedule == null || schedule.isEmpty) return '';
    try {
      final DateTime parsed = DateTime.parse(schedule);
      return '${DateFormat('d MMM, yyyy').format(parsed)}, ${DateFormat('h:mm a').format(parsed)}';
    } catch (_) {
      return schedule;
    }
  }

  Widget _infoRow(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: robotoRegular.copyWith(fontSize: 14, color: Colors.black54)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: robotoBold.copyWith(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(BuildContext context, Map<String, dynamic> step, bool isLast) {
    final bool done = step['done'] == true;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? primaryAccent : Colors.grey[300],
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Icon(Icons.circle, size: 8, color: Colors.grey[500]),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step['title'],
                style: robotoBold.copyWith(
                  fontSize: 14,
                  color: done ? Theme.of(context).textTheme.bodyLarge!.color : Colors.grey[500],
                ),
              ),
              Text(
                step['time'],
                style: robotoSmall.copyWith(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(BuildContext context, bool nextDone) {
    return Container(
      margin: const EdgeInsets.only(left: 15),
      width: 2,
      height: 24,
      color: nextDone ? primaryAccent : Colors.grey[300],
    );
  }
}

