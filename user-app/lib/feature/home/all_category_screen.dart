import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

/// nest. style All Categories screen (reference: design_refrence/home-harmony-hub)
/// 3-col bordered cards, grey circle icon, bold label - overflow safe layout
class AllCategoryScreen extends StatelessWidget {
  const AllCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
        endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        appBar: CustomAppBar(title: 'all_categories'.tr),
        body: FooterBaseView(
          child: SizedBox(
            width: isDesktop ? Dimensions.webMaxWidth : null,
            child: GetBuilder<CategoryController>(builder: (categoryController) {
              return Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isMobile(context) ? 3 : 4,
                      crossAxisSpacing: Dimensions.paddingSizeSmall,
                      mainAxisSpacing: Dimensions.paddingSizeSmall,
                      /// generous height ratio - text 2 lines ke saath overflow safe
                      childAspectRatio: MediaQuery.of(context).size.width < 400 ? 0.72 : 0.78,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryController.categoryList?.length ?? 0,
                    itemBuilder: (context, index) {
                      return TextHover(builder: (hovered){
                        return InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                            categoryController.categoryList![index].slug!,
                            categoryController.categoryList?[index].name ?? '',
                            index.toString(),
                          )),
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeExtraSmall,
                              vertical: Dimensions.paddingSizeDefault,
                            ),
                            decoration: BoxDecoration(
                              /// nest. style : flat bordered card
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                              border: Border.all(
                                color: Theme.of(context).primaryColorLight.withValues(alpha: Get.isDarkMode ? 0.4 : 1),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                /// Grey circle icon - nest. style
                                Container(
                                  height: 56,
                                  width: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: CustomImage(
                                        width: 32,
                                        height: 32,
                                        image: categoryController.categoryList?[index].imageFullPath ?? "",
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                /// Label - fixed 2 lines, no overflow
                                Text(
                                  categoryController.categoryList?[index].name ?? '',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    height: 1.2,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    fontWeight: hovered ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    }),
              );
            }),
          ),
        ),
      ),
    );
  }
}

