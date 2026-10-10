import 'package:jassdbx_serviceman/utils/core_export.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header (avatar + greeting/name + icon buttons)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Row(
                children: [
                  _shimmerBox(context, height: 44, width: 44, radius: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(context, height: 10, width: 110, radius: 5),
                        const SizedBox(height: 8),
                        _shimmerBox(context, height: 16, width: 140),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _shimmerBox(context, height: 36, width: 36),
                  const SizedBox(width: 4),
                  _shimmerBox(context, height: 36, width: 36),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Work availability card
                  _shimmerBox(context, height: 78),
                  const SizedBox(height: 16),

                  // Stats row (3 tiles)
                  Row(
                    children: [
                      Expanded(child: _shimmerBox(context, height: 64)),
                      const SizedBox(width: 8),
                      Expanded(child: _shimmerBox(context, height: 64)),
                      const SizedBox(width: 8),
                      Expanded(child: _shimmerBox(context, height: 64)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick actions header + 4 tiles
                  _shimmerBox(context, height: 18, width: 150),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _shimmerBox(context, height: 80)),
                      const SizedBox(width: 8),
                      Expanded(child: _shimmerBox(context, height: 80)),
                      const SizedBox(width: 8),
                      Expanded(child: _shimmerBox(context, height: 80)),
                      const SizedBox(width: 8),
                      Expanded(child: _shimmerBox(context, height: 80)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Earning / this month card
                  _shimmerBox(context, height: 180),
                  const SizedBox(height: 24),

                  // Recent bookings header + list items
                  _shimmerBox(context, height: 18, width: 160),
                  const SizedBox(height: 12),
                  _shimmerBox(context, height: 132),
                  const SizedBox(height: 12),
                  _shimmerBox(context, height: 132),
                  const SizedBox(height: 20),

                  // Refresh button
                  _shimmerBox(context, height: 48),
                  const SizedBox(height: 112),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(
    BuildContext context, {
    required double height,
    double? width,
    double radius = 10,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.kMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
