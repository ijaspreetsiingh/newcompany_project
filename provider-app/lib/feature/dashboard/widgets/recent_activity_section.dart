import 'package:demandium_provider/feature/dashboard/widgets/recent_activity_graph.dart';
import 'package:demandium_provider/feature/dashboard/widgets/recent_activity_list_view.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        final bool hasBookings =
            dashboardController.dashboardRecentActivityList.isNotEmpty;
        final bool hasCustomPosts =
            dashboardController.dashboardCustomizedPostList.isNotEmpty;

        if (!hasBookings && !hasCustomPosts) return const SizedBox();

        final bool showTabs = hasBookings && hasCustomPosts;

        return InkSection(
          title: 'Recent activity'.tr,
          action: 'View all'.tr,
          onAction: () =>
              Get.offAllNamed(RouteHelper.getInitialRoute(pageIndex: 1)),
          child: InkCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RecentActivityGraph(),
                  if (showTabs)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: InkPills(
                        items: <String>[
                          'normal_booking'.tr,
                          'customised_booking'.tr,
                        ],
                        value: dashboardController.showNormalBooking
                            ? 'normal_booking'.tr
                            : 'customised_booking'.tr,
                        onChanged: (String value) => dashboardController
                            .changeTypeOfShowBookingStatus(
                              status: value == 'normal_booking'.tr,
                            ),
                      ),
                    ),
                  const RecentActivityListView(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
