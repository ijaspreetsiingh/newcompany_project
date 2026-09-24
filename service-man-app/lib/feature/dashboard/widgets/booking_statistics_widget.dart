
import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class BookingStatisticsWidget extends StatelessWidget {
  const BookingStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        final earningData = dashboardController.bookingStatisticsModel;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'booking_statistics'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            earningData == null
                ? _buildSkeleton(context)
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _BookingStatCard(
                          period: 'this_week'.tr,
                          total: earningData.thisWeek?.total ?? 0,
                          change: earningData.thisWeek?.change ?? 0.0,
                          periodLabel: 'from_last_week'.tr,
                        ),
                        const SizedBox(width: 12),
                        _BookingStatCard(
                          period: 'this_month'.tr,
                          total: earningData.thisMonth?.total ?? 0,
                          change: earningData.thisMonth?.change ?? 0.0,
                          periodLabel: 'from_last_month'.tr,
                        ),
                        const SizedBox(width: 12),
                        _BookingStatCard(
                          period: 'this_year'.tr,
                          total: earningData.thisYear?.total ?? 0,
                          change: earningData.thisYear?.change ?? 0.0,
                          periodLabel: 'from_last_year'.tr,
                        ),
                      ],
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Row(
      children: List.generate(3, (index) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 12, width: 60, color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),
              Container(height: 24, width: 40, color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),
              Container(height: 10, width: 80, color: Theme.of(context).dividerColor),
            ],
          ),
        ),
      )),
    );
  }
}

class _BookingStatCard extends StatelessWidget {
  final String period;
  final int total;
  final double change;
  final String periodLabel;

  const _BookingStatCard({
    required this.period,
    required this.total,
    required this.change,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final changeColor = isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
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
          Text(
            period,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            '$total',
            style: robotoBold.copyWith(
              fontSize: 28,
              color: Theme.of(context).primaryColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                isPositive ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: changeColor,
              ),
              const SizedBox(width: 2),
              Text(
                '${isPositive ? '+' : ''}$change%',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: changeColor,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  periodLabel,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

