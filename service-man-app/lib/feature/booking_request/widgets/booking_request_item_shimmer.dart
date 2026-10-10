import 'package:jassdbx_serviceman/utils/core_export.dart';

class BookingRequestItemShimmer extends StatelessWidget {
  const BookingRequestItemShimmer({super.key});

  Widget _block(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.kMuted,
        borderRadius: BorderRadius.circular(kRadiusMd),
      ),
    );
  }

  Widget _cardShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.kCard,
          borderRadius: BorderRadius.circular(kRadiusMd),
          border: Border.all(color: context.kBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _block(context, 74, 22),
                const Spacer(),
                _block(context, 56, 14),
              ],
            ),
            const SizedBox(height: 12),
            _block(context, 170, 16),
            const SizedBox(height: 12),
            _block(context, 220, 12),
            const SizedBox(height: 8),
            _block(context, 150, 12),
            const SizedBox(height: 12),
            Container(height: 1, color: context.kBorder),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: _block(context, 96, 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 3),
      interval: const Duration(seconds: 5),
      colorOpacity: 0,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: ListView.builder(
        itemBuilder: (context, index) => _cardShimmer(context),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: 8,
      ),
    );
  }
}
