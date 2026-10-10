import 'package:jassdbx_provider/util/core_export.dart';
import 'package:jassdbx_provider/feature/reporting/model/chart_model.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BusinessReportLineChart extends StatefulWidget {
  final String fromPage;
  const BusinessReportLineChart({super.key, required this.fromPage});

  @override
  BusinessReportLineChartState createState() => BusinessReportLineChartState();
}

class BusinessReportLineChartState extends State<BusinessReportLineChart> {
  late TooltipBehavior _tooltipBehavior;
  @override
  void initState(){
    _tooltipBehavior =  TooltipBehavior(
      enable: true,
      color: InkColors.foreground,
      textStyle:  TextStyle(fontSize: 11, color: InkColors.card),
    );
    super.initState();
  }

  Widget _legend(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, size: 10, color: color),
      const SizedBox(width: 6,),
      Text(
        label,
        style:  TextStyle(
          fontSize: 11,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: InkColors.mutedForeground,
        ),
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: InkColors.card,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: InkColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 34,
                  width: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: InkColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:  Icon(Icons.show_chart_rounded, size: 17, color: InkColors.foreground),
                ),
                const SizedBox(width: 12,),
                Text("earning_statistics".tr,
                  style:  TextStyle(
                    fontSize: 13.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: InkColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16,),
            if(widget.fromPage == 'overview')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legend(InkColors.foreground, 'earning'.tr),
                const SizedBox(width: 24,),
                _legend(InkColors.destructive, 'expense'.tr),
              ],
            ),

            if(widget.fromPage == 'earning')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legend(InkColors.inkSoft, 'net_profit'.tr),
                  const SizedBox(width: 24,),
                  _legend(InkColors.foreground, 'total_earning'.tr),
                  const SizedBox(width: 24,),
                  _legend(InkColors.destructive, 'total_expense'.tr),
                ],
              ),
            const SizedBox(height: 16,),
            SizedBox(
              height: 200,
              child: Center(
                  child: SfCartesianChart(
                      primaryXAxis:  CategoryAxis(
                        axisLine: AxisLine(color: InkColors.border),
                        majorTickLines: MajorTickLines(size: 0, width: 0),
                        majorGridLines: MajorGridLines(color: InkColors.border),
                        labelStyle: TextStyle(fontSize: 10, color: InkColors.mutedForeground),
                      ),
                      primaryYAxis:  NumericAxis(
                        axisLine: AxisLine(color: InkColors.border),
                        majorTickLines: MajorTickLines(size: 0, width: 0),
                        majorGridLines: MajorGridLines(color: InkColors.border),
                        labelStyle: TextStyle(fontSize: 10, color: InkColors.mutedForeground),
                      ),
                      onDataLabelTapped: (DataLabelTapDetails data){

                      },
                      tooltipBehavior: _tooltipBehavior,
                      enableMultiSelection: true,

                      series: <CartesianSeries>[
                        if(widget.fromPage=='overview')
                        SplineSeries<ChartDataModel, String>(
                            color: InkColors.destructive,
                            width: 3,
                            enableTooltip: true,
                            name: "expense".tr,
                            dataSource: Get.find<BusinessReportController>().overviewExpenseChart,
                            xValueMapper: (ChartDataModel data, _) => data.x,
                            yValueMapper: (ChartDataModel data, _) => data.y,

                        ),
                        if(widget.fromPage=='overview')
                        SplineSeries<ChartDataModel, String>(
                            color: InkColors.foreground,
                            width: 3,
                            enableTooltip: true,
                            name: "earning".tr,
                            dataSource:  Get.find<BusinessReportController>().overviewEarningChart,
                            xValueMapper: (ChartDataModel data, _) => data.x,
                            yValueMapper: (ChartDataModel data, _) => data.y,

                        ),

                        if(widget.fromPage=='earning')
                          SplineSeries<ChartDataModel, String>(
                              color: InkColors.foreground,
                              width: 3,
                              enableTooltip: true,
                              name: "total_earning".tr,
                              dataSource:  Get.find<BusinessReportController>().earningTotalEarningChart,
                              xValueMapper: (ChartDataModel data, _) => data.x,
                              yValueMapper: (ChartDataModel data, _) => data.y,

                          ),


                        if(widget.fromPage=='earning')
                          SplineSeries<ChartDataModel, String>(
                              color: InkColors.destructive,
                              width: 3,
                              enableTooltip: true,
                              name: "total_expense".tr,
                              dataSource:  Get.find<BusinessReportController>().earningExpenseChart,
                              xValueMapper: (ChartDataModel data, _) => data.x,
                              yValueMapper: (ChartDataModel data, _) => data.y,

                          ),

                        if(widget.fromPage=='earning')
                          SplineSeries<ChartDataModel, String>(
                              color: InkColors.inkSoft,
                              width: 3,
                              enableTooltip: true,
                              name: "net_profit".tr,
                              dataSource:  Get.find<BusinessReportController>().earningNetProfitChart,
                              xValueMapper: (ChartDataModel data, _) => data.x,
                              yValueMapper: (ChartDataModel data, _) => data.y,

                          ),




                      ]
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final double x;
  final int? y;
}

