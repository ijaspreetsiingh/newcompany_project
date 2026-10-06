import 'package:demandium_provider/feature/reporting/view/report_search_filter.dart';
import 'package:demandium_provider/feature/reporting/widgets/report_panels.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Reports hub — single screen with Booking / Business / Transaction pills
/// (design: design/src/routes/_tabs.reports.tsx).
class ReportNavigationView extends StatefulWidget {
  const ReportNavigationView({super.key});

  @override
  State<ReportNavigationView> createState() => _ReportNavigationViewState();
}

class _ReportNavigationViewState extends State<ReportNavigationView> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();

    final BookingReportController bookingReportController = Get.find<BookingReportController>();
    bookingReportController.resetValue();
    bookingReportController.getBookingReportData(1);

    final TransactionReportController transactionReportController = Get.find<TransactionReportController>();
    transactionReportController.resetFilterValue(updateTabControllerValue: false);
    transactionReportController.getAllTransactionReportData(1);
  }

  String _dateLabel(String? dateRange, DateTime? startDate, DateTime? endDate) {
    if (dateRange == "custom_date" && startDate != null && endDate != null) {
      final DateFormat format = DateFormat('dd MMM yyyy');
      return "${format.format(startDate)} – ${format.format(endDate)}";
    }
    return (dateRange ?? "all_time").tr;
  }

  @override
  Widget build(BuildContext context) {

    final List<String> tabs = ['booking'.tr, 'business'.tr, 'transaction'.tr];

    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        child: GetBuilder<BookingReportController>(builder: (bookingReportController) {
          return GetBuilder<TransactionReportController>(builder: (transactionReportController) {

            final String subtitle = _tabIndex == 2 ?
            _dateLabel(transactionReportController.dateRange, transactionReportController.startDate, transactionReportController.endDate) :
            _dateLabel(bookingReportController.dateRange, bookingReportController.startDate, bookingReportController.endDate);

            return Column(children: [

              InkTopBar(
                title: 'reports'.tr,
                subtitle: subtitle,
                onBack: (){
                  if(Navigator.canPop(context)){
                    Get.back();
                  }else{
                    Get.offNamed(RouteHelper.initial);
                  }
                },
                right: InkIconButton(
                  icon: Icons.filter_alt_outlined,
                  onTap: () => Get.to(() => ReportSearchFilter(fromPage: _tabIndex == 2 ? "transaction" : "booking")),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkPills(
                  items: tabs,
                  value: tabs[_tabIndex],
                  onChanged: (value) => setState(() => _tabIndex = tabs.indexOf(value)),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: IndexedStack(
                  index: _tabIndex,
                  children: const [
                    BookingReportPanel(),
                    BusinessReportPanel(),
                    TransactionReportPanel(),
                  ],
                ),
              ),

            ]);
          });
        }),
      ),
    );
  }
}
