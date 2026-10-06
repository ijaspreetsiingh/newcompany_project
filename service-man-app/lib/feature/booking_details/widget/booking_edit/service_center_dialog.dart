import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';


class ServiceCenterDialog extends StatefulWidget {
  final ServiceModel? service;
  final int selectedServiceIndex;
  const ServiceCenterDialog({super.key, this.service, required this.selectedServiceIndex});

  @override
  State<ServiceCenterDialog> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ServiceCenterDialog> {

  @override
  void initState() {
    super.initState();
    Get.find<BookingEditController>().resetSelectedServiceVariationQuantity(widget.selectedServiceIndex);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingEditController>(builder: (bookingEditController){

      return Container(
        width:ResponsiveHelper.isDesktop(context)? Dimensions.webMaxWidth/2:Dimensions.webMaxWidth,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: context.kCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusLg)),
          border: Border(top: BorderSide(color: context.kBorder, width: 1)),
        ),
        child:  Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: Dimensions.paddingSizeLarge*2,),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                child: CustomImage(
                  image: widget.service?.thumbnailFullPath ?? "",
                  height: 60, width: 60,
                ),
              ),
              Container( height: 40, width: 40, alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: context.kMuted),
                child: InkWell( onTap: () => Get.back(),
                  child: Icon(Icons.close_rounded, color: context.kForeground,),
                ),
              )
            ],
          ),

          Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Text( widget.service?.name??"", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: context.kForeground), textAlign: TextAlign.center, maxLines: 2,),
          ),


          Text(
            "${widget.service?.variations?.length??"0"} ${'variation_available'.tr}",
            style: robotoRegular.copyWith(color: context.kMutedForeground),
          ),

          ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: Get.height * 0.1,
                maxHeight: Get.height * 0.4
            ),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.service?.variations?.length,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                itemBuilder: (context, index) {
                  return Padding(
                    padding:  const EdgeInsets.symmetric(vertical:Dimensions.paddingSizeSmall),
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: context.kCard,
                        borderRadius: const BorderRadius.all(Radius.circular(kRadiusMd),),
                        border: Border.all(color: context.kBorder, width: 1),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${widget.service?.variations?[index].variantKey.toString().capitalizeFirst}".replaceAll('-', ' '), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: context.kForeground),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text( PriceConverter.convertPrice(widget.service?.variations?[index].price,isShowLongPrice:true),
                                    style: robotoMedium.copyWith(color: context.kForeground, fontSize: Dimensions.fontSizeSmall)),
                              ),
                            ],
                          ),
                        ),

                        Expanded( flex:1,
                          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                            widget.service!.variations![index].quantity > 0 ? InkWell(
                              onTap: (){
                                bookingEditController.updatedVariationQuantity(widget.selectedServiceIndex, index, increment: false);
                              },
                              child: Container(
                                height: 30, width: 30,
                                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.kCard,
                                    border: Border.all(color: context.kInputBorder, width: 1)
                                ),
                                alignment: Alignment.center,
                                child: Icon(Icons.remove_rounded , size: 15, color: context.kForeground,),
                              ),
                            ) : const SizedBox(),

                            widget.service!.variations![index].quantity > 0 ? Text(
                              widget.service!.variations![index].quantity.toString(),
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: context.kForeground),
                            ) : const SizedBox(),

                            GestureDetector(
                              onTap: (){
                                bookingEditController.updatedVariationQuantity(widget.selectedServiceIndex, index, increment: true);
                              },
                              child: Container(
                                height: 30, width: 30,
                                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.kCard,
                                    border: Border.all(color: context.kInputBorder, width: 1)
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.add_rounded ,
                                  size: 15,
                                  color: context.kForeground,
                                ),
                              ),
                            )
                          ]),
                        ),
                      ]),
                    ),
                  );
                }),
          ),

          CustomButton(
            height: 48,
            onPressed: bookingEditController.isCartButtonActive? () async {
              await bookingEditController.addMultipleCartItem(widget.selectedServiceIndex);
              Get.back();
            } : null,
            btnTxt: 'add_to_cart'.tr,
            isLoading: bookingEditController.isLoading ,
          ),
        ],
        ),
      );
    });
  }
}
