import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class PopularServiceListView extends StatefulWidget {
  final List<Service>? serviceList;
  const PopularServiceListView({super.key, required this.serviceList});

  @override
  State<PopularServiceListView> createState() => _PopularServiceListViewState();
}

class _PopularServiceListViewState extends State<PopularServiceListView> {
  int _selectedChipIndex = -1;

  @override
  Widget build(BuildContext context) {
    final List<Service>? services = widget.serviceList;

    if(services == null){
      return const PopularServiceListShimmer();
    }
    if(services.isEmpty){
      return const SizedBox();
    }

    final List<CategoryModel> categories = Get.find<CategoryController>().categoryList ?? [];

    /// Filter services by selected category chip
    List<Service> filteredServices = _selectedChipIndex == -1
        ? services
        : services.where((service) =>
            service.categoryId == categories[_selectedChipIndex].id).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      /// Title
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: TitleWidget(
          title: 'most_popular_services',
          onTap: () => Get.toNamed(RouteHelper.getSearchResultRoute(fromPage: "popular")),
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      /// Category chips
      SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            bool isSelected = index == 0 ? _selectedChipIndex == -1 : _selectedChipIndex == index - 1;
            String label = index == 0 ? 'all'.tr : categories[index - 1].name ?? '';

            return Padding(
              padding: const EdgeInsetsDirectional.only(end: Dimensions.paddingSizeSmall),
              child: InkWell(
                onTap: () => setState(() => _selectedChipIndex = index == 0 ? -1 : index - 1),
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall + 1),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor.withValues(alpha:0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    label,
                    style: isSelected
                        ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white)
                        : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodySmall?.color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      /// Vertical service cards
      filteredServices.isNotEmpty ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Column(children: List.generate(
          filteredServices.length > 5 ? 5 : filteredServices.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            child: PopularServiceCard(service: filteredServices[index]),
          ),
        )),
      ) : Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
        child: Center(child: Text('no_service_found'.tr, style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).hintColor,
        ))),
      ),
    ]);
  }
}

class PopularServiceCard extends StatelessWidget {
  final Service service;
  const PopularServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    num lowestPrice = 0.0;
    if(service.variationsAppFormat?.zoneWiseVariations != null && service.variationsAppFormat!.zoneWiseVariations!.isNotEmpty){
      lowestPrice = service.variationsAppFormat!.zoneWiseVariations![0].price ?? 0.0;
      for (var i = 1; i < service.variationsAppFormat!.zoneWiseVariations!.length; i++) {
        num itemPrice = service.variationsAppFormat!.zoneWiseVariations![i].price ?? 0.0;
        if (itemPrice < lowestPrice) {
          lowestPrice = itemPrice;
        }
      }
    }

    Discount discountModel = PriceConverter.discountCalculation(service);

    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getServiceRoute(service.slug ?? '')),
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          border: Get.isDarkMode
              ? Border.all(color: Theme.of(context).primaryColorLight.withValues(alpha:0.15))
              : Border.all(color: Theme.of(context).shadowColor.withValues(alpha:0.15)),
          boxShadow: Get.find<ThemeController>().darkTheme ? null : searchBoxShadow,
        ),
        child: Row(children: [

          /// Service image
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: CustomImage(
              image: service.thumbnailFullPath ?? '',
              height: 75, width: 75,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          /// Details
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text(
                service.category?.name ?? '',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).hintColor,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              Text(
                service.name ?? '',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              Text(
                PriceConverter.convertPrice(lowestPrice.toDouble(),
                  discount: discountModel.discountAmount?.toDouble() ?? 0.0,
                  discountType: discountModel.discountAmountType,
                ),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              /// Rating row
              Row(children: [
                Icon(Icons.star_rounded, color: const Color(0xFFFF9900), size: 16),
                const SizedBox(width: 2),
                Text(
                  (service.avgRating ?? 0).toStringAsFixed(1),
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  '  |  ${service.ratingCount ?? 0}+ ${'reviews'.tr}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ]),
            ]),
          ),

          /// Favorite icon
          FavoriteIconWidget(
            value: service.isFavorite,
            serviceId: service.id,
          ),
        ]),
      ),
    );
  }
}

class PopularServiceListShimmer extends StatelessWidget {
  const PopularServiceListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(height: 20, width: 160, decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            )),
            Container(height: 16, width: 55, decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            )),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        SizedBox(
          height: 34,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) => Container(
              height: 34, width: 80,
              margin: const EdgeInsetsDirectional.only(end: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
              ),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Column(children: List.generate(3, (index) => Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          ),
          child: Row(children: [
            Shimmer(duration: const Duration(seconds: 2), enabled: true,
              child: Container(
                height: 75, width: 75,
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Shimmer(duration: const Duration(seconds: 2), enabled: true,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(height: 10, width: 80, color: Theme.of(context).shadowColor),
                  const SizedBox(height: 6),
                  Container(height: 14, width: 140, color: Theme.of(context).shadowColor),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 60, color: Theme.of(context).shadowColor),
                ]),
              ),
            ),
          ]),
        ))),
      ]),
    );
  }
}
