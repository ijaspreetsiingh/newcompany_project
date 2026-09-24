import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:showcaseview/showcaseview.dart';

class SubCategoryView extends StatelessWidget {
  final List<ServiceSubCategoryModel> subCategoryList;
  final GlobalKey subscribeKey;
  const SubCategoryView({
    super.key,
    required this.subCategoryList,
    required this.subscribeKey,
  });
  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return subCategoryList.isEmpty &&
            !Get.find<ServiceCategoryController>().isSubCategoryLoading
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomShowCaseWidget(
                  isActive: true,
                  showcaseKey: subscribeKey,
                  showArrow: false,
                  child: SizedBox(),
                ),

                Text(
                  "no_sub_category_found".tr,
                  style: robotoMedium.copyWith(
                    fontSize: 16,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              ],
            ),
          )
        : Get.find<ServiceCategoryController>().isSubCategoryLoading
        ? const SubCategoryItemShimmer()
        : Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isTab(context) ? 2 : 1,
                    mainAxisExtent: 172,
                  ),
                  controller:
                      Get.find<ServiceCategoryController>().scrollController,
                  itemCount: subCategoryList.length,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    int totalService = 0;
                    for (var element in subCategoryList[index].services!) {
                      if (element.isActive == 1) {
                        totalService++;
                      }
                    }
                    return GetBuilder<ServiceCategoryController>(
                      builder: (allServiceController) {
                        final bool isSubscribed =
                            subCategoryList[index].isSubscribed == 1;

                        return Container(
                          margin: const EdgeInsets.fromLTRB(
                            Dimensions.paddingSizeDefault,
                            2,
                            Dimensions.paddingSizeDefault,
                            Dimensions.paddingSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: context.customThemeColors.cardShadow,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusExtraLarge,
                            ),
                            border: Border.all(
                              color: isSubscribed
                                  ? primary.withValues(alpha: 0.25)
                                  : Theme.of(
                                      context,
                                    ).hintColor.withValues(alpha: 0.08),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusExtraLarge,
                            ),
                            onTap: () {
                              Get.to(
                                ServicesScreen(
                                  subcategoryModel: allServiceController
                                      .serviceSubCategoryList[index],
                                  fromPage: 'category',
                                  index: index,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeDefault,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall - 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primary.withValues(
                                            alpha: 0.07,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusSmall,
                                          ),
                                          child: CustomImage(
                                            height: 54,
                                            width: 54,
                                            fit: BoxFit.cover,
                                            image:
                                                '${subCategoryList[index].imageFullPath}',
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        width: Dimensions.paddingSizeSmall,
                                      ),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    subCategoryList[index].name
                                                        .toString(),
                                                    style: robotoBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isSubscribed)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: context
                                                          .customThemeColors
                                                          .success
                                                          .withValues(
                                                            alpha: 0.12,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            50,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      size: 14,
                                                      color: context
                                                          .customThemeColors
                                                          .success,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            Text(
                                              subCategoryList[index].description
                                                  .toString(),
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall -
                                                    1,
                                                color: Theme.of(
                                                  context,
                                                ).hintColor,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),
                                  Divider(
                                    thickness: 0.5,
                                    height: 1,
                                    color: Theme.of(
                                      context,
                                    ).hintColor.withValues(alpha: 0.12),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),

                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeSmall,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primary.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.grid_view_rounded,
                                              size: 13,
                                              color: primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "${'services'.tr} ($totalService)",
                                              style: robotoSemiBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Spacer(),

                                      CustomShowCaseWidget(
                                        showcaseKey: subscribeKey,
                                        isActive: index == 0,
                                        child: GetBuilder<ServiceCategoryController>(
                                          builder: (allService) {
                                            return Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                onTap: isSubscribed
                                                    ? null
                                                    : () {
                                                        Get.find<
                                                              BusinessSubscriptionController
                                                            >()
                                                            .openTrialEndBottomSheet()
                                                            .then((isTrail) {
                                                              if (isTrail) {
                                                                int?
                                                                isSubscribe =
                                                                    subCategoryList[index]
                                                                        .isSubscribed;
                                                                showCustomBottomSheet(
                                                                  child: SubscribeUnsubscribeBottomSheet(
                                                                    isSubscribe:
                                                                        isSubscribe ==
                                                                            1
                                                                        ? false
                                                                        : true,
                                                                    subCategoryModel:
                                                                        subCategoryList[index],
                                                                    index:
                                                                        index,
                                                                    fromPage:
                                                                        'category',
                                                                  ),
                                                                );
                                                              }
                                                            });
                                                      },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeDefault,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    gradient: isSubscribed
                                                        ? null
                                                        : LinearGradient(
                                                            colors: [
                                                              primary,
                                                              Color.lerp(
                                                                primary,
                                                                const Color(
                                                                  0xFF1E40AF,
                                                                ),
                                                                0.45,
                                                              )!,
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                    color: isSubscribed
                                                        ? context
                                                              .customThemeColors
                                                              .success
                                                              .withValues(
                                                                alpha: 0.10,
                                                              )
                                                        : null,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          50,
                                                        ),
                                                    boxShadow: isSubscribed
                                                        ? null
                                                        : [
                                                            BoxShadow(
                                                              color: primary
                                                                  .withValues(
                                                                    alpha: 0.30,
                                                                  ),
                                                              blurRadius: 8,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    3,
                                                                  ),
                                                            ),
                                                          ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        isSubscribed
                                                            ? Icons
                                                                  .check_circle_rounded
                                                            : Icons
                                                                  .add_circle_outline_rounded,
                                                        size: 14,
                                                        color: isSubscribed
                                                            ? context
                                                                  .customThemeColors
                                                                  .success
                                                            : Colors.white,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        isSubscribed
                                                            ? "already_subscribed"
                                                                  .tr
                                                            : "subscribe".tr,
                                                        style: robotoSemiBold.copyWith(
                                                          color: isSubscribed
                                                              ? context
                                                                    .customThemeColors
                                                                    .success
                                                              : Colors.white,
                                                          fontSize:
                                                              Get.width < 350
                                                              ? Dimensions
                                                                        .fontSizeSmall -
                                                                    2
                                                              : Dimensions
                                                                    .fontSizeSmall,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Get.find<ServiceCategoryController>().isPaginationLoading
                  ? CircularProgressIndicator(
                      color: Theme.of(context).hoverColor,
                    )
                  : const SizedBox.shrink(),
            ],
          );
  }
}

class CustomShowCaseWidget extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final bool showArrow;
  final GlobalKey? showcaseKey;
  const CustomShowCaseWidget({
    super.key,
    required this.child,
    required this.isActive,
    required this.showcaseKey,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return isActive && showcaseKey != null
        ? Showcase(
            showArrow: showArrow,
            key: showcaseKey!,

            descTextStyle: robotoRegular,
            descriptionPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            tooltipBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            tooltipPosition: TooltipPosition.top,
            tooltipActions: [
              TooltipActionButton(
                type: null,
                backgroundColor: Colors.transparent,
              ),

              TooltipActionButton(
                type: TooltipDefaultActionType.next,
                name: 'got_it'.tr.toUpperCase(),
                backgroundColor: Colors.transparent,
                textStyle: robotoBold.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),

              TooltipActionButton(
                type: null,
                backgroundColor: Colors.transparent,
              ),
            ],
            description: 'you_can_subscribe_to_your_preferred_service'.tr,
            child: child,
          )
        : child;
  }
}
