import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jdds/util/core_export.dart';

// ============= CONFtrMATION SCREEN (Success) =============
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

  @override
  Widget build(BuildContext context) {
    final String bookingId = _bookingId();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Mark
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Icon(Icons.check, size: 48, color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // Title
              Text(
                'booking_confirmed'.tr.toUpperCase(),
                style: robotoSmall.copyWith(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                'your_home_is_in_good_hands'.tr,
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(
                    fontSize: 24, color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text(
                'professional_will_be_assigned_shortly'.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // Booking Ticket (real data)
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'booking_id'.tr.toUpperCase(),
                          style: robotoSmall.copyWith(fontSize: 10, color: Colors.black54),
                        ),
                        Text(
                          '#$bookingId',
                          style: robotoBold.copyWith(
                              fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    _buildTicketRow(Icons.calendar_today, _scheduleText(), context),
                    if (_addressText().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildTicketRow(Icons.location_on, _addressText(), context),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // Track Booking Button (real booking id)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(RouteHelper.getTrackingFinalRoute(bookingId: _internalBookingId())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  ),
                  child: Text(
                    'track_booking'.tr,
                    style: robotoBold.copyWith(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back to Home
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
                    style:
                        robotoBold.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: robotoRegular.copyWith(
                  fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color)),
        ),
      ],
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? bookingId = Get.parameters['id'];
      if (bookingId != null && bookingId.isNotEmpty && bookingId != 'null') {
        Get.find<BookingDetailsController>().getBookingDetails(bookingId: bookingId);
      }
    });
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

