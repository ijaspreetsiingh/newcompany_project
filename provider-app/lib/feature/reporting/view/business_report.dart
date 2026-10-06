import 'package:demandium_provider/feature/reporting/view/report_search_filter.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BusinessReport extends StatelessWidget {
  const BusinessReport({super.key});

  Widget _tab(String label) => SizedBox(
    height: 45,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(label, maxLines: 1),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {

    return GetBuilder<BusinessReportController>(builder: (businessReportController){
      return Scaffold(
        backgroundColor: InkColors.background,
        body: SafeArea(
          child: DefaultTabController(

            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                InkTopBar(
                  title: 'business_report'.tr,
                  onBack: () => Get.back(),
                  right: InkIconButton(
                    icon: Icons.filter_alt_outlined,
                    onTap: () => Get.to(()=> ReportSearchFilter(fromPage: 'report')),
                  ),
                ),

                businessReportController.isFiltered ? const Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 4),
                  child: BusinessReportFilteredWidget(),
                ) : const SizedBox(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    tabAlignment: TabAlignment.start,
                    controller: businessReportController.businessReportTabController,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      color: InkColors.foreground,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: InkColors.background,
                    unselectedLabelColor: InkColors.mutedForeground,
                    labelStyle: robotoBold.copyWith(fontSize: 12.5),
                    unselectedLabelStyle: robotoMedium.copyWith(fontSize: 12.5),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                    dividerHeight: 0,
                    splashBorderRadius: BorderRadius.circular(50),
                    tabs:  [
                      _tab("overview".tr),
                      _tab("earning_report".tr),
                      _tab("expense_report".tr),
                    ],

                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: businessReportController.businessReportTabController,
                    children: const [
                      BusinessReportView(fromPage: 'overview',),
                      BusinessReportView(fromPage: 'earning',),
                      BusinessReportView(fromPage: 'expense',),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
