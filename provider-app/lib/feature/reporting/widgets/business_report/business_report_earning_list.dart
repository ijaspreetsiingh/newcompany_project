import 'package:demandium_provider/feature/reporting/model/business_report_earning_model.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

 TextStyle _earnLabelStyle = TextStyle(
  fontSize: 12.5,
  height: 1.3,
  fontWeight: FontWeight.w500,
  color: InkColors.mutedForeground,
);

 TextStyle _earnLabelStrongStyle = TextStyle(
  fontSize: 13,
  height: 1.3,
  fontWeight: FontWeight.w700,
  color: InkColors.foreground,
);

 TextStyle _earnValueStyle = TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontSize: 13,
  height: 1.3,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.2,
  color: InkColors.foreground,
);

Widget _earnRow(String label, String value, {TextStyle? style}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 5),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: _earnLabelStyle)),
      const SizedBox(width: 12),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: style ?? _earnValueStyle),
    ],
  ),
);

Widget _earnDivider() => Container(height: 1, color: InkColors.border);

class BusinessReportEarningListView extends StatelessWidget {
  final  List<BusinessReportEarningFilterData>  filterData;
  const BusinessReportEarningListView({super.key, required this.filterData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        filterData.isNotEmpty?
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          itemBuilder: (context,index){

            double  netProfit = filterData[index].bookingDetailsAmounts?.providerEarning??0;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('booking_id'.tr, style: _earnLabelStyle),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(" #${filterData[index].readableId.toString()}",
                            style:  TextStyle(
                              fontSize: 12.5,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              color: InkColors.foreground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('booking_amount'.tr, style: _earnLabelStyle),
                          Text(PriceConverter.convertPrice(filterData[index].totalBookingAmount),
                            maxLines: 1,
                            style: _earnValueStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],)
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [

                    _earnRow('total_service_discount'.tr, PriceConverter.convertPrice(filterData[index].totalDiscountAmount)),
                    _earnRow('provider_paid_service_discount'.tr, PriceConverter.convertPrice(filterData[index].bookingDetailsAmounts?.discountByProvider??0)),
                    _earnRow('total_coupon_discount'.tr, PriceConverter.convertPrice(filterData[index].totalCouponDiscountAmount)),
                    _earnRow('provider_paid_coupon_discount'.tr, PriceConverter.convertPrice(filterData[index].bookingDetailsAmounts?.couponDiscountByProvider??0)),
                    _earnRow('total_campaign_discount'.tr, PriceConverter.convertPrice(filterData[index].totalCampaignDiscountAmount)),
                    _earnRow('provider_paid_campaign_discount'.tr, PriceConverter.convertPrice(filterData[index].bookingDetailsAmounts?.campaignDiscountByProvider??0)),

                    const SizedBox(height: 6),
                    _earnDivider(),
                    const SizedBox(height: 6),

                    _earnRow('sub_total'.tr, PriceConverter.convertPrice(filterData[index].totalBookingAmount)),
                    _earnRow('admin_commission'.tr, PriceConverter.convertPrice(filterData[index].bookingDetailsAmounts?.adminCommission??0)),
                    _earnRow("${'vat/tax'.tr} : ", PriceConverter.convertPrice(filterData[index].totalTaxAmount)),

                    const SizedBox(height: 6),
                    _earnDivider(),
                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text('provider_net_income'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _earnLabelStrongStyle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(PriceConverter.convertPrice(netProfit),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _earnValueStyle.copyWith(fontSize: 14),
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
