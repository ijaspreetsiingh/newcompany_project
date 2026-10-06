import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/reporting/model/business_report_overview_model.dart';
import 'package:get/get.dart';

 TextStyle _ovLabelStyle = TextStyle(
  fontSize: 12.5,
  height: 1.3,
  fontWeight: FontWeight.w500,
  color: InkColors.mutedForeground,
);

 TextStyle _ovValueStyle = TextStyle(
  fontSize: 13,
  height: 1.3,
  fontWeight: FontWeight.w600,
  color: InkColors.foreground,
);

 TextStyle _ovMoneyStyle = TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontSize: 13,
  height: 1.3,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.2,
  color: InkColors.foreground,
);

Widget _ovRow(String label, String value, {TextStyle? style}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 5),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: _ovLabelStyle)),
      const SizedBox(width: 12),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: style ?? _ovValueStyle),
    ],
  ),
);

Widget _ovDivider() => Container(height: 1, color: InkColors.border);

class BusinessReportOverviewListView extends StatelessWidget {
  final  List<Amounts>  filterData;
  const BusinessReportOverviewListView({super.key, required this.filterData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        filterData.isNotEmpty?
        ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context,index){

            double totalEarning=0;
            double totalExpense=0;
            double netProfit=0;
            double netProfitRate=0;
            double tax =0;

            totalEarning = filterData[index].providerEarning??0;
            tax = filterData[index].serviceTax??0;

            totalExpense = filterData[index].campaignDiscountByProvider!
                + filterData[index].couponDiscountByProvider! + filterData[index].discountByProvider!;

            netProfit = totalEarning;
            netProfitRate =totalEarning!=0? (netProfit*100)/totalEarning  : netProfit*100;

            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: index == filterData.length - 1 ? 0 : 12),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: InkColors.card,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: InkColors.border),
              ),
              child: Column(children: [

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration:  BoxDecoration(
                    color: InkColors.secondary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(19),
                      topRight: Radius.circular(19),
                    ),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Text('net_profit_rate'.tr,
                        style:  TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: InkColors.foreground,
                        ),
                      ),
                      Text("${netProfitRate.toStringAsFixed(2)} % ",
                        style:  TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: InkColors.foreground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [

                    _ovRow('total_earning'.tr, PriceConverter.convertPrice(totalEarning), style: _ovMoneyStyle),
                    _ovRow('total_expenses'.tr, PriceConverter.convertPrice(totalExpense), style: _ovMoneyStyle),
                    _ovRow('tax'.tr, PriceConverter.convertPrice(tax), style: _ovMoneyStyle),

                    const SizedBox(height: 6),
                    _ovDivider(),
                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${'net_profit'.tr} : ",
                          style:  TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            color: InkColors.foreground,
                          ),
                        ),
                        Text(PriceConverter.convertPrice(netProfit),
                          style: _ovMoneyStyle.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),

                  ]),
                ),
              ]),
            );
          },
          itemCount: filterData.length,
        ):
        SizedBox(height: Get.height*0.33,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkEmptyState('no_data_found'.tr),
            ),
          ),),

        if(Get.find<BusinessReportController>().isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
      ],
    );
  }
}
