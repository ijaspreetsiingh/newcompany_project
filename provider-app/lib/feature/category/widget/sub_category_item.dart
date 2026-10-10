import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:showcaseview/showcaseview.dart';

class SubCategoryView extends StatelessWidget {
  final List<ServiceSubCategoryModel> subCategoryList;
  final GlobalKey subscribeKey;
  const SubCategoryView({
    super.key,
    required this.subCategoryList,
    required this.subscribeKey,
  });

  void _openServices({
    required ServiceCategoryController controller,
    required int index,
  }) {
    Get.to(
      ServicesScreen(
        subcategoryModel: controller.serviceSubCategoryList[index],
        fromPage: 'category',
        index: index,
      ),
    );
  }

  /// Shown instead of the "no subcategory" message when the API call failed
  /// (server unreachable / no internet) so the user can simply retry.
  Widget _loadFailedState(ServiceCategoryController controller) {
    return InkCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 30,
            color: InkColors.mutedForeground,
          ),
          const SizedBox(height: 10),
          Text(
            'something_went_wrong'.tr,
            textAlign: TextAlign.center,
            style: robotoSemiBold.copyWith(
              fontSize: 13.5,
              height: 1.3,
              color: InkColors.foreground,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 150,
            child: CustomButton(
              onPressed: () => controller.getSubCategoryList(
                offset: 1,
                isFromPagination: false,
              ),
              btnTxt: 'retry'.tr,
              icon: Icons.refresh_rounded,
              height: 38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ServiceCategoryController controller = Get.find<
      ServiceCategoryController
    >();

    if (subCategoryList.isEmpty && !controller.isSubCategoryLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            CustomShowCaseWidget(
              isActive: true,
              showcaseKey: subscribeKey,
              showArrow: false,
              child: const SizedBox.shrink(),
            ),
            controller.hasSubCategoryLoadFailed
                ? _loadFailedState(controller)
                : InkEmptyState('no_sub_category_found'.tr),
          ],
        ),
      );
    }

    if (controller.isSubCategoryLoading) {
      return const SizedBox(height: 420, child: SubCategoryItemShimmer());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (int index = 0; index < subCategoryList.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _subCategoryCard(context, controller, index),
            ),
        ],
      ),
    );
  }

  Widget _subCategoryCard(
    BuildContext context,
    ServiceCategoryController controller,
    int index,
  ) {
    final ServiceSubCategoryModel subCategory = subCategoryList[index];
    final bool isSubscribed = subCategory.isSubscribed == 1;

    int totalService = 0;
    for (var element in subCategory.services ?? <ServiceModel>[]) {
      if (element.isActive == 1) {
        totalService++;
      }
    }

    return GetBuilder<ServiceCategoryController>(
      builder: (allServiceController) {
        final Widget card = InkCard(
          padding: const EdgeInsets.all(16),
          onTap: () =>
              _openServices(controller: allServiceController, index: index),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: InkColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CustomImage(
                      height: 54,
                      width: 54,
                      fit: BoxFit.cover,
                      image: '${subCategory.imageFullPath}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subCategory.name.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoBold.copyWith(
                                  fontSize: 14,
                                  height: 1.3,
                                  color: InkColors.foreground,
                                ),
                              ),
                            ),
                            if (isSubscribed) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: InkColors.accent,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  'assigned_to_you'.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoSemiBold.copyWith(
                                    fontSize: 10,
                                    height: 1.2,
                                    color: InkColors.foreground,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: InkColors.foreground,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subCategory.description.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                            fontSize: 12,
                            height: 1.4,
                            color: InkColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
               Divider(height: 1, thickness: 1, color: InkColors.border),
              const SizedBox(height: 14),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: InkColors.secondary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Icon(
                          Icons.grid_view_rounded,
                          size: 13,
                          color: InkColors.foreground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${'services'.tr} ($totalService)",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoSemiBold.copyWith(
                            fontSize: 12,
                            color: InkColors.foreground,
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
                        final bool subscribed =
                            allService
                                .serviceSubCategoryList[index]
                                .isSubscribed ==
                            1;

                        return GestureDetector(
                          onTap: subscribed
                              ? null
                              : () {
                                  Get.find<
                                        BusinessSubscriptionController
                                      >()
                                      .openTrialEndBottomSheet()
                                      .then((isTrail) {
                                        if (isTrail) {
                                          showCustomBottomSheet(
                                            child: SubscribeUnsubscribeBottomSheet(
                                              isSubscribe: !subscribed,
                                              subCategoryModel:
                                                  allService
                                                      .serviceSubCategoryList[index],
                                              index: index,
                                              fromPage: 'category',
                                            ),
                                          );
                                        }
                                      });
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: subscribed
                                  ? InkColors.card
                                  : InkColors.foreground,
                              borderRadius: BorderRadius.circular(50),
                              border: subscribed
                                  ? Border.all(color: InkColors.border)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  subscribed
                                      ? Icons.check_rounded
                                      : Icons.add_rounded,
                                  size: 14,
                                  color: subscribed
                                      ? InkColors.foreground
                                      : InkColors.background,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  subscribed
                                      ? "already_subscribed".tr
                                      : "subscribe".tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoSemiBold.copyWith(
                                    fontSize: 12,
                                    color: subscribed
                                        ? InkColors.foreground
                                        : InkColors.background,
                                  ),
                                ),
                              ],
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
        );

        if (!isSubscribed) {
          return card;
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: InkColors.foreground, width: 2),
          ),
          child: card,
        );
      },
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
