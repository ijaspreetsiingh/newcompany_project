import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class MySubscriptionSection extends StatelessWidget {
  const MySubscriptionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        return dashboardController.dashboardSubscriptionList.isEmpty
            ? const SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeSmall,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 22,
                              width: 5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primary,
                                    Color.lerp(
                                      primary,
                                      const Color(0xFF1E40AF),
                                      0.5,
                                    )!,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Text(
                              "mySubscription".tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),

                        GestureDetector(
                          onTap: () =>
                              Get.toNamed(RouteHelper.getMySubscriptionRoute()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              "view_all".tr,
                              style: robotoSemiBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusExtraLarge,
                        ),
                        boxShadow: context.customThemeColors.cardShadow,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            if (dashboardController
                                    .dashboardSubscriptionList[index]
                                    .subCategory !=
                                null) {
                              return SubscriptionCardItem(
                                subscriptionModelData: dashboardController
                                    .dashboardSubscriptionList[index],
                                index: index,
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                          physics: const ClampingScrollPhysics(),
                          itemCount: dashboardController
                              .dashboardSubscriptionList
                              .length,
                        ),
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}
