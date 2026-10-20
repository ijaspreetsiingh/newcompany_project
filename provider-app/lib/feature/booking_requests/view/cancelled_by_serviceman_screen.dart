import 'dart:convert';
import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:jassdbx_provider/feature/booking_requests/controller/cancelled_booking_controller.dart';

/// Provider screen: bookings jo serviceman ne cancel ki hain.
/// Provider yahan se kisi bhi serviceman ko manually assign kar sakta hai.
class CancelledByServicemanScreen extends StatefulWidget {
  const CancelledByServicemanScreen({super.key});

  @override
  State<CancelledByServicemanScreen> createState() =>
      _CancelledByServicemanScreenState();
}

class _CancelledByServicemanScreenState
    extends State<CancelledByServicemanScreen> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CancelledBookingController>()) {
      Get.put(CancelledBookingController(userRepo: Get.find()));
    }
    Get.find<CancelledBookingController>().loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        child: Column(
          children: [
            InkTopBar(
              title: 'cancelled_by_serviceman'.tr,
              onBack: () => Get.back(),
            ),
            Expanded(
              child: GetBuilder<CancelledBookingController>(
                builder: (ctrl) {
                  if (ctrl.isLoading && ctrl.bookings.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (ctrl.bookings.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 64, color: InkColors.mutedForeground),
                            const SizedBox(height: 16),
                            Text(
                              'no_cancelled_bookings'.tr,
                              style: robotoSemiBold.copyWith(
                                  fontSize: 16, color: InkColors.foreground),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'no_cancelled_bookings_desc'.tr,
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(
                                  fontSize: 13,
                                  color: InkColors.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ctrl.loadBookings(refresh: true),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: ctrl.bookings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final booking = ctrl.bookings[index];
                        return _CancelledBookingCard(
                          booking: booking,
                          onAssign: (servicemanId) =>
                              ctrl.assignServiceman(booking['id'], servicemanId),
                          isAssigning: ctrl.assigningBookingId == booking['id'],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelledBookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final void Function(String servicemanId) onAssign;
  final bool isAssigning;

  const _CancelledBookingCard({
    required this.booking,
    required this.onAssign,
    required this.isAssigning,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> servicemen =
        (booking['available_servicemen'] as List?) ?? [];
    final String readableId = booking['readable_id']?.toString() ?? '';
    final String subCatName =
        booking['sub_category']?['name']?.toString() ?? '';
    final String cancelledAt = booking['cancelled_by_serviceman_at'] ?? '';

    return InkCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#$readableId',
                      style: robotoSemiBold.copyWith(
                          fontSize: 14, color: InkColors.foreground),
                    ),
                    if (subCatName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subCatName,
                        style: robotoRegular.copyWith(
                            fontSize: 12, color: InkColors.mutedForeground),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: InkColors.destructive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'serviceman_cancelled'.tr,
                  style: robotoMedium.copyWith(
                      fontSize: 10, color: InkColors.destructive),
                ),
              ),
            ],
          ),

          if (cancelledAt.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              cancelledAt.substring(0, cancelledAt.length > 16 ? 16 : cancelledAt.length),
              style: robotoRegular.copyWith(
                  fontSize: 11, color: InkColors.mutedForeground),
            ),
          ],

          const Divider(height: 24),

          // Assign serviceman section
          Text(
            'assign_serviceman'.tr,
            style:
                robotoSemiBold.copyWith(fontSize: 13, color: InkColors.foreground),
          ),
          const SizedBox(height: 10),

          if (servicemen.isEmpty)
            Text(
              'no_serviceman_available'.tr,
              style: robotoRegular.copyWith(
                  fontSize: 12, color: InkColors.mutedForeground),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: servicemen.map<Widget>((sm) {
                final String id = sm['id']?.toString() ?? '';
                final String name = sm['name']?.toString() ?? '';
                final double? dist =
                    double.tryParse(sm['distance_km']?.toString() ?? '');

                return InkWell(
                  onTap: isAssigning ? null : () => onAssign(id),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: InkColors.secondary,
                      border: Border.all(color: InkColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 15, color: InkColors.foreground),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: robotoMedium.copyWith(
                                    fontSize: 12, color: InkColors.foreground)),
                            if (dist != null)
                              Text('${dist.toStringAsFixed(1)} km',
                                  style: robotoRegular.copyWith(
                                      fontSize: 10,
                                      color: InkColors.mutedForeground)),
                          ],
                        ),
                        if (isAssigning) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 1.5, color: InkColors.foreground),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
