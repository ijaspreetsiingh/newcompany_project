import 'dart:math' as math;

import 'package:jassdbx_provider/feature/reporting/model/chart_model.dart';
import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class EarningStatisticsWidget extends StatefulWidget {
  const EarningStatisticsWidget({super.key});

  @override
  State<EarningStatisticsWidget> createState() =>
      _EarningStatisticsWidgetState();
}

class _EarningStatisticsWidgetState extends State<EarningStatisticsWidget> {
  /// [current range, previous range] pairs sent to the business report api.
  static const List<List<String>> _rangeKeys = <List<String>>[
    <String>['this_week', 'last_week'],
    <String>['this_month', 'last_month'],
    <String>['this_year', 'last_year'],
  ];

  int _rangeIndex = 0;
  bool _loading = true;
  bool _loadedOnce = false;
  Object? _lastEarningInstance;
  List<ChartDataModel> _currentSeries = <ChartDataModel>[];
  List<ChartDataModel> _previousSeries = <ChartDataModel>[];

  @override
  void initState() {
    super.initState();
    _loadSeries(0);
  }

  Future<void> _loadSeries(int index) async {
    setState(() {
      _rangeIndex = index;
      _loading = true;
    });

    final List<String> keys = _rangeKeys[index];
    final BusinessReportController reportController =
        Get.find<BusinessReportController>();

    try {
      reportController.setSelectedDropdownValue(keys[0], type: 'date_range');
      await reportController.getBusinessReportOverviewData(1);
      final List<ChartDataModel> current =
          List<ChartDataModel>.of(reportController.overviewEarningChart);

      reportController.setSelectedDropdownValue(keys[1], type: 'date_range');
      await reportController.getBusinessReportOverviewData(1);
      final List<ChartDataModel> previous =
          List<ChartDataModel>.of(reportController.overviewEarningChart);

      reportController.resetValue();

      if (!mounted) return;
      setState(() {
        _currentSeries = current;
        _previousSeries = previous;
        _loading = false;
        _loadedOnce = true;
      });
    } catch (_) {
      reportController.resetValue();
      if (!mounted) return;
      setState(() {
        _currentSeries = <ChartDataModel>[];
        _previousSeries = <ChartDataModel>[];
        _loading = false;
        _loadedOnce = true;
      });
    }
  }

  void _openReports() {
    Get.find<BusinessReportController>().businessReportTabController?.index = 1;
    Get.to(() => const BusinessReport());
  }

  Widget _buildPills() {
    final List<String> items = <String>[
      'this_week'.tr,
      'this_month'.tr,
      'this_year'.tr,
    ];
    return InkPills(
      items: items,
      value: items[_rangeIndex],
      onChanged: (String value) {
        final int index = items.indexOf(value);
        if (index != -1 && index != _rangeIndex && !_loading) _loadSeries(index);
      },
    );
  }

  Widget _buildChart() {
    if (_loading) {
      return Center(
        child: SizedBox(
          height: 26,
          width: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: InkColors.foreground,
          ),
        ),
      );
    }

    final int currentLength = _currentSeries.length;
    final int previousLength = _previousSeries.length;
    final bool hasCurrent = currentLength >= 2;
    final bool hasPrevious = previousLength >= 2;

    if (!hasCurrent && !hasPrevious) {
      return Center(
        child: Text(
          'no_data_found'.tr,
          style: robotoRegular.copyWith(
            fontSize: 13,
            color: InkColors.mutedForeground,
          ),
        ),
      );
    }

    final int count = hasCurrent && hasPrevious
        ? math.min(currentLength, previousLength)
        : hasCurrent
        ? currentLength
        : previousLength;

    final List<FlSpot> currentSpots = <FlSpot>[];
    final List<FlSpot> previousSpots = <FlSpot>[];
    for (int i = 0; i < count; i++) {
      if (i < currentLength) {
        currentSpots.add(FlSpot(i.toDouble(), _currentSeries[i].y ?? 0));
      }
      if (i < previousLength) {
        previousSpots.add(FlSpot(i.toDouble(), _previousSeries[i].y ?? 0));
      }
    }

    final List<String> labels = <String>[];
    for (int i = 0; i < count; i++) {
      labels.add(hasCurrent ? _currentSeries[i].x : _previousSeries[i].x);
    }

    double interval = 1;
    if (count > 1) {
      interval = ((count - 1) / 4).ceilToDouble();
      if (interval < 1) interval = 1;
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBorderRadius: BorderRadius.circular(12),
            tooltipBorder:  BorderSide(color: InkColors.border),
            getTooltipColor: (LineBarSpot touchedSpot) => InkColors.foreground,
            getTooltipItems: (List<LineBarSpot> touchedSpots) =>
                touchedSpots.map((LineBarSpot spot) {
                  return LineTooltipItem(
                    '₹${spot.y.toStringAsFixed(0)}',
                    robotoMedium.copyWith(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: interval,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int index = value.round();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[index],
                    style: robotoRegular.copyWith(
                      fontSize: 10,
                      color: InkColors.mutedForeground,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: <LineChartBarData>[
          if (hasPrevious && previousSpots.length >= 2)
            LineChartBarData(
              spots: previousSpots,
              isCurved: true,
              barWidth: 1.5,
              color: InkColors.chart4,
              dashArray: const <int>[4, 4],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          if (hasCurrent && currentSpots.length >= 2)
            LineChartBarData(
              spots: currentSpots,
              isCurved: true,
              barWidth: 2.4,
              color: InkColors.chart1,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    InkColors.chart1.withValues(alpha: 0.35),
                    InkColors.chart1.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        Container(
          height: 2,
          width: 16,
          decoration:  BoxDecoration(color: InkColors.foreground),
        ),
        const SizedBox(width: 6),
        Text(
          'Current',
          style: robotoMedium.copyWith(
            fontSize: 11,
            color: InkColors.mutedForeground,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 2,
          width: 16,
          decoration:  BoxDecoration(color: InkColors.chart4),
        ),
        const SizedBox(width: 6),
        Text(
          'Previous',
          style: robotoMedium.copyWith(
            fontSize: 11,
            color: InkColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkSection(
      title: 'Earnings statistics'.tr,
      action: 'Reports'.tr,
      onAction: _openReports,
      child: GetBuilder<DashboardController>(
        builder: (dashboardController) {
          final Object? earningInstance = dashboardController.earningDataModel;
          if (_loadedOnce && !identical(earningInstance, _lastEarningInstance)) {
            _lastEarningInstance = earningInstance;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_loading) _loadSeries(_rangeIndex);
            });
          } else if (_lastEarningInstance == null) {
            _lastEarningInstance = earningInstance;
          }

          return InkCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPills(),
                const SizedBox(height: 16),
                SizedBox(height: 160, child: _buildChart()),
                const SizedBox(height: 8),
                _buildLegend(),
              ],
            ),
          );
        },
      ),
    );
  }
}
