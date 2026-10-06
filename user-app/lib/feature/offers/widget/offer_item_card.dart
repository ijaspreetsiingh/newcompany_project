import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class OfferItemCard extends StatelessWidget {
  final Service service;
  final GlobalKey<CustomShakingWidgetState>? signInShakeKey;
  const OfferItemCard({super.key, required this.service, this.signInShakeKey});

  num _lowestPrice() {
    num lowestPrice = 0.0;
    if(service.variationsAppFormat?.zoneWiseVariations != null){
      lowestPrice = service.variationsAppFormat!.zoneWiseVariations![0].price!;
      for (var i = 0; i < service.variationsAppFormat!.zoneWiseVariations!.length; i++) {
        if (service.variationsAppFormat!.zoneWiseVariations![i].price! < lowestPrice) {
          lowestPrice = service.variationsAppFormat!.zoneWiseVariations![i].price!;
        }
      }
    }
    return lowestPrice;
  }

  @override
  Widget build(BuildContext context) {
    Discount discountModel = PriceConverter.discountCalculation(service);
    num lowestPrice = _lowestPrice();

    return OnHover(
      isItem: true,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          boxShadow: Get.find<ThemeController>().darkTheme ? null : cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.toNamed(RouteHelper.getServiceRoute(service.slug!)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            /// Image + discount + favorite
            Stack(children: [
              CustomImage(
                image: '${service.thumbnailFullPath}',
                fit: BoxFit.cover,
                width: double.maxFinite,
                height: 118,
              ),

              discountModel.discountAmount! > 0 ? Align(
                alignment: Alignment.topLeft,
                child: DiscountTagWidget(
                  discountAmount: discountModel.discountAmount,
                  discountAmountType: discountModel.discountAmountType,
                ),
              ) : const SizedBox(),

              Align(
                alignment: Alignment.topRight,
                child: FavoriteIconWidget(
                  value: service.isFavorite,
                  serviceId: service.id!,
                  signInShakeKey: signInShakeKey,
                ),
              ),
            ]),

            /// Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text(
                    service.name ?? "",
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  Text(
                    'starts_from'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),

                  const Spacer(),

                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if(discountModel.discountAmount! > 0)
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              PriceConverter.convertPrice(lowestPrice.toDouble()),
                              maxLines: 1,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                decoration: TextDecoration.lineThrough,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            discountModel.discountAmount! > 0
                                ? PriceConverter.convertPrice(
                                    lowestPrice.toDouble(),
                                    discount: discountModel.discountAmount!.toDouble(),
                                    discountType: discountModel.discountAmountType)
                                : PriceConverter.convertPrice(lowestPrice.toDouble()),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Get.isDarkMode
                                  ? Theme.of(context).primaryColorLight
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    InkWell(
                      onTap: () => showModalBottomSheet(
                        useRootNavigator: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) => ServiceCenterDialog(service: service),
                      ),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Container(
                        height: 34, width: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        ),
                        child: Icon(Icons.add,
                          size: 20,
                          color: Get.isDarkMode
                              ? Theme.of(context).primaryColorLight
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}


