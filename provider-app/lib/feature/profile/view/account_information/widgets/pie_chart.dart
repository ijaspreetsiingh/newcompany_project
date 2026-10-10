import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class TransactionPieChart extends StatefulWidget {
  const TransactionPieChart({super.key});

  @override
  State<TransactionPieChart> createState() => _TransactionPieChartState();
}

class _TransactionPieChartState extends State<TransactionPieChart> {

  static List<Color> get _sliceColors => <Color>[
    InkColors.chart1,
    InkColors.chart2,
    InkColors.chart3,
    InkColors.chart4,
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        final int totalAccepted = userProfileController.totalAcceptedRequest;
        final int totalOngoing = userProfileController.totalOngoingRequest;
        final int totalCompleted = userProfileController.totalCompletedRequest;
        final int totalCanceled = userProfileController.totalCanceledRequest;
        final int totalBookingRequest = totalAccepted + totalOngoing + totalCompleted + totalCanceled;

        int percentOfCancelRequest = 0;
        int percentOfCompletedRequest = 0;
        int percentOfOngoingRequest = 0;
        int percentOfAcceptedRequest = 0;

        if (totalBookingRequest > 0) {
          if (totalCanceled != 0) {
            percentOfCancelRequest = ((totalCanceled * 100.00) / totalBookingRequest).ceil();
          }
          if (totalCompleted != 0) {
            percentOfCompletedRequest = ((totalCompleted * 100.00) / totalBookingRequest).ceil();
          }
          if (totalOngoing != 0) {
            percentOfOngoingRequest = ((totalOngoing * 100.00) / totalBookingRequest).floor();
          }
          if (totalAccepted != 0) {
            percentOfAcceptedRequest = ((totalAccepted * 100.00) / totalBookingRequest).floor();
          }
        }

        final List<_LegendItem> legendItems = <_LegendItem>[
          _LegendItem(label: 'accepted'.tr, percent: percentOfAcceptedRequest, color: _sliceColors[0]),
          _LegendItem(label: 'ongoing'.tr, percent: percentOfOngoingRequest, color: _sliceColors[1]),
          _LegendItem(label: 'completed'.tr, percent: percentOfCompletedRequest, color: _sliceColors[2]),
          _LegendItem(label: 'canceled'.tr, percent: percentOfCancelRequest, color: _sliceColors[3]),
        ];

        return InkCard(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(
              height: 112,
              width: 112,
              child: PieChart(
                PieChartData(
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 30,
                  sections: totalBookingRequest > 0
                      ? <PieChartSectionData>[
                          if (totalAccepted > 0) _section(totalAccepted, _sliceColors[0]),
                          if (totalOngoing > 0) _section(totalOngoing, _sliceColors[1]),
                          if (totalCompleted > 0) _section(totalCompleted, _sliceColors[2]),
                          if (totalCanceled > 0) _section(totalCanceled, _sliceColors[3]),
                        ]
                      : <PieChartSectionData>[
                          PieChartSectionData(
                            color: InkColors.accent,
                            value: 1,
                            title: '',
                            radius: 44,
                            showTitle: false,
                          ),
                        ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                for (int i = 0; i < legendItems.length; i++) ...[
                  if (i != 0) const SizedBox(height: 8),
                  Row(children: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(color: legendItems[i].color, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        legendItems[i].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:  TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: InkColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${legendItems[i].percent}%',
                      style:  TextStyle(fontSize: 12, height: 1.3, color: InkColors.mutedForeground),
                    ),
                  ]),
                ],
              ]),
            ),
          ]),
        );
      },
    );
  }

  PieChartSectionData _section(int value, Color color) {
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: '',
      radius: 44,
      showTitle: false,
      borderSide:  BorderSide(color: InkColors.card, width: 1.5),
    );
  }
}

class _LegendItem {
  final String label;
  final int percent;
  final Color color;

  const _LegendItem({required this.label, required this.percent, required this.color});
}
