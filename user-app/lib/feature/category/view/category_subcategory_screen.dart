import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

/// nest. style single screen : Category chips (top) + Sub Categories (below)
/// Reference flow : "All Categories" aur "Available Service" dono ka kaam ek hi screen pe
/// - Upar horizontal category chips (selected = black pill)
/// - Niche selected category ke sub categories (bordered rows, live update)
class CategorySubCategoryScreen extends StatefulWidget {
  final String categorySlug;
  final String categoryIndex;
  const CategorySubCategoryScreen({super.key, required this.categorySlug, required this.categoryIndex}) ;

  @override
  State<CategorySubCategoryScreen> createState() => _CategorySubCategoryScreenState();
}

class _CategorySubCategoryScreenState extends State<CategorySubCategoryScreen> {
  AutoScrollController? scrollController;
  String? categoryIndex;
  int availableServiceCount = 0;

  @override
  void initState() {
    scrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );
    scrollController!.scrollToIndex(int.tryParse(widget.categoryIndex) ?? 0, preferPosition: AutoScrollPosition.middle);
    scrollController!.highlight(int.tryParse(widget.categoryIndex) ?? 0);

    if(Get.find<LocationController>().getUserAddress() !=null){
      availableServiceCount = Get.find<LocationController>().getUserAddress()!.availableServiceCountInZone!;
    }

    Get.find<CategoryController>().getCategoryList(false);
    categoryIndex = widget.categoryIndex ;
    if (widget.categorySlug.isNotEmpty) {
      Get.find<CategoryController>().getSubCategoryList(widget.categorySlug, shouldUpdate: false);
    } else {
      /// All Categories se bina slug ke aaye : pehli category auto-select
      /// Post-frame callback - build phase ke bahar (setState/update during build error se bachne ke liye)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadFirstCategorySubCategories();
        }
      });
    }

    super.initState();
  }

  /// Empty slug case : category list load hone tak wait, phtr pehli category ke sub categories
  Future<void> _loadFirstCategorySubCategories() async {
    final CategoryController controller = Get.find<CategoryController>();
    int tries = 0;
    while ((controller.categoryList == null || controller.categoryList!.isEmpty) && tries < 20) {
      await Future.delayed(const Duration(milliseconds: 150));
      tries++;
    }
    final list = controller.categoryList;
    if (list != null && list.isNotEmpty && mounted) {
      /// Plain assignment - GetBuilder update() se rebuild hoga, setState ki zaroorat nahi
      categoryIndex = '0';
      controller.getSubCategoryList(list.first.slug!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: GetBuilder<CategoryController>(
        builder: (categoryController) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
            endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
            appBar: CustomAppBar(title: 'available_service'.tr,),
            body: availableServiceCount > 0 ?
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              /// â”€â”€ Category chips (nest. pills) â”€â”€
              SizedBox(
                height: ResponsiveHelper.isDesktop(context) ? 150 : 136,
                child: (categoryController.categoryList != null && !categoryController.isSearching!) ?
                ListView.builder(
                  shrinkWrap: true,
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryController.categoryList!.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    CategoryModel categoryModel = categoryController.categoryList!.elementAt(index);
                    final bool isSelected = index == int.parse(categoryIndex!);

                    return AutoScrollTag(
                      controller: scrollController!,
                      key: ValueKey(index),
                      index: index,
                      child: InkWell(
                        onTap: () {
                          setState(() => categoryIndex = index.toString());
                          Get.find<CategoryController>().getSubCategoryList(categoryModel.slug!);
                          scrollController!.scrollToIndex(index, preferPosition: AutoScrollPosition.middle,
                            duration: const Duration(milliseconds: 400),
                          );
                          scrollController!.highlight(index);
                        },
                        hoverColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        child: Container(
                          width: ResponsiveHelper.isDesktop(context) ? 120 : 96,
                          margin: const EdgeInsetsDirectional.only(end: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            /// nest. pill : selected = black fill, unselected = bordered card
                            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                            border: isSelected ? null : Border.all(
                              color: Theme.of(context).primaryColorLight.withValues(alpha: Get.isDarkMode ? 0.4 : 1),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              /// Icon circle - selected = white circle, unselected = grey circle
                              Container(
                                height: 46, width: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? (Get.isDarkMode ? Colors.black : Colors.white)
                                      : Theme.of(context).primaryColorLight,
                                ),
                                child: Center(
                                  child: CustomImage(
                                    fit: BoxFit.contain,
                                    height: 26, width: 26,
                                    image: categoryModel.imageFullPath ?? '',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              /// Label
                              Text(categoryModel.name ?? '',
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  height: 1.2,
                                  color: isSelected
                                      ? (Get.isDarkMode ? Colors.black : Colors.white)
                                      : Theme.of(context).textTheme.bodySmall?.color,
                                ),
                                maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
                              ),
                            ]),
                        ),
                      ),
                    );
                  },
                ) : ResponsiveHelper.isDesktop(context)
                    ? const CategoryShimmer(fromHomeScreen: false,)
                    : const _ChipsShimmer(),
              ),

              /// Hatrline divider - nest. style
              Divider(height: 1, thickness: 1,
                color: Theme.of(context).primaryColorLight.withValues(alpha: Get.isDarkMode ? 0.4 : 1)),

              /// â”€â”€ Sub Categories header â”€â”€
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault, Dimensions.paddingSizeLarge,
                  Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
                ),
                child: Text('sub_categories'.tr, style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                )),
              ),

              /// â”€â”€ Sub Categories list (live update on chip tap) â”€â”€
              Expanded(child: _SubCategoriesBody(categoryController: categoryController)),
            ]) :
            SizedBox( height: MediaQuery.of(context).size.height*.6, child: const ServiceNotAvailableScreen()),
          );
        },
      ),
    );
  }
}

/// Sub categories body : nest. bordered rows / shimmer / no-data
class _SubCategoriesBody extends StatelessWidget {
  final CategoryController categoryController;
  const _SubCategoriesBody({required this.categoryController});

  @override
  Widget build(BuildContext context) {
    if (categoryController.subCategoryList == null) {
      return const NestSubCategoryShimmer();
    }

    final List<CategoryModel> subCategoryList = categoryController.subCategoryList ?? [];

    if (subCategoryList.isEmpty) {
      return NoDataScreen(
        text: 'no_subcategory_found'.tr,
        type: NoDataType.categorySubcategory,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault, 0,
        Dimensions.paddingSizeDefault, Dimensions.paddingSizeLarge,
      ),
      itemCount: subCategoryList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: NestSubCategoryRow(categoryModel: subCategoryList[index]),
        );
      },
    );
  }
}

/// nest. sub category row : rounded image left, name + description, "N services" badge right
class NestSubCategoryRow extends StatelessWidget {
  final CategoryModel categoryModel;
  const NestSubCategoryRow({super.key, required this.categoryModel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.find<ServiceController>().cleanSubCategory();
        Get.toNamed(RouteHelper.allServiceScreenRoute(categoryModel.slug!.toString()));
      },
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          border: Border.all(
            color: Theme.of(context).primaryColorLight.withValues(alpha: Get.isDarkMode ? 0.4 : 1),
          ),
        ),
        child: Row(children: [

          /// Image 72x72 rounded
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: CustomImage(
              image: categoryModel.imageFullPath ?? '',
              height: 72, width: 72, fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          /// Name + description
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(categoryModel.name ?? '',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              if ((categoryModel.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(categoryModel.description ?? '',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 5),
              /// Service count - nest. grey badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraMoreLarge),
                ),
                child: Text('${categoryModel.serviceCount ?? 0} ${'services'.tr}',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ]),
          ),

          Icon(Icons.chevron_right_rounded, size: 20, color: Theme.of(context).hintColor),
        ]),
      ),
    );
  }
}

/// Chips shimmer while categories load
class _ChipsShimmer extends StatelessWidget {
  const _ChipsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        width: 96,
        margin: const EdgeInsetsDirectional.only(end: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          border: Border.all(
            color: Theme.of(context).primaryColorLight.withValues(alpha: Get.isDarkMode ? 0.4 : 1),
          ),
        ),
        child: Shimmer(duration: const Duration(seconds: 2), enabled: true,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              height: 46, width: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).shadowColor,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(height: 10, width: 56, color: Theme.of(context).shadowColor),
          ])),
      ),
    );
  }
}

/// Rows shimmer while sub categories load
class NestSubCategoryShimmer extends StatelessWidget {
  const NestSubCategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(children: List.generate(5, (index) => Container(
        height: 96,
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          border: Border.all(
            color: Theme.of(context).primaryColorLight.withValues(alpha: Get.isDarkMode ? 0.4 : 1),
          ),
        ),
        child: Row(children: [
          Shimmer(duration: const Duration(seconds: 2), enabled: true,
            child: Container(
              height: 72, width: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(child: Shimmer(duration: const Duration(seconds: 2), enabled: true,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(height: 12, width: 150, color: Theme.of(context).shadowColor),
              const SizedBox(height: 8),
              Container(height: 10, width: 200, color: Theme.of(context).shadowColor),
              const SizedBox(height: 8),
              Container(height: 14, width: 80, color: Theme.of(context).shadowColor),
            ]),
          )),
        ]),
      ))),
    );
  }
}



