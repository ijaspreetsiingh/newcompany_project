import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class CategoryItemShimmer extends StatelessWidget {
  final int index;
  const CategoryItemShimmer({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceCategoryController>(builder: (serviceCategoryController){
      return Container(
        width: 96,
        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          color: Get.isDarkMode? Colors.grey.shade700 : Colors.grey.shade100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              height: 34,
              width: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Container(
                  color: Theme.of(context).hintColor.withValues(alpha:0.2),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              width: 60,
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).hintColor.withValues(alpha:0.2),
              ),
            ),
          ],
        ),
      );
    });
  }
}
