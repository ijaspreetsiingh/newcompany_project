import 'package:demandium_provider/feature/dashboard/widgets/advertisement_section.dart';
import 'package:demandium_provider/feature/dashboard/widgets/earning_statistics_widget.dart';
import 'package:demandium_provider/feature/nav/widgets/subscription_trail_end_widget.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});
  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final toolTip = JustTheController();

  @override
  void initState() {
    super.initState();
    Get.find<DashboardController>().getEarningData();
    Get.find<BusinessSettingController>().getBookingSettingsDataFromServer();
    Get.find<BusinessSettingController>()
        .getServiceAvailabilitySettingsFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        bool canShow =
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

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: CustomAppBar(
            title: AppConstants.appName,
            bgColor: Theme.of(context).colorScheme.surface,
            isBackButtonExist: false,
            actionWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GetBuilder<NotificationController>(
                  builder: (notificationController) {
                    return InkWell(
                      onTap: () => Get.toNamed(
                        RouteHelper.getNotificationRoute(
                          fromPage: "notification",
                        ),
                      ),
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Get.isDarkMode
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                        alignment: Alignment.center,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color,
                            ),
                            if (notificationController.unseenNotificationCount >
                                0)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2563EB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${notificationController.unseenNotificationCount}',
                                    style: robotoBold.copyWith(
                                      fontSize: 8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
              ],
            ),
          ),
          body: RefreshIndicator(
            backgroundColor: Theme.of(context).primaryColor,
            onRefresh: () async {
              await Get.find<DashboardController>().getDashboardData();
              Get.find<DashboardController>().changeRecentActivityView(
                status: true,
                shouldUpdate: true,
              );
              Get.find<DashboardController>().changeTypeOfShowBookingStatus(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  /// Hero header card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault + 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Color.lerp(
                              Theme.of(context).primaryColor,
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
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.30),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -24,
                            top: -34,
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 70,
                            bottom: -48,
                            child: Container(
                              height: 90,
                              width: 90,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'dashboard'.tr,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeOverLarge,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.18,
                                        ),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Text(
                                        AppConstants.appName,
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusLarge,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.insights_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  TopCardSection(toolTip: toolTip),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  const EarningStatisticsWidget(),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  const RecentActivitySection(),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  const AdvertisementSection(),
                  const MySubscriptionSection(),
                  const ServiceManSection(),

                  SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton:
              canShow && !userProfileController.trialWidgetNotShow
              ? const SubscriptionTrailEndWidget()
              : const SizedBox(),
        );
      },
    );
  }
}
