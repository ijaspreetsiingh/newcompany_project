import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Dashboard par dikhata hai ki admin ne provider ko kitni main category /
/// sub category assign ki hain (naam + count) — tap karne par My Services.
class AssignedCategoriesSection extends StatelessWidget {
  const AssignedCategoriesSection({super.key});

  void _openMyServices({int categoryIndex = 0}) {
    Get.to(() => MyServicesScreen(initialCategoryIndex: categoryIndex));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyServicesController>(
      builder: (controller) {
        if (!controller.hasFetchedOnce) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.ensureLoaded();
          });
          return const SizedBox.shrink();
        }

        final int categoryCount = controller.categories.length;
        final int subCategoryCount = controller.totalSubCategories;
        final bool hasData = categoryCount > 0;

        return InkSection(
          title: 'my_services'.tr,
          action: hasData ? 'manage'.tr : null,
          onAction: hasData ? () => _openMyServices() : null,
          child: InkCard(
            onTap: hasData ? () => _openMyServices() : null,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _countBlock(
                        label: 'main_category'.tr,
                        value: '$categoryCount',
                      ),
                    ),
                    Container(
                      height: 34,
                      width: 1,
                      color: InkColors.border,
                    ),
                    Expanded(
                      child: _countBlock(
                        label: 'sub_category'.tr,
                        value: '$subCategoryCount',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: InkColors.foreground,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'open'.tr,
                        style: robotoSemiBold.copyWith(
                          fontSize: 12,
                          color: InkColors.background,
                        ),
                      ),
                    ),
                  ],
                ),

                if (hasData) ...[
                  const SizedBox(height: 14),
                  Text(
                    'admin_assigned_categories'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: 11,
                      height: 1.3,
                      color: InkColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...controller.categories.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: CategoryChangeBottomSheet.show,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: InkColors.paper,
                                borderRadius:
                                    BorderRadius.circular(Dimensions.radiusSmall),
                                border: Border.all(color: InkColors.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.folder_outlined,
                                    size: 15,
                                    color: InkColors.mutedForeground,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.value.name ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        height: 1.3,
                                        color: InkColors.foreground,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: InkColors.accent,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      '${entry.value.subCategories.length}',
                                      style: robotoBold.copyWith(
                                        fontSize: 10,
                                        height: 1.3,
                                        color: InkColors.foreground,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: InkColors.mutedForeground,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                ] else ...[
                  const SizedBox(height: 10),
                  Text(
                    'no_category_assigned'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      height: 1.4,
                      color: InkColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _countBlock({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkEyebrow(label),
        const SizedBox(height: 4),
        Text(
          value,
          style: displayBold.copyWith(
            fontSize: 22,
            height: 1.1,
            color: InkColors.foreground,
          ),
        ),
      ],
    );
  }
}
