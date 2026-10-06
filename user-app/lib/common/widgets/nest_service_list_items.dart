import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

/// nest. style service list/grid widgets (reference: design_refrence/home-harmony-hub)
/// Shared by See All (search results) and other service listing screens.
/// Rows  : image left, name + rating + price, chevron right, hatrline border card
/// Grid  : image top, category eyebrow, name, price row - bordered card

class NestServiceViewVertical extends StatelessWidget {
  final List<Service>? service;
  final EdgeInsetsGeometry? padding;
  final bool? isScrollable;
  final int? shimmerLength;
  final String? noDataText;
  final String? fromPage;
  final NoDataType? noDataType;
  final Function(String type)? onVegFilterTap;

  const NestServiceViewVertical({
    super.key,
    required this.service,
    this.isScrollable = false,
    this.shimmerLength = 20,
    this.padding = const EdgeInsets.all(Dimensions.paddingSizeDefault),
    this.noDataText,
    this.fromPage = "",
    this.noDataType,
    this.onVegFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNull = service == null;
    final int length = isNull ? 0 : service!.length;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (!isNull && length != 0)
        ListView.builder(
          physics: isScrollable! ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
          shrinkWrap: !isScrollable!,
          padding: padding,
          itemCount: length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: NestServiceListRow(service: service![index]),
            );
          },
        )
      else if (length == 0 && !isNull)
        Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: NoDataScreen(text: noDataText ?? 'no_service_found'.tr, type: noDataType ?? NoDataType.search),
          ),
        )
      else
        const NestServiceRowsShimmer(),
    ]);
  }
}

/// nest. ServiceRow : image left, name + rating + price onwards, chevron right
class NestServiceListRow extends StatelessWidget {
  final Service service;
  final bool showBorder;
  const NestServiceListRow({super.key, required this.service, this.showBorder = true});

  @override
  Widget build(BuildContext context) {
    num lowestPrice = 0.0;
    if (service.variationsAppFormat?.zoneWiseVariations != null &&
        service.variationsAppFormat!.zoneWiseVariations!.isNotEmpty) {
      lowestPrice = service.variationsAppFormat!.zoneWiseVariations![0].price ?? 0.0;
      for (var i = 1; i < service.variationsAppFormat!.zoneWiseVariations!.length; i++) {
        num itemPrice = service.variationsAppFormat!.zoneWiseVariations![i].price ?? 0.0;
        if (itemPrice < lowestPrice) {
          lowestPrice = itemPrice;
        }
      }
    }

    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getServiceRoute(service.slug ?? '')),
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          border: showBorder
              ? Border.all(color: Theme.of(context).primaryColorLight.withValues(alpha: Get.isDarkMode ? 0.4 : 1))
              : null,
        ),
        child: Row(children: [

          /// Image 80x80 rounded
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: CustomImage(
              image: service.thumbnailFullPath ?? '',
              height: 72, width: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          /// Name + rating + price
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(service.name ?? '',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.star_rounded, size: 14, color: Theme.of(context).textTheme.bodyLarge!.color),
                const SizedBox(width: 2),
                Text((service.avgRating ?? 0).toStringAsFixed(1),
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  )),
                Text('  Â·  ${service.ratingCount ?? 0}+ ${'reviews'.tr}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor,
                  )),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Text(PriceConverter.convertPrice(lowestPrice.toDouble()),
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  )),
                Text('  onwards',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor,
                  )),
              ]),
            ]),
          ),

          Icon(Icons.chevron_right_rounded, size: 20, color: Theme.of(context).hintColor),
        ]),
      ),
    );
  }
}

/// nest. service grid card : image top (1.6:1), category eyebrow, name, price + rating
class NestServiceGridCard extends StatelessWidget {
  final Service service;
  const NestServiceGridCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    num lowestPrice = 0.0;
    if (service.variationsAppFormat?.zoneWiseVariations != null &&
        service.variationsAppFormat!.zoneWiseVariations!.isNotEmpty) {
      lowestPrice = service.variationsAppFormat!.zoneWiseVariations![0].price ?? 0.0;
      for (var i = 1; i < service.variationsAppFormat!.zoneWiseVariations!.length; i++) {
        num itemPrice = service.variationsAppFormat!.zoneWiseVariations![i].price ?? 0.0;
        if (itemPrice < lowestPrice) {
          lowestPrice = itemPrice;
        }
      }
    }

    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getServiceRoute(service.slug ?? '')),
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          border: Border.all(color: Theme.of(context).primaryColorLight.withValues(alpha: Get.isDarkMode ? 0.4 : 1)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          /// Image - 1.6:1 aspect
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge - 1)),
              child: SizedBox(
                width: double.infinity,
                child: CustomImage(
                  image: service.thumbnailFullPath ?? '',
                  height: double.infinity, width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          /// Content
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text((service.category?.name ?? '').toUpperCase(),
                  style: robotoBold.copyWith(
                    fontSize: 9,
                    letterSpacing: 0.8,
                    color: Theme.of(context).hintColor,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(service.name ?? '',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Flexible(child: Text(PriceConverter.convertPrice(lowestPrice.toDouble()),
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  )),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.star_rounded, size: 12, color: Theme.of(context).textTheme.bodyLarge!.color),
                    const SizedBox(width: 2),
                    Text((service.avgRating ?? 0).toStringAsFixed(1),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).hintColor,
                      )),
                  ]),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Shimmer while API loads - rows layout
class NestServiceRowsShimmer extends StatelessWidget {
  const NestServiceRowsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(children: List.generate(6, (index) => Container(
        height: 96,
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          border: Border.all(
            color: Theme.of(context).primaryColorLight.withValues(alpha: Get.isDarkMode ? 0.4 : 1),
          ),
        ),
        child: Row(children: [
          Shimmer(duration: const Duration(seconds: 2), enabled: true,
            child: Container(
              height: 72, width: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(child: Shimmer(duration: const Duration(seconds: 2), enabled: true,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(height: 12, width: 150, color: Theme.of(context).shadowColor),
              const SizedBox(height: 8),
              Container(height: 10, width: 90, color: Theme.of(context).shadowColor),
              const SizedBox(height: 8),
              Container(height: 10, width: 70, color: Theme.of(context).shadowColor),
            ]),
          )),
        ]),
      ))),
    );
  }
}



