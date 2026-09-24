import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class DashboardTopCardShimmer extends StatelessWidget {
  const DashboardTopCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 3),
      interval: const Duration(seconds: 5),
      colorOpacity: 0,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(context, height: 18, width: 140),
                _shimmerBox(context, height: 28, width: 90, radius: 20),
              ],
            ),
            const SizedBox(height: 16),

            // 2x2 stat cards
            Row(
              children: [
                Expanded(child: _shimmerStatCard(context)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerStatCard(context)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _shimmerStatCard(context)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerStatCard(context)),
              ],
            ),
            const SizedBox(height: 24),

            // Booking Statistics section header
            _shimmerBox(context, height: 18, width: 160),
            const SizedBox(height: 16),

            // Horizontal stat cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _shimmerWideStatCard(context),
                  const SizedBox(width: 12),
                  _shimmerWideStatCard(context),
                  const SizedBox(width: 12),
                  _shimmerWideStatCard(context),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Bookings section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(context, height: 18, width: 130),
                _shimmerBox(context, height: 14, width: 60),
              ],
            ),
            const SizedBox(height: 16),

            // Booking list items
            _shimmerBookingItem(context),
            const SizedBox(height: 12),
            _shimmerBookingItem(context),
            const SizedBox(height: 12),
            _shimmerBookingItem(context),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(BuildContext context, {required double height, required double width, double radius = 8}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _shimmerStatCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBox(context, height: 40, width: 40, radius: 10),
              const Spacer(),
              _shimmerBox(context, height: 14, width: 14, radius: 4),
            ],
          ),
          const SizedBox(height: 16),
          _shimmerBox(context, height: 28, width: 36),
          const SizedBox(height: 8),
          _shimmerBox(context, height: 12, width: 80),
          const SizedBox(height: 12),
          _shimmerBox(context, height: 12, width: 100),
        ],
      ),
    );
  }

  Widget _shimmerWideStatCard(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(context, height: 12, width: 60),
          const SizedBox(height: 12),
          _shimmerBox(context, height: 28, width: 40),
          const SizedBox(height: 12),
          _shimmerBox(context, height: 12, width: 100),
        ],
      ),
    );
  }

  Widget _shimmerBookingItem(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _shimmerBox(context, height: 44, width: 44, radius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(context, height: 14, width: 120),
                const SizedBox(height: 8),
                _shimmerBox(context, height: 12, width: 80),
              ],
            ),
          ),
          _shimmerBox(context, height: 28, width: 70, radius: 14),
        ],
      ),
    );
  }
}