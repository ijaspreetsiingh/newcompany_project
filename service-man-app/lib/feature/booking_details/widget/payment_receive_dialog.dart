import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class PaymentReceiveDialog extends StatefulWidget {
  final String bookingId;
  final String orderAmount;
  final bool isSubBooking;
  const PaymentReceiveDialog(this.bookingId, this.orderAmount, {super.key, required this.isSubBooking,});

  @override
  State<PaymentReceiveDialog> createState() => _PaymentReceiveDialogState();
}

class _PaymentReceiveDialogState extends State<PaymentReceiveDialog>{
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.only(
          left: Dimensions.paddingSizeDefault,
          bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: context.kCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusLg)),
        border: Border(top: BorderSide(color: context.kBorder, width: 1)),
      ),
      child: GetBuilder<BookingDetailsController>(
          builder: (bookingDetailsController) {
            return SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                        onTap: () => Get.back(),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeDefault,
                              right: Dimensions.paddingSizeDefault),
                          child: Icon(Icons.close_rounded, color: context.kForeground,),
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                        right: Dimensions.paddingSizeDefault,
                        top: ResponsiveHelper.isDesktop(context)
                            ? 0
                            : Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 100,
                              child: Image.asset(Images.money),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                            Text("collected_money_from_customer".tr,
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: context.kForeground),),
                            const SizedBox(height: Dimensions.paddingSizeLarge,),

                            Row( crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${"order_amount".tr} : ',style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: context.kMutedForeground),),
                                Text(PriceConverter.convertPrice(double.parse(widget.orderAmount)),
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: context.kForeground),),
                              ],),
                            const SizedBox(height: Dimensions.paddingSizeLarge,),


                            CustomButton(
                              onPressed:(){
                                bookingDetailsController.changePaymentStatus(widget.bookingId,"paid");
                                bookingDetailsController.changeBookingStatus(bookingId : widget.bookingId, bookingStatus:  "completed", isSubBooking: widget.isSubBooking);
                                Get.back();
                              },
                              btnTxt: 'ok'.tr,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                          ]),
                    ),
                  ]),
            );
          }),
    );
  }
}
