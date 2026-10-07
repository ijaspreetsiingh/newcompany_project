import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AreaViewWidget extends StatelessWidget {
  const AreaViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    String? zoneId = Get.find<LocationController>().getUserAddress()?.zoneId!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GetBuilder<ServiceAreaController>(
      builder: (serviceAreaController) {
        return serviceAreaController.zoneList == null
            ? const AvailableAreaShimmer()
            : GridView.builder(
                key: UniqueKey(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  crossAxisCount: ResponsiveHelper.isMobile(context)
                      ? 2
                      : ResponsiveHelper.isTab(context)
                          ? 3
                          : 3,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: serviceAreaController.zoneList?.length,
                itemBuilder: (context, index) {
                  final isSelected =
                      zoneId == serviceAreaController.zoneList![index].id;
                  final bgColor = isSelected
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                      : isDark
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFF8F8F8);
                  final borderColor = isSelected
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
                      : isDark
                          ? const Color(0xFF333333)
                          : const Color(0xFFE5E5E5);

                  return Column(
                    children: [
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              'your_area'.tr,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 24),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(RouteHelper.getPickMapRoute(
                              "",
                              true,
                              'false',
                              serviceAreaController.zoneList![index],
                              Get.find<LocationController>().getUserAddress(),
                            ));
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderColor,
                                width: isSelected ? 2 : 1.5,
                              ),
                              color: bgColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.08,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 28,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : isDark
                                          ? const Color(0xFFB3B3B3)
                                          : const Color(0xFF7D7D7D),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  serviceAreaController.zoneList![index].name!,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : isDark
                                            ? const Color(0xFFF1F1F1)
                                            : const Color(0xFF141414),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
      },
    );
  }
}

class AvailableAreaShimmer extends StatelessWidget {
  const AvailableAreaShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer(
      child: GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          crossAxisCount: ResponsiveHelper.isMobile(context)
              ? 2
              : ResponsiveHelper.isTab(context)
                  ? 3
                  : 3,
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: ResponsiveHelper.isMobile(context) ? 4 : 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
