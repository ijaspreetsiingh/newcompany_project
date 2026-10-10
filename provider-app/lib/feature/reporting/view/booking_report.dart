import 'package:jassdbx_provider/feature/reporting/view/report_search_filter.dart';
import 'package:jassdbx_provider/feature/reporting/widgets/report_panels.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingReport extends StatelessWidget {
  const BookingReport({super.key});

  String _dateLabel(BookingReportController controller) {
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
        child: GetBuilder<BookingReportController>(
          initState: (_) => Get.find<BookingReportController>().getBookingReportData(1),
          builder: (bookingReportController) {
            return Column(children: [

              InkTopBar(
                title: 'booking_report'.tr,
                subtitle: _dateLabel(bookingReportController),
                onBack: () => Get.back(),
                right: InkIconButton(
                  icon: Icons.filter_alt_outlined,
                  onTap: () => Get.to(() => const ReportSearchFilter(fromPage: "booking")),
                ),
              ),

              const SizedBox(height: 20),

              const Expanded(child: BookingReportPanel()),

            ]);
          },
        ),
      ),
    );
  }
}
