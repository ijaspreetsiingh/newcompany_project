import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.title,
    required this.selectedCategory,
    required this.image,
    required this.index,
  });
  final String title;
  final String image;
  final String selectedCategory;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceCategoryController>(
      builder: (serviceCategoryController) {
        final bool isSelected = selectedCategory == title;
        final Color primary = Theme.of(context).primaryColor;

        return Container(
          margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeExtraSmall + 2,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      primary,
                      Color.lerp(primary, const Color(0xFF1E40AF), 0.45)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            border: isSelected
                ? null
                : Border.all(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.12),
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : context.customThemeColors.lightShadow,
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : primary.withValues(alpha: 0.08),
                  ),
                  padding: const EdgeInsets.all(
                    Dimensions.paddingSizeExtraSmall,
                  ),
                  child: CustomImage(height: 22, width: 22, image: image),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall - 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 82),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall + 1,
                      height: 1.2,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
