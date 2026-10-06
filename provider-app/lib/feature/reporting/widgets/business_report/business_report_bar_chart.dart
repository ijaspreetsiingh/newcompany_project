import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:graphic/graphic.dart';



class BusinessReportBarChart extends StatelessWidget {
  const BusinessReportBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 250,
        decoration: BoxDecoration(
          color: InkColors.card,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: InkColors.border),
        ),
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
                  child:  Icon(Icons.receipt_long_outlined, size: 17, color: InkColors.foreground),
                ),
                const SizedBox(width: 12,),
                Text("expense_statistics".tr,
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
            Expanded(
              child: Chart(
                data: Get.find<BusinessReportController>().barChartData.isNotEmpty?Get.find<BusinessReportController>().barChartData:basicData,
                variables: {
                  'Timeline': Variable(
                    accessor: (Map map) => map['timeline'] as String,
                  ),
                  'Amount': Variable(
                    accessor: (Map map) => map['Amount'] as num,
                  ),
                },
                axes: [
                  AxisGuide(
                    line: PaintStyle(strokeColor: InkColors.border, strokeWidth: 1),
                    label: LabelStyle(
                      textStyle:  TextStyle(fontSize: 10, color: InkColors.mutedForeground),
                      offset: const Offset(0, 7.5),
                    ),
                  ),
                  AxisGuide(
                    grid: PaintStyle(strokeColor: InkColors.border, strokeWidth: 1),
                    label: LabelStyle(
                      textStyle:  TextStyle(fontSize: 10, color: InkColors.mutedForeground),
                      offset: const Offset(-7.5, 0),
                    ),
                  ),
                ],
                selections: {'tap': PointSelection(dim: Dim.x)},
                tooltip: TooltipGuide(
                    backgroundColor: InkColors.foreground,
                    textStyle:  TextStyle(fontSize: 11, color: InkColors.card),
                ),
                marks: [IntervalMark(color: ColorEncode(value: InkColors.destructive))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const basicData = [
  {'timeline': '0', 'Amount': 0},
  {'timeline': '2', 'Amount': 0},
  {'timeline': '4', 'Amount': 0},
];
