import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class MySubscriptionSection extends StatelessWidget {
  const MySubscriptionSection({super.key});

  void _openPlanScreen() {
    Get.toNamed(RouteHelper.getBusinessPlanScreen());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        final subscriptionInfo =
            userProfileController.providerModel?.content?.subscriptionInfo;
        final packageDetails = subscriptionInfo?.subscribedPackageDetails;

        if (packageDetails == null ||
            (packageDetails.packageName ?? '').isEmpty) {
          return const SizedBox();
        }

        final DateTime? packageEndDate = DateTime.tryParse(
          packageDetails.packageEndDate ?? '',
        );
        final int daysLeft = packageEndDate == null
            ? 0
            : DateConverter.countDays(endDate: packageEndDate);
        final String renewDate = packageEndDate == null
            ? ''
            : DateConverter.dateStringMonthYear(
                packageEndDate,
                format: 'd MMM',
              );
        final String meta = renewDate.isEmpty
            ? '$daysLeft ${'days_left'.tr}'
            : '$daysLeft ${'days_left'.tr} · ${'renews'.tr} $renewDate';

        return InkSection(
          title: 'My subscription'.tr,
          action: 'Manage'.tr,
          onAction: _openPlanScreen,
          child: InkCard(
            onTap: _openPlanScreen,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkEyebrow('current_plan'.tr),
                      const SizedBox(height: 6),
                      Text(
                        packageDetails.packageName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: displayBold.copyWith(
                          fontSize: 18,
                          height: 1.2,
                          color: InkColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: InkColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: InkColors.foreground,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'renew'.tr,
                    style: robotoSemiBold.copyWith(
                      fontSize: 12,
                      color: InkColors.background,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
