import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';
import 'package:jdds/feature/offers/widget/offer_item_view.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key}) ;
  @override
  State<OfferScreen> createState() => _OfferScreenState();
}
class _OfferScreenState extends State<OfferScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<ServiceController>().getOffersList(1,true);
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
      endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,

      appBar: CustomAppBar(
        title: 'offers'.tr,
      ),

      body: GetBuilder<ServiceController>(
        builder: (serviceController){

          bool hasData = serviceController.offerBasedServiceList != null &&
              serviceController.offerBasedServiceList!.isNotEmpty;

          return FooterBaseView(
            scrollController: scrollController,
            bottomPadding: false,
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                /// Special Offer hero banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeExtraSmall,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Color.lerp(Theme.of(context).colorScheme.primary, const Color(0xFFE65100), 0.45)!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge + 4),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(children: [

                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('special_offer'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('current_offers'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.local_offer_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text('offers'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Colors.white,
                                ),
                              ),
                            ]),
                          ),
                        ]),
                      ),

                      Container(
                        height: 64, width: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        ),
                        child: const Icon(Icons.local_offer_rounded, size: 34, color: Colors.white),
                      ),
                    ]),
                  ),
                ),

                /// Section header
                if(hasData) Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeDefault,
                    0,
                  ),
                  child: Row(children: [
                    Container(
                      height: 30, width: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                      ),
                      child: Icon(Icons.workspace_premium_outlined,
                        size: 17, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text('current_offers'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    if(serviceController.offerBasedServiceContent?.total != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text('${serviceController.offerBasedServiceContent!.total}',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  ]),
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                PaginatedListView(
                  scrollController: scrollController,
                  totalSize: serviceController.offerBasedServiceContent?.total,
                  offset: serviceController.offerBasedServiceContent?.currentPage,
                  onPaginate: (int offset) async => await serviceController.getOffersList(offset, false),
                  itemView: OfferItemView(
                    service: serviceController.offerBasedServiceList,
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
