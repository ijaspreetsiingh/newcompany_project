import 'package:jassdbx_serviceman/helper/booking_helper.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';


class BookingSummeryView extends StatelessWidget{
  final BookingDetailsContent bookingDetails;
  const BookingSummeryView({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context){
    return GetBuilder<BookingDetailsController>(builder:(bookingDetailsController){


      double paidAmount = 0;


      double discount= bookingDetails.totalDiscountAmount ?? 0;
      double campaignDiscount= double.tryParse(bookingDetails.totalCampaignDiscountAmount ?? "0" ) ?? 0;
      double totalDiscount =  (discount+campaignDiscount);
      double subTotal = BookingHelper.getSubTotalCost(bookingDetails);

      double totalBookingAmount = bookingDetails.totalBookingAmount ?? 0;
      bool isPartialPayment = bookingDetails.partialPayments !=null && bookingDetails.partialPayments!.isNotEmpty;

      if(isPartialPayment) {
        bookingDetails.partialPayments?.forEach((element) {
          paidAmount = paidAmount + (element.paidAmount ?? 0);
        });
      }else{
        paidAmount  = totalBookingAmount - (bookingDetails.additionalCharge ?? 0);
      }

      double dueAmount = totalBookingAmount - paidAmount;
      double additionalCharge = isPartialPayment ? totalBookingAmount - paidAmount : bookingDetails.additionalCharge ?? 0;

      Widget amountRow(String label, String value, {bool grand = false}) {
        return Padding(
          padding: EdgeInsets.only(bottom: grand ? 0 : 12),
          child: Row(children: [
            Expanded(
              child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: grand
                    ? robotoBold.copyWith(fontSize: 16, color: context.kForeground)
                    : robotoRegular.copyWith(fontSize: 12, color: context.kMutedForeground),
              ),
            ),
            const SizedBox(width: 12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(value,
                style: grand
                    ? robotoBold.copyWith(fontSize: 16, color: context.kForeground)
                    : robotoMedium.copyWith(fontSize: 14, color: context.kForeground),
              ),
            ),
          ]),
        );
      }

      Widget divider() => Container(height: 1, color: context.kBorder, margin: const EdgeInsets.symmetric(vertical: 12));

      Widget totalBox(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: context.kBackground,
          borderRadius: BorderRadius.circular(kRadiusMd),
          border: Border.all(color: context.kInputBorder, width: 1),
        ),
        child: child,
      );

      Widget dueRowAmount(double amount) => amountRow(
        "${(bookingDetails.bookingStatus == "pending"  || bookingDetails.bookingStatus == "accepted" || bookingDetails.bookingStatus == "ongoing")
            ? "due_amount".tr : "paid_amount".tr} (${"cash_after_service".tr})",
        PriceConverter.convertPrice(amount, isShowLongPrice: true),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [

        SectionHeader(title: "booking_summary".tr),

        const SizedBox(height: 12),

        KCard(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("service_info".tr, style: robotoBold.copyWith(fontSize: 12, color: context.kMutedForeground)),
              Text("price".tr, style: robotoBold.copyWith(fontSize: 12, color: context.kMutedForeground)),
            ]),

            const SizedBox(height: 12),

            for (int index = 0; index < (bookingDetails.details?.length ?? 0); index++)
              ServiceInfoItem(
                bookingService : bookingDetails.details?[index],
                bookingDetailsController: bookingDetailsController,
                index: index,
              ),

            divider(),

            amountRow("subtotal_vat_ex".tr, PriceConverter.convertPrice(subTotal, isShowLongPrice:true)),
            amountRow("service_discount".tr, "(-) ${PriceConverter.convertPrice(totalDiscount, isShowLongPrice:true)}"),
            amountRow("coupon_discount".tr, "(-) ${PriceConverter.convertPrice(double.tryParse(bookingDetails.totalCouponDiscountAmount ?? ""), isShowLongPrice:true)}"),

            if(bookingDetails.totalReferralDiscountAmount != null && bookingDetails.totalReferralDiscountAmount! > 0)
              amountRow('referral_discount'.tr, '(-) ${PriceConverter.convertPrice(bookingDetails.totalReferralDiscountAmount ?? 0)}'),

            amountRow("service_tax".tr, "(+) ${PriceConverter.convertPrice( bookingDetails.totalTaxAmount ?? 0, isShowLongPrice:true)}"),

            if(bookingDetails.extraFee != null && bookingDetails.extraFee! > 0)
              amountRow(
                Get.find<SplashController>().configModel?.content?.additionalChargeLabelName ?? "",
                "(+) ${PriceConverter.convertPrice( bookingDetails.extraFee ?? 0, isShowLongPrice:true)}",
              ),

            divider(),

            if(!isPartialPayment && bookingDetails.paymentMethod != "wallet_payment")
              (additionalCharge == 0) ||  bookingDetails.paymentMethod == "cash_after_service" ?
              amountRow('grand_total'.tr, PriceConverter.convertPrice(bookingDetails.totalBookingAmount ?? 0, isShowLongPrice: true), grand: true)
              :
              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                child: totalBox(Column(children: [
                  amountRow('grand_total'.tr, PriceConverter.convertPrice( totalBookingAmount ,isShowLongPrice: true), grand: true),
                  if(additionalCharge > 0 ) ...[
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    dueRowAmount(additionalCharge),
                  ],
                ])),
              )
            else if(!isPartialPayment && bookingDetails.paymentMethod == "wallet_payment")
              totalBox(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                amountRow('grand_total'.tr, PriceConverter.convertPrice(bookingDetails.totalBookingAmount ?? 0, isShowLongPrice: true), grand: true),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: context.kMuted,
                    borderRadius: BorderRadius.circular(kRadiusSm),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start ,children: [

                    Text( (bookingDetails.additionalCharge! <= 0) ? 'total_order_amount_has_been_paid_by_customer'.tr : "has_been_paid_by_customer".tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: context.kMutedForeground),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        Image.asset(Images.walletSmall, width: 17,),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                        Text( 'via_wallet'.tr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: context.kMutedForeground),
                          overflow: TextOverflow.ellipsis,),
                      ],),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          PriceConverter.convertPrice( paidAmount ,isShowLongPrice: true),
                          style: robotoMedium.copyWith(fontSize: 14, color: context.kForeground),),
                      ),
                    ]),

                    if(additionalCharge > 0 )
                      dueRowAmount(additionalCharge),

                  ]),
                ),
              ]))
            else if(isPartialPayment)
              totalBox(Column(children: [
                amountRow('grand_total'.tr, PriceConverter.convertPrice( totalBookingAmount, isShowLongPrice: true), grand: true),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                for (int index = 0; index < (bookingDetails.partialPayments?.length ?? 0); index++)
                  _partialPaymentRow(context, bookingDetails, index),

                if(bookingDetails.partialPayments?.length == 1 && dueAmount > 0)
                  dueRowAmount(dueAmount),

              ]))
            else
              amountRow('grand_total'.tr, PriceConverter.convertPrice( totalBookingAmount, isShowLongPrice: true), grand: true),

          ]),
        ),
      ],
      );
    },
    );
  }

  Widget _partialPaymentRow(BuildContext context, BookingDetailsContent bookingDetails, int index) {
    String payWith = bookingDetails.partialPayments?[index].paidWith ?? "";

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Image.asset(Images.walletSmall, width: 15,),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
          Flexible(
            child: Text( '${ payWith == "cash_after_service" ? "paid_amount".tr : payWith == "digital" && bookingDetails.paymentMethod == "offline_payment" ? ""  :'paid_by'.tr} ''${payWith == "digital" ? "${bookingDetails.paymentMethod}".tr : (payWith == "cash_after_service" ? "(${'cash_after_service'.tr})" : payWith).tr }',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: context.kMutedForeground),
              overflow: TextOverflow.ellipsis,),
          ),
        ]),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            PriceConverter.convertPrice( bookingDetails.partialPayments?[index].paidAmount ?? 0,isShowLongPrice: true),
            style: robotoMedium.copyWith(fontSize: 14, color: context.kForeground),),
        )]),
    );
  }
}


class ServiceInfoItem extends StatelessWidget {
  final int index;
  final BookingDetailsController bookingDetailsController;
  final ItemService? bookingService;
  const ServiceInfoItem({
    super.key,required this.bookingService,
    required this.bookingDetailsController,
    required this.index});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Text(bookingService?.serviceName??"",
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: context.kForeground),
                  overflow: TextOverflow.ellipsis,
                )
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault,),
            Text(PriceConverter.convertPrice(BookingHelper.getBookingServiceUnitConst(bookingService), isShowLongPrice:true,),
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: context.kForeground),
            ),
          ],
          ),

          if(bookingService?.variantKey!=null)
            Padding(padding: const EdgeInsets.only( top: Dimensions.paddingSizeExtraSmall),
              child: Row(children: [

                Flexible(
                  child: Text(bookingService?.variantKey?.replaceAll("-", " ").capitalizeFirst ?? "",
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: context.kMutedForeground),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Container(
                  height: 10, width: 0.5,
                  color: context.kBorder,
                  margin : const EdgeInsets.only(left : Dimensions.paddingSizeSmall, right:  Dimensions.paddingSizeSmall, top: 5),
                ),

                Text("${"qty".tr} : ${bookingService?.quantity}",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: context.kMutedForeground),
                ),

              ]),
            ),

          priceText("unit_price".tr, bookingService?.serviceCost??"0", context),

        ],
      ),
    );
  }

}


Widget priceText(String title,var amount,BuildContext context){
  return Column(children: [
    Row(
      children: [
        Text("$title : ",
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: context.kMutedForeground),
        ),
        Text(PriceConverter.convertPrice(amount,isShowLongPrice:true),
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: context.kMutedForeground),
        ),
      ],
    ),
    const SizedBox(height:Dimensions.paddingSizeExtraSmall),
  ],
  );
}
