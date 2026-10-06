import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/feature/offers/widget/offer_item_card.dart';

class OfferItemView extends StatelessWidget {
  final List<Service>? service;
  final EdgeInsetsGeometry? padding;
  final bool? isScrollable;
  final int? shimmerLength;
  final GlobalKey<CustomShakingWidgetState>? signInShakeKey;

  const OfferItemView({
    super.key,
    required this.service,
    this.isScrollable = false,
    this.shimmerLength = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
    this.signInShakeKey,
  });

  @override
  Widget build(BuildContext context) {
    bool isNull = service == null;
    int length = isNull ? 1 : service!.length;

    Widget emptyState() {
      return Center(
        child: SizedBox(
          height: ResponsiveHelper.isDesktop(context)
              ? MediaQuery.of(context).size.height * 0.6
              : MediaQuery.of(context).size.height * 0.45,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              height: 96, width: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              ),
              child: Image.asset(Images.emptyOffer, width: 46,),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text('no_offer_found'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text('current_offers'.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
          ]),
        ),
      );
    }

    Widget gridView({required int count, bool shimmer = false}) {
      return GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingSizeDefault,
          mainAxisSpacing: Dimensions.paddingSizeDefault,
          mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 285 : 255,
          crossAxisCount: ResponsiveHelper.isDesktop(context)
              ? 5
              : ResponsiveHelper.isTab(context) ? 3 : 2,
        ),
        physics: isScrollable! ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: isScrollable! ? false : true,
        itemCount: count,
        padding: padding,
        itemBuilder: (context, index) {
          return shimmer
              ? ServiceShimmer(isEnabled: true, hasDivider: false)
              : OfferItemCard(service: service![index], signInShakeKey: signInShakeKey);
        },
      );
    }

    return Column(mainAxisSize: MainAxisSize.min, children: [
      !isNull && length != 0
          ? gridView(count: length)
          : length == 0
              ? emptyState()
              : gridView(count: shimmerLength!, shimmer: true),
    ]);
  }
}



