import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class RecentActivityGraph extends StatelessWidget {
  const RecentActivityGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        final int normalCount =
            dashboardController.additionalInfoCount?.pendingBookingCount ?? 0;
        final int customisedCount =
            dashboardController.additionalInfoCount?.customizedPostCount ?? 0;
        final int totalCount = normalCount + customisedCount;

        if (totalCount <= 0) return const SizedBox.shrink();

        final int normalPercent = ((normalCount * 100) / totalCount).round();
        final int customisedPercent = 100 - normalPercent;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration:  BoxDecoration(
            border: Border(
              bottom: BorderSide(color: InkColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 96,
                width: 96,
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 28,
                    sections: <PieChartSectionData>[
                      PieChartSectionData(
                        color: InkColors.chart1,
                        value: normalPercent.toDouble(),
                        title: '',
                        radius: 44,
                      ),
                      PieChartSectionData(
                        color: InkColors.chart4,
                        value: customisedPercent.toDouble(),
                        title: '',
                        radius: 44,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LegendRow(
                      color: InkColors.chart1,
                      label: 'normal_booking'.tr,
                      percent: normalPercent,
                    ),
                    const SizedBox(height: 8),
                    _LegendRow(
                      color: InkColors.chart4,
                      label: 'customised_booking'.tr,
                      percent: customisedPercent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int percent;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoSemiBold.copyWith(
              fontSize: 12,
              color: InkColors.foreground,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percent%',
          style: robotoRegular.copyWith(
            fontSize: 12,
            color: InkColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
