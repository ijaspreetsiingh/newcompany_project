import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class SubscriptionTrailEndWidget extends StatefulWidget {
  final VoidCallback? onDismiss;

  const SubscriptionTrailEndWidget({super.key, this.onDismiss});

  @override
  State<SubscriptionTrailEndWidget> createState() =>
      _SubscriptionTrailEndWidgetState();
}

class _SubscriptionTrailEndWidgetState
    extends State<SubscriptionTrailEndWidget> {
  bool _dismissed = false;

  void _dismiss() {
    setState(() {
      _dismissed = true;
    });
    widget.onDismiss?.call();
  }

  void _openPlanScreen() {
    Get.toNamed(RouteHelper.getBusinessPlanScreen());
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        final subscribedPackageDetails = userProfileController
            .providerModel
            ?.content
            ?.subscriptionInfo
            ?.subscribedPackageDetails;

        final String? packageEndDate = subscribedPackageDetails?.packageEndDate;
        final DateTime? endDate = DateTime.tryParse(packageEndDate ?? '');
        if (subscribedPackageDetails == null || endDate == null) {
          return const SizedBox.shrink();
        }

        final int trialRemainDuration = DateConverter.countDays(
          endDate: endDate,
        ) - 1;

        final String message = trialRemainDuration > 0
            ? 'Trial ends in $trialRemainDuration days — upgrade to keep bidding active.'
            : '${'free_trial'.tr} — ${'will_be_end_today'.tr}. Upgrade to keep bidding active.';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: InkColors.destructive,
            borderRadius: BorderRadius.circular(12),
            boxShadow: InkColors.floatShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  message,
                  style: robotoSemiBold.copyWith(
                    fontSize: 12,
                    height: 1.35,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _openPlanScreen,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'upgrade'.tr,
                    style: robotoBold.copyWith(
                      fontSize: 11,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _dismiss,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
