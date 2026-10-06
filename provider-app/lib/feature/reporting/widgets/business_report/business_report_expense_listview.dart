import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/reporting/model/business_report_expense_model.dart';
import 'package:get/get.dart';

 TextStyle _expLabelStyle = TextStyle(
  fontSize: 12.5,
  height: 1.3,
  fontWeight: FontWeight.w500,
  color: InkColors.mutedForeground,
);

 TextStyle _expLabelStrongStyle = TextStyle(
  fontSize: 13,
  height: 1.3,
  fontWeight: FontWeight.w700,
  color: InkColors.foreground,
);

 TextStyle _expValueStyle = TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontSize: 13,
  height: 1.3,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.2,
  color: InkColors.foreground,
);

Widget _expRow(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 5),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: _expLabelStyle)),
      const SizedBox(width: 12),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: _expValueStyle),
    ],
  ),
);

Widget _expDivider() => Container(height: 1, color: InkColors.border);

class BusinessReportExpenseListView extends StatelessWidget {
  final  List<BusinessReportFilterData>  filterData;
  const BusinessReportExpenseListView({super.key, required this.filterData});

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
            double normalDiscount =filterData[index].discountByProvider??0;
            double couponDiscount = filterData[index].couponDiscountByProvider??0;
            double campaignDiscount = filterData[index].campaignDiscountByProvider??0;

            double totalExpense =normalDiscount+couponDiscount+campaignDiscount;

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
                  child: Row(children: [

                      Text('booking_id'.tr, style: _expLabelStyle),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(" #${filterData[index].booking?.readableId.toString()??""}",
                          style:  TextStyle(
                            fontSize: 12.5,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            color: InkColors.foreground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [

                    _expRow('normal_discount'.tr, PriceConverter.convertPrice(double.tryParse(filterData[index].discountByProvider.toString()))),
                    _expRow('coupon_discount'.tr, PriceConverter.convertPrice(double.tryParse(filterData[index].couponDiscountByProvider.toString()))),
                    _expRow('campaign_discount'.tr, PriceConverter.convertPrice(double.tryParse(filterData[index].campaignDiscountByProvider.toString()))),

                    const SizedBox(height: 6),
                    _expDivider(),
                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text('total_expense'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _expLabelStrongStyle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(PriceConverter.convertPrice(totalExpense),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _expValueStyle.copyWith(fontSize: 14),
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
