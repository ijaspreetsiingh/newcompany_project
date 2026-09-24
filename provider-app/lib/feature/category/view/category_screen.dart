import 'package:demandium_provider/feature/tutorial/controller/tutorial_controller.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:showcaseview/showcaseview.dart';

class AllServicesScreen extends StatefulWidget {
  final bool isTutorialActive;
  const AllServicesScreen({super.key, required this.isTutorialActive});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  AutoScrollController? menuScrollController;
  final GlobalKey subscribeKey = GlobalKey();

  @override
  void initState() {
    ServiceCategoryController controller = Get.find();

    menuScrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );
    menuScrollController!.scrollToIndex(
      controller.selectedCategory,
      preferPosition: AutoScrollPosition.middle,
    );
    menuScrollController!.highlight(controller.selectedCategory);

    controller.getCategoryList(shouldUpdate: false, reloadSubcategory: true);

    if (widget.isTutorialActive) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCaseWidget.of(context).startShowCase([subscribeKey]),
      );
      Get.find<TutorialController>().updateTutorial(
        key: AppConstants.serviceSubscriptionTutorialKey,
      );
    }

    super.initState();
  }

  Widget _sectionHeader({
    required BuildContext context,
    required String title,
    required int count,
  }) {
    final Color primary = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
      ),
      child: Row(
        children: [
          Container(
            height: 22,
            width: 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary,
                  Color.lerp(primary, const Color(0xFF1E40AF), 0.5)!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(
            title,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              '$count',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: MainAppBar(
        title: 'available_services',
        color: Theme.of(context).primaryColor,
      ),

      body: GetBuilder<ServiceCategoryController>(
        builder: (allServiceController) {
          if (allServiceController.serviceCategoryList == null) {
            return const CategorySubcategoryShimmer();
          } else {
            return allServiceController.serviceCategoryList != null &&
                    allServiceController.serviceCategoryList!.isEmpty
                ? SizedBox(
                    height: Get.height * .8,
                    child: Center(
                      child: NoDataScreen(
                        showCaseKey: subscribeKey,
                        text: "no_available_service".tr,
                        type: NoDataType.service,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Hero banner
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeDefault,
                          Dimensions.paddingSizeSmall,
                          Dimensions.paddingSizeDefault,
                          0,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primary,
                                Color.lerp(
                                  primary,
                                  const Color(0xFF1E40AF),
                                  0.55,
                                )!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusExtraLarge,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.30),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -18,
                                top: -30,
                                child: Container(
                                  height: 110,
                                  width: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.10),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 70,
                                bottom: -42,
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.07),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'available_services'.tr,
                                          style: robotoBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraLarge,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(
                                          height:
                                              Dimensions.paddingSizeExtraSmall,
                                        ),
                                        Text(
                                          'subscribed_categories'.tr,
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.white.withValues(
                                              alpha: 0.85,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.grid_view_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// Categories header
                      _sectionHeader(
                        context: context,
                        title: 'categories'.tr,
                        count:
                            allServiceController.serviceCategoryList?.length ??
                            0,
                      ),

                      /// Horizontal category chips
                      SizedBox(
                        height: 72,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          controller: menuScrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          itemCount:
                              allServiceController.serviceCategoryList?.length,
                          itemBuilder: (context, index) {
                            return AutoScrollTag(
                              controller: menuScrollController!,
                              key: ValueKey(index),
                              index: index,
                              child: GestureDetector(
                                onTap: () async {
                                  allServiceController.changeCategory(index);
                                  allServiceController.getSubCategoryList(
                                    offset: 1,
                                    isFromPagination: false,
                                  );
                                  await menuScrollController!.scrollToIndex(
                                    index,
                                    preferPosition: AutoScrollPosition.middle,
                                    duration: const Duration(milliseconds: 600),
                                  );
                                  await menuScrollController!.highlight(index);
                                },
                                child: CategoryItem(
                                  index: index,
                                  image:
                                      allServiceController
                                          .serviceCategoryList?[index]
                                          .imageFullPath
                                          .toString() ??
                                      "",
                                  title:
                                      allServiceController
                                          .serviceCategoryList?[index]
                                          .name
                                          .toString() ??
                                      "",
                                  selectedCategory:
                                      allServiceController
                                          .serviceCategoryList?[allServiceController
                                              .selectedCategory]
                                          .name
                                          .toString() ??
                                      "",
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      /// Sub categories header
                      _sectionHeader(
                        context: context,
                        title: 'sub_category'.tr,
                        count:
                            allServiceController.serviceSubCategoryList.length,
                      ),

                      /// Sub category grid
                      Expanded(
                        child: SubCategoryView(
                          subCategoryList:
                              allServiceController.serviceSubCategoryList,
                          subscribeKey: subscribeKey,
                        ),
                      ),
                    ],
                  );
          }
        },
      ),
    );
  }
}
