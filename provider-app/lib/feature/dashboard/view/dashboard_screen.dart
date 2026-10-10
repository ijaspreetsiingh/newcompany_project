import 'package:jassdbx_provider/feature/dashboard/widgets/dashboard_header_new.dart';
import 'package:jassdbx_provider/feature/dashboard/widgets/earning_statistics_widget.dart';
import 'package:jassdbx_provider/feature/nav/widgets/subscription_trail_end_widget.dart';
import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});
  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  bool _ribbonDismissed = false;

  @override
  void initState() {
    super.initState();
    Get.find<DashboardController>().getEarningData();
    Get.find<MyServicesController>().ensureLoaded();
    Get.find<BusinessSettingController>().getBookingSettingsDataFromServer();
    Get.find<BusinessSettingController>()
        .getServiceAvailabilitySettingsFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        final bool subscriptionRequired =
            userProfileController.isSubscriptionRequired;

        final bool canShow =
            subscriptionRequired &&
            userProfileController.providerModel != null &&
            userProfileController.providerModel!.content != null &&
            userProfileController.providerModel!.content!.subscriptionInfo !=
                null &&
            userProfileController
                    .providerModel!
                    .content!
                    .subscriptionInfo!
                    .subscribedPackageDetails !=
                null &&
            userProfileController
                    .providerModel!
                    .content!
                    .subscriptionInfo!
                    .subscribedPackageDetails!
                    .trialDuration !=
                0 &&
            DateConverter.countDays(
                  endDate: DateTime.parse(
                    userProfileController
                        .providerModel!
                        .content!
                        .subscriptionInfo!
                        .subscribedPackageDetails!
                        .packageEndDate!,
                  ),
                ) >
                0;

        final bool showRibbon =
            canShow &&
            !userProfileController.trialWidgetNotShow &&
            !_ribbonDismissed;

        return Scaffold(
          backgroundColor: InkColors.background,
          appBar: const DashboardHeaderNew(),
          body: Stack(
            children: [
              RefreshIndicator(
                backgroundColor: Theme.of(context).primaryColor,
                onRefresh: () async {
                  await Get.find<DashboardController>().getDashboardData();
                  Get.find<DashboardController>().changeRecentActivityView(
                    status: true,
                    shouldUpdate: true,
                  );
                  Get.find<DashboardController>()
                      .changeTypeOfShowBookingStatus(
                        status: true,
                        shouldUpdate: true,
                      );
                  await Get.find<DashboardController>().getEarningData();
                  await Get.find<UserProfileController>().getProviderInfo(
                    reload: true,
                  );
                  Get.find<NotificationController>().getNotifications(
                    1,
                    saveNotificationCount: false,
                  );
                  Get.find<SplashController>().getConfigData();
                },
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: GetBuilder<DashboardController>(
                    builder: (dashboardController) {
                      final bool showActivity =
                          dashboardController
                              .dashboardRecentActivityList
                              .isNotEmpty ||
                          dashboardController
                              .dashboardCustomizedPostList
                              .isNotEmpty;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 28),

                          /// Hero — ink-surface overview card
                          const BusinessSummarySection(),
                          const SizedBox(height: 28),

                          /// 2x2 grid of API top cards
                          const DashboardStatGrid(),
                          const SizedBox(height: 28),

                          const EarningStatisticsWidget(),
                          const SizedBox(height: 28),

                          if (showActivity) ...[
                            const RecentActivitySection(),
                            const SizedBox(height: 28),
                          ],

                          const AssignedCategoriesSection(),
                          const SizedBox(height: 28),

                          const ServiceManSection(),
                          SizedBox(height: showRibbon ? 96 : 32),
                        ],
                      );
                    },
                  ),
                ),
              ),
              if (showRibbon)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SubscriptionTrailEndWidget(
                    onDismiss: () => setState(() => _ribbonDismissed = true),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
