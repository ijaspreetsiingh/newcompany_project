import 'package:demandium_provider/feature/dashboard/widgets/recent_activity_graph.dart';
import 'package:demandium_provider/feature/dashboard/widgets/recent_activity_list_view.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        return dashboardController.dashboardRecentActivityList.isEmpty &&
                dashboardController.dashboardCustomizedPostList.isEmpty
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusExtraLarge,
                    ),
                    boxShadow: context.customThemeColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeDefault,
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 22,
                              width: 5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Color.lerp(
                                      Theme.of(context).primaryColor,
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
                              "recent_booking_activities".tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.9),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            InkWell(
                              onTap: () => dashboardController
                                  .changeRecentActivityView(),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall + 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  dashboardController.showRecentActivityList
                                      ? Images.recentActivityGraph
                                      : Images.recentActivityList,
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      dashboardController.showRecentActivityList
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TabBar(
                                  controller: dashboardController.tabController,
                                  unselectedLabelColor: Colors.grey,
                                  isScrollable: true,
                                  dividerColor: Colors.transparent,
                                  indicatorColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  labelColor: Theme.of(context).primaryColor,
                                  labelStyle: robotoMedium,
                                  indicatorWeight: 2,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  tabAlignment: TabAlignment.start,

                                  tabs: [
                                    SizedBox(
                                      height: 35,
                                      child: Center(
                                        child: Text(
                                          "normal_booking".tr,
                                          style: robotoMedium,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 35,
                                      child: Center(
                                        child: Text(
                                          "customised_booking".tr,
                                          style: robotoMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onTap: (index) {
                                    if (dashboardController
                                            .tabController
                                            ?.index ==
                                        0) {
                                      dashboardController
                                          .changeTypeOfShowBookingStatus(
                                            status: true,
                                          );
                                    } else {
                                      dashboardController
                                          .changeTypeOfShowBookingStatus(
                                            status: false,
                                          );
                                    }
                                  },
                                ),
                                SizedBox(height: Dimensions.paddingSizeSmall),

                                const RecentActivityListView(),
                              ],
                            )
                          : const RecentActivityGraph(),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
