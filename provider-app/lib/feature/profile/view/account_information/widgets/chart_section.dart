import 'package:jassdbx_provider/feature/reporting/model/chart_model.dart';
import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class TransactionChart extends StatefulWidget {
  const TransactionChart({super.key});

  @override
  State<TransactionChart> createState() => _TransactionChartState();
}

class _TransactionChartState extends State<TransactionChart> {
  bool _loading = true;
  List<ChartDataModel> _series = <ChartDataModel>[];

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries() async {
    final BusinessReportController reportController = Get.find<BusinessReportController>();

    try {
      reportController.setSelectedDropdownValue('this_week', type: 'date_range');
      await reportController.getBusinessReportOverviewData(1);
      final List<ChartDataModel> series = List<ChartDataModel>.of(reportController.overviewEarningChart);
      reportController.resetValue();

      if (!mounted) return;
      setState(() {
        _series = series;
        _loading = false;
      });
    } catch (_) {
      reportController.resetValue();
      if (!mounted) return;
      setState(() {
        _series = <ChartDataModel>[];
        _loading = false;
      });
    }
  }

  Widget _stateBox({required Widget child}) {
    return InkCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(height: 144, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _stateBox(
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: InkColors.foreground),
          ),
        ),
      );
    }

    final bool hasValues = _series.any((ChartDataModel element) => (element.y ?? 0) > 0);

    if (_series.isEmpty || !hasValues) {
      return _stateBox(
        child: Center(
          child: Text(
            'no_data_found'.tr,
            textAlign: TextAlign.center,
            style:  TextStyle(fontSize: 13, height: 1.5, color: InkColors.mutedForeground),
          ),
        ),
      );
    }

    final int count = _series.length;
    double interval = 1;
    if (count > 1) {
      interval = ((count - 1) / 4).ceilToDouble();
      if (interval < 1) interval = 1;
    }

    return InkCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 144,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  interval: interval,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final int index = value.round();
                    if (index < 0 || index >= count) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _series[index].x,
                        style:  TextStyle(fontSize: 10, height: 1.2, color: InkColors.mutedForeground),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List<BarChartGroupData>.generate(count, (int index) {
              return BarChartGroupData(
                x: index,
                barRods: <BarChartRodData>[
                  BarChartRodData(
                    toY: _series[index].y ?? 0,
                    color: InkColors.chart1,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
