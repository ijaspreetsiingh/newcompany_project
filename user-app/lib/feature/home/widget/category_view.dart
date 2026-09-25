import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  static const List<Color> _circleColors = [
    Color(0xFFF5F5F5),
    Color(0xFFF5F5F5),
    Color(0xFFF5F5F5),
    Color(0xFFF5F5F5),
    Color(0xFFF5F5F5),
    Color(0xFFF5F5F5),
    Color(0xFFF5F5F5),
    Color(0xFFF5F5F5),
    Color(0xFFF5F5F5),
    Color(0xFFF5F5F5),
  ];

  /// Category name → Material icon (local fallback jab API image na aaye)
  static IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('clean')) return Icons.cleaning_services_rounded;
    if (n.contains('pipe') || n.contains('leak') || n.contains('plumb')) return Icons.plumbing_rounded;
    if (n.contains('fan')) return Icons.air_rounded;
    if (n.contains('ac') || n.contains('air con') || n.contains('cool')) return Icons.ac_unit_rounded;
    if (n.contains('electric') || n.contains('wiring')) return Icons.electrical_services_rounded;
    if (n.contains('paint') || n.contains('wall')) return Icons.format_paint_rounded;
    if (n.contains('pest') || n.contains('insect')) return Icons.pest_control_rounded;
    if (n.contains('appliance') || n.contains('repair')) return Icons.home_repair_service_rounded;
    if (n.contains('garden') || n.contains('lawn') || n.contains('landscap')) return Icons.yard_rounded;
    if (n.contains('car') || n.contains('wash') || n.contains('detail')) return Icons.local_car_wash_rounded;
    if (n.contains('move') || n.contains('pack') || n.contains('shift')) return Icons.inventory_2_rounded;
    if (n.contains('pest')) return Icons.bug_report_rounded;
    if (n.contains('beauty') || n.contains('salon') || n.contains('spa')) return Icons.spa_rounded;
    if (n.contains('tutor') || n.contains('teach') || n.contains('educat')) return Icons.school_rounded;
    if (n.contains('health') || n.contains('doctor') || n.contains('nurs')) return Icons.health_and_safety_rounded;
    if (n.contains('pet')) return Icons.pets_rounded;
    if (n.contains('web') || n.contains('software') || n.contains('dev')) return Icons.laptop_mac_rounded;
    if (n.contains('legal') || n.contains('law')) return Icons.gavel_rounded;
    if (n.contains('event') || n.contains('party')) return Icons.celebration_rounded;
    return Icons.home_repair_service_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (categoryController) {

      return categoryController.categoryList != null && categoryController.categoryList!.isEmpty ? const SizedBox() :
      categoryController.categoryList != null ? Center(
        child: SizedBox(width: Dimensions.webMaxWidth,
          child: Padding(padding: const EdgeInsets.symmetric( vertical:Dimensions.paddingSizeDefault),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              TitleWidget(
                title: 'services',
                onTap: ()=> Get.toNamed(RouteHelper.getAllCategoriesScreen()),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: categoryController.categoryList!.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: Dimensions.paddingSizeSmall,
                  mainAxisSpacing: Dimensions.paddingSizeDefault,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {

                  /// More tile
                  if (index >= categoryController.categoryList!.length) {
                    return InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getAllCategoriesScreen()),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Column(children: [
                        Container(
                          height: 62, width: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Get.isDarkMode
                                ? Theme.of(context).cardColor
                                : const Color(0xFFF5F5F5),
                            border: Border.all(
                              color: Theme.of(context).hintColor.withValues(alpha:0.2),
                            ),
                          ),
                          child: Icon(Icons.more_horiz, color: Theme.of(context).textTheme.bodyMedium?.color, size: 28),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Flexible(
                          child: Text(
                            'more'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    );
                  }

                  final colorIndex = index % _circleColors.length;
                  final catName = categoryController.categoryList?[index].name ?? '';
                  final catImage = categoryController.categoryList?[index].imageFullPath ?? '';
                  final fallbackIcon = _iconForCategory(catName);

                  return TextHover(builder: (hovered){
                    return InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                        categoryController.categoryList![index].slug!,
                        categoryController.categoryList?[index].name ?? '',
                        index.toString(),
                      )),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Column(children: [
                        Container(
                          height: 62, width: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Get.isDarkMode
                                ? Theme.of(context).cardColor
                                : _circleColors[colorIndex],
                            border: Border.all(
                              color: Theme.of(context).hintColor.withValues(alpha:0.15),
                            ),
                          ),
                          child: Center(
                            child: catImage.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: CustomImage(
                                      width: 38,
                                      height: 38,
                                      image: catImage,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Icon(
                                    fallbackIcon,
                                    size: 30,
                                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87,
                                  ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Flexible(child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            catName,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              fontWeight: hovered ? FontWeight.w600 : FontWeight.w400,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),

                      ]),
                    );
                  });
                },
              ),
            ]),
          ),
        ),
      ) : const CategoryShimmer();
    });
  }
}


class CategoryShimmer extends StatelessWidget {
  final bool? fromHomeScreen;

  const CategoryShimmer({super.key, this.fromHomeScreen=true});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: Column(
          children: [
            if(fromHomeScreen!) const SizedBox(height: Dimensions.paddingSizeLarge,),
            if(fromHomeScreen!) Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 25, width: 120,
                  decoration: BoxDecoration(
                    color: Get.isDarkMode ? Theme.of(context).cardColor : Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: Get.isDarkMode ? null : cardShadow,
                  ),
                ), Container(
                  height: 25, width: 100,
                  decoration: BoxDecoration(
                    color: Get.find<ThemeController>().darkTheme ?  Theme.of(context).cardColor : Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: Get.isDarkMode ? null : cardShadow,
                  ),
                ),
              ],),
            if(fromHomeScreen!)const SizedBox(height: Dimensions.paddingSizeSmall,),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: 8,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 62, width: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                      ),
                      child: Shimmer(
                        duration: const Duration(seconds: 2),
                        enabled: true,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).shadowColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      height: 12, width: 55,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                    ),
                  ],
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: Dimensions.paddingSizeSmall,
                mainAxisSpacing: Dimensions.paddingSizeDefault,
                childAspectRatio: 0.82,
              ),
            ),

            SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeLarge,)
          ],
        ),
      ),
    );
  }
}
