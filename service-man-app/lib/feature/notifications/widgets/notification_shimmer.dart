import 'package:demandium_serviceman/utils/core_export.dart';


class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({super.key}) ;

  Widget _block(BuildContext context, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.kMuted,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 3),
      direction: const ShimmerDirection.fromLTRB(),
      child: ListView.builder(
        itemCount: 10,
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeLarge,
          horizontal: Dimensions.paddingSizeLarge,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.kMuted,
                    borderRadius: BorderRadius.circular(kRadiusMd),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _block(context, width: 180, height: 14),
                      const SizedBox(height: 8),
                      _block(context, width: double.infinity, height: 10),
                      const SizedBox(height: 6),
                      _block(context, width: 140, height: 10),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                _block(context, width: 42, height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
