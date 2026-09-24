import 'package:demandium_provider/feature/serviceman/view/serviceman_details.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ServiceManSection extends StatelessWidget {
  const ServiceManSection({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        return Column(
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
                        "service_man_list".tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.color!.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap: () {
                      Get.toNamed(RouteHelper.serviceManSetup);
                    },
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
                        dashboardController.dashboardServicemanList.isEmpty
                            ? "add_new_service_man".tr
                            : "view_all".tr,
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

            dashboardController.dashboardServicemanList.isEmpty
                ? const SizedBox(height: Dimensions.paddingSizeDefault)
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusExtraLarge,
                        ),
                        boxShadow: context.customThemeColors.cardShadow,
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveHelper.isDesktop(context)
                              ? 6
                              : ResponsiveHelper.isTab(context)
                              ? 4
                              : 2,
                          childAspectRatio: 0.95,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                        ),

                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall,
                                ),
                                margin: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusLarge,
                                  ),
                                  color: primary.withValues(alpha: 0.05),
                                  border: Border.all(
                                    color: primary.withValues(alpha: 0.10),
                                  ),
                                ),

                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Row(),

                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primary.withValues(alpha: 0.12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CustomImage(
                                          fit: BoxFit.cover,
                                          height: 54,
                                          width: 54,
                                          image:
                                              '${dashboardController.dashboardServicemanList[index].user!.profileImageFullPath}',
                                          placeholder: Images.userPlaceHolder,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeSmall,
                                    ),
                                    Text(
                                      '${dashboardController.dashboardServicemanList[index].user!.firstName!} ${dashboardController.dashboardServicemanList[index].user!.lastName!}',
                                      style: robotoSemiBold.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.9),
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    Text(
                                      dashboardController
                                          .dashboardServicemanList[index]
                                          .user!
                                          .phone!,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: CustomInkWell(
                                    onTap: () {
                                      Get.to(
                                        () => ServicemanDetails(
                                          id: dashboardController
                                              .dashboardServicemanList[index]
                                              .id!,
                                          fromDashboard: true,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        itemCount:
                            dashboardController.dashboardServicemanList.length,
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
