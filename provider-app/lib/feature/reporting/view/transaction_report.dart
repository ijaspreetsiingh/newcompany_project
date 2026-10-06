import 'package:demandium_provider/feature/reporting/view/report_search_filter.dart';
import 'package:demandium_provider/feature/reporting/widgets/report_panels.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionReport extends StatelessWidget {
  const TransactionReport({super.key});

  String _dateLabel(TransactionReportController controller) {
    if (controller.dateRange == "custom_date" && controller.startDate != null && controller.endDate != null) {
      final DateFormat format = DateFormat('dd MMM yyyy');
      return "${format.format(controller.startDate!)} – ${format.format(controller.endDate!)}";
    }
    return (controller.dateRange ?? "all_time").tr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        child: GetBuilder<TransactionReportController>(
          initState: (_) => Get.find<TransactionReportController>().getAllTransactionReportData(1),
          builder: (transactionReportController) {
            return Column(children: [

              InkTopBar(
                title: 'transactions_report'.tr,
                subtitle: _dateLabel(transactionReportController),
                onBack: () => Get.back(),
                right: InkIconButton(
                  icon: Icons.filter_alt_outlined,
                  onTap: () => Get.to(() => const ReportSearchFilter(fromPage: "transaction")),
                ),
              ),

              const SizedBox(height: 20),

              const Expanded(child: TransactionReportPanel()),

            ]);
          },
        ),
      ),
    );
  }
}
