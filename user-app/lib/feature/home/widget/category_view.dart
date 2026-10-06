import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  /// Category name â†’ Material icon (local fallback jab API image na aaye)
  static IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('clean')) return Icons.cleaning_services_rounded;
    if (n.contains('pipe') || n.contains('leak') || n.contains('plumb')) {
      return Icons.plumbing_rounded;
    }
    if (n.contains('fan')) return Icons.air_rounded;
    if (n.contains('ac') || n.contains('air con') || n.contains('cool')) {
      return Icons.ac_unit_rounded;
    }
    if (n.contains('electric') || n.contains('wiring')) {
      return Icons.electrical_services_rounded;
    }
    if (n.contains('paint') || n.contains('wall')) {
      return Icons.format_paint_rounded;
    }
    if (n.contains('pest') || n.contains('insect')) {
      return Icons.pest_control_rounded;
    }
    if (n.contains('appliance') || n.contains('repair')) {
      return Icons.home_repair_service_rounded;
    }
    if (n.contains('garden') || n.contains('lawn') || n.contains('landscap')) {
      return Icons.yard_rounded;
    }
    if (n.contains('car') || n.contains('wash') || n.contains('detail')) {
      return Icons.local_car_wash_rounded;
    }
    if (n.contains('move') || n.contains('pack') || n.contains('shift')) {
      return Icons.inventory_2_rounded;
    }
    if (n.contains('beauty') || n.contains('salon') || n.contains('spa')) {
      return Icons.spa_rounded;
    }
    if (n.contains('tutor') || n.contains('teach') || n.contains('educat')) {
      return Icons.school_rounded;
    }
    if (n.contains('health') || n.contains('doctor') || n.contains('nurs')) {
      return Icons.health_and_safety_rounded;
    }
    if (n.contains('pet')) return Icons.pets_rounded;
    if (n.contains('web') || n.contains('software') || n.contains('dev')) {
      return Icons.laptop_mac_rounded;
    }
    if (n.contains('legal') || n.contains('law')) return Icons.gavel_rounded;
    if (n.contains('event') || n.contains('party')) {
      return Icons.celebration_rounded;
    }
    return Icons.home_repair_service_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Light mode: light grey so cards stand out against white scaffold
    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF6F6F6);
    final borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE5E5E5);
    final iconBgColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final primaryColor = isDark
        ? const Color(0xFFF1F1F1)
        : const Color(0xFF141414);

    return GetBuilder<CategoryController>(
      builder: (categoryController) {
        // Keep Home in sync with the real category API list used by the
        // Services tab. Featured/service payloads can contain a different
        // subset and must not create extra category tiles here.
        final categories =
            (categoryController.categoryList ?? const <CategoryModel>[])
                .where((category) => (category.name ?? '').trim().isNotEmpty)
                .toList();

        if (categories.isEmpty) {
          // Show shimmer only if categoryList hasn't been fetched yet
          if (categoryController.categoryList == null) {
            debugPrint('CategoryView: Showing shimmer (categoryList is null)');
            return const CategoryShimmer();
          }
          // Categories loaded but empty after filtering â†’ show nothing
          return const SizedBox();
        }

        // Show max 8 categories + 1 "More" tile (2x4 grid)
        final int catCount = categories.length;
        final int showCount = catCount > 8 ? 8 : catCount;
        // total = showCount categories + 1 More tile
        final int totalItems = showCount + 1;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Services',
                    style: GoogleFonts.manrope(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        Get.toNamed(RouteHelper.getAllCategoriesScreen()),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See all',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: totalItems,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  /// More tile â€” last item
                  if (index >= showCount) {
                    return InkWell(
                      onTap: () =>
                          Get.find<BottomNavController>().goToServicesTab(),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: iconBgColor,
                              ),
                              child: Icon(
                                Icons.grid_view_rounded,
                                color: primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Flexible(
                              child: Text(
                                'more'.tr,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final catName = categories[index].name ?? '';
                  final catImage = categories[index].imageFullPath ?? '';
                  final fallbackIcon = _iconForCategory(catName);

                  return InkWell(
                    onTap: () =>
                        Get.find<BottomNavController>().goToServicesTab(
                          categorySlug: categories[index].slug,
                          categoryId: categories[index].id,
                        ),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: iconBgColor,
                            ),
                            child: catImage.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: CustomImage(
                                      width: 28,
                                      height: 28,
                                      image: catImage,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Icon(
                                    fallbackIcon,
                                    size: 24,
                                    color: primaryColor,
                                  ),
                          ),
                          const SizedBox(height: 8),

                          Flexible(
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                catName,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
        },
      );
  }
}

class CategoryShimmer extends StatelessWidget {
  final bool? fromHomeScreen;

  const CategoryShimmer({super.key, this.fromHomeScreen = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFEEEEEE);
    final shimmerHighlight = isDark
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFF6F6F6);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fromHomeScreen!) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 22,
                  width: 100,
                  decoration: BoxDecoration(
                    color: shimmerBase,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  height: 22,
                  width: 60,
                  decoration: BoxDecoration(
                    color: shimmerBase,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          // Only 4 shimmer tiles (1 row of 4) â€” avoids giant grey block
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              return Shimmer(
                duration: const Duration(seconds: 2),
                enabled: true,
                child: Container(
                  decoration: BoxDecoration(
                    color: shimmerBase,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: shimmerHighlight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 44,
                        decoration: BoxDecoration(
                          color: shimmerHighlight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
