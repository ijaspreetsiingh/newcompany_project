import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class BusinessSummerySection extends StatelessWidget {
  const BusinessSummerySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "booking_summary".tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "this_week".tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'here_is_your_booking_overview_for_this_week'.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_today_rounded,
                    count: controller.cards.pendingBookings ?? 0,
                    label: "assigned_booking".tr,
                    iconColor: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFDBEAFE),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.access_time_rounded,
                    count: controller.cards.ongoingBookings ?? 0,
                    label: "ongoing_booking".tr,
                    iconColor: const Color(0xFF0EA5E9),
                    bgColor: const Color(0xFFE0F2FE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_rounded,
                    count: controller.cards.completedBookings ?? 0,
                    label: "completed_booking".tr,
                    iconColor: const Color(0xFF22C55E),
                    bgColor: const Color(0xFFECFDF5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.cancel_rounded,
                    count: controller.cards.canceledBookings ?? 0,
                    label: "canceled_booking".tr,
                    iconColor: const Color(0xFFEF4444),
                    bgColor: const Color(0xFFFEF2F2),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color iconColor;
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Theme.of(context).hintColor.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            '$count',
            style: robotoBold.copyWith(
              fontSize: 28,
              color: Theme.of(context).textTheme.bodyLarge!.color,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
