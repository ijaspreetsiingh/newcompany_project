import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

/// nest. style skeleton loader (Services tab / See All screen)
/// Layout new list se exactly match karta hai :
/// chips â†’ count line â†’ filter buttons â†’ bordered service rows
class SearchShimmerWidget extends StatelessWidget {
  const SearchShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Color base = Theme.of(context).shadowColor;
    final bool isDark = Get.isDarkMode;

    return Center(
      child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            /// â”€â”€ Category chips skeleton â”€â”€
            SizedBox(
              height: 62,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  final double width = index == 0 ? 70 : (index % 2 == 0 ? 110 : 95);
                  return Container(
                    height: 38,
                    width: width,
                    margin: const EdgeInsetsDirectional.only(end: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : base,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraMoreLarge),
                    ),
                  );
                },
              ),
            ),

            /// â”€â”€ Count line skeleton â”€â”€
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
                Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
              ),
              child: Container(
                height: 12, width: 100,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : base,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
            ),

            /// â”€â”€ Sort / Filter buttons skeleton â”€â”€
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault, 0,
                Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
              ),
              child: Row(children: [
                _box(context, 40, 40, base, isDark, radius: Dimensions.radiusDefault),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                _box(context, 40, 40, base, isDark, radius: Dimensions.radiusDefault),
              ]),
            ),

            /// â”€â”€ Service rows skeleton (nest. bordered rows jaisa) â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Column(children: List.generate(6, (index) => Container(
                height: 96,
                margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                  border: Border.all(
                    color: Theme.of(context).primaryColorLight.withValues(alpha: isDark ? 0.4 : 1),
                  ),
                ),
                child: Row(children: [

                  /// Image placeholder
                  Container(
                    height: 72, width: 72,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : base,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  /// Text lines placeholder (name, rating, price)
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(height: 13, width: 160,
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : base),
                      const SizedBox(height: 9),
                      Container(height: 10, width: 100,
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : base),
                      const SizedBox(height: 9),
                      Container(height: 10, width: 70,
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : base),
                    ]),
                  ),

                  /// Chevron placeholder
                  Container(
                    height: 16, width: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : base,
                    ),
                  ),
                ]),
              ))),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _box(BuildContext context, double height, double width, Color base, bool isDark, {double radius = Dimensions.radiusSmall}) {
    return Container(
      height: height, width: width,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

