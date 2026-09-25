import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';
import 'package:readmore/readmore.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final String? serviceID;
  final String? fromPage;
  const ServiceDetailsScreen({super.key, this.serviceID, this.fromPage = "others"});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  final scaffoldState = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (widget.serviceID != null) {
      Get.find<ServiceDetailsController>().getServiceDetails(widget.serviceID!,
          fromPage: widget.fromPage == "search_page" ? "search_page" : "");
      
      // Load recently viewed services after main service data
      if (Get.find<AuthController>().isLoggedIn()) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.find<ServiceController>().getRecentlyViewedServiceList(1, true);
        });
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        key: scaffoldState,
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
        endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        body: GetBuilder<ServiceDetailsController>(
          builder: (serviceController) {
            if (serviceController.service != null || widget.serviceID == null) {
              if (serviceController.service != null &&
                  serviceController.service!.id != null &&
                  widget.serviceID != null) {
                Service? service = serviceController.service;
                Discount discount = PriceConverter.discountCalculation(service!);
                double lowestPrice = 0.0;
                if (service.variationsAppFormat?.zoneWiseVariations != null &&
                    service.variationsAppFormat!.zoneWiseVariations!.isNotEmpty) {
                  lowestPrice = service
                      .variationsAppFormat!.zoneWiseVariations![0].price
                      ?.toDouble() ?? 0.0;
                  for (var i = 1;
                      i < service.variationsAppFormat!.zoneWiseVariations!.length;
                      i++) {
                    double itemPrice = service.variationsAppFormat!.zoneWiseVariations![i].price?.toDouble() ?? 0.0;
                    if (itemPrice < lowestPrice) {
                      lowestPrice = itemPrice;
                    }
                  }
                }

                final String coverImage = (service.coverImageFullPath ?? '').isNotEmpty
                    ? service.coverImageFullPath!
                    : ((service.thumbnailFullPath ?? '').isNotEmpty)
                        ? service.thumbnailFullPath!
                        : '';
                final List<String> galleryImages = [...(service.gallery ?? [])];

                return Stack(children: [
                  /// Main scrollable content
                  RefreshIndicator(
                    onRefresh: () async {
                      await Get.find<ServiceDetailsController>()
                          .getServiceDetails(widget.serviceID!,
                              fromPage: widget.fromPage == "search_page"
                                  ? "search_page"
                                  : "");
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 1. Hero image - cover only, 3:1 perfect fit (no crop)
                            _HeroImageSection(
                              coverImage: coverImage,
                              service: service,
                            ),

                            /// 2. Service name + rating + bookmark + thumbnail
                            _ServiceInfoSection(service: service),

                            /// 3. Price row
                            _PriceSection(
                              service: service,
                              discount: discount,
                              lowestPrice: lowestPrice,
                            ),

                            /// 4. About me
                            _AboutSection(
                                description: service.description ?? ''),

                            /// 5. Photos & Videos gallery grid — sirf gallery images (cover nahi)
                            if (galleryImages.isNotEmpty)
                              _ServiceGalleryGrid(
                                images: galleryImages,
                                scrollController: _scrollController,
                              ),

                            /// 6. Ratings & Reviews
                            _ReviewsSection(
                                serviceId: service.id ?? '',
                                scrollController: _scrollController),

                            /// Bottom padding for buttons
                            const SizedBox(height: 80),
                          ]),
                    ),
                  ),

                  /// Top back + cart buttons overlaid
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _TopBarOverlay(service: service),
                  ),

                  /// Bottom buttons
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _BottomActionButtons(service: service),
                  ),
                ]);
              } else {
                return NoDataScreen(
                  text: 'no_service_available'.tr,
                  type: NoDataType.service,
                );
              }
            } else {
              return const ServiceDetailsShimmerWidget();
            }
          },
        ),
      ),
    );
  }
}

/// Top bar with back + cart icons overlaid on hero
class _TopBarOverlay extends StatelessWidget {
  final Service service;
  const _TopBarOverlay({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeSmall),
          child: Row(children: [
            InkWell(
              onTap: () => Get.back(),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Colors.black87),
              ),
            ),
            const Spacer(),
            GetBuilder<CartController>(builder: (cartController) {
              return InkWell(
                onTap: () => Get.toNamed(RouteHelper.getCartRoute()),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  child: Stack(children: [
                    const Center(
                      child: Icon(Icons.shopping_cart_outlined,
                          size: 20, color: Colors.black87),
                    ),
                    if (cartController.cartList.isNotEmpty)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cartController.cartList.length}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ]),
                ),
              );
            }),
          ]),
        ),
      ),
    );
  }
}

/// Hero image section - cover only, AspectRatio 3:1 (perfect fit, no side cut)
class _HeroImageSection extends StatelessWidget {
  final String coverImage;
  final Service service;
  const _HeroImageSection({required this.coverImage, required this.service});

  @override
  Widget build(BuildContext context) {
    if (coverImage.isEmpty) {
      return Container(
        width: double.infinity,
        height: ResponsiveHelper.isDesktop(context) ? 400 : 300,
        color: Theme.of(context).cardColor,
        child: Center(
          child: Image.asset(Images.placeholder, width: 150),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 3,
      child: CustomImage(
        image: coverImage,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: Images.placeholder,
      ),
    );
  }
}

/// Service info section - name, rating, bookmark
class _ServiceInfoSection extends StatelessWidget {
  final Service service;
  const _ServiceInfoSection({required this.service});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeDefault,
          0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        /// Thumbnail (1:1) — admin se upload hua service thumbnail yahan dikhega
        if ((service.thumbnailFullPath ?? '').isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: CustomImage(
              image: service.thumbnailFullPath!,
              height: 72,
              width: 72,
              fit: BoxFit.cover,
              placeholder: Images.placeholder,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],

        /// Name + Bookmark
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(service.name ?? '',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeOverLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          FavoriteIconWidget(
            value: service.isFavorite,
            serviceId: service.id,
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        /// Rating row
        Row(children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFF9900), size: 22),
          const SizedBox(width: Dimensions.paddingSizeMini),
          Text((service.avgRating ?? 0.0).toStringAsFixed(1),
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          Text('  (${service.ratingCount ?? 0} ${'reviews'.tr})',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            ),
          ),
        ]),
      ]),
    );
  }
}

/// Price section - only price, no ADD button
class _PriceSection extends StatelessWidget {
  final Service service;
  final Discount discount;
  final double lowestPrice;
  const _PriceSection(
      {required this.service,
      required this.discount,
      required this.lowestPrice});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if ((discount.discountAmount ?? 0) > 0)
          Text(PriceConverter.convertPrice(lowestPrice, isShowLongPrice: true),
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              decoration: TextDecoration.lineThrough,
              color: Theme.of(context).hintColor,
            ),
          ),
        Text(
          PriceConverter.convertPrice(
            lowestPrice,
            discount: discount.discountAmount?.toDouble() ?? 0.0,
            discountType: discount.discountAmountType ?? 'amount',
            isShowLongPrice: true,
          ),
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeOverLarge + 4,
            color: Get.isDarkMode
                ? Theme.of(context).primaryColorLight
                : Theme.of(context).primaryColor,
          ),
        ),
      ]),
    );
  }
}

/// About section
class _AboutSection extends StatelessWidget {
  final String description;
  const _AboutSection({required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeDefault,
          0,
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('about_me'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        ReadMoreText(
          description,
          trimCollapsedText: "see_more".tr,
          trimExpandedText: "  ${"see_less".tr}",
          trimMode: TrimMode.Line,
          trimLines: 3,
          style: robotoRegular.copyWith(
            color: Theme.of(context)
                .textTheme
                .bodySmall
                ?.color
                ?.withValues(alpha: 0.6),
            fontSize: Dimensions.fontSizeDefault,
            height: 1.5,
          ),
          moreStyle: robotoMedium.copyWith(
              color: Theme.of(context).colorScheme.primary),
          lessStyle: robotoMedium.copyWith(
              color: Theme.of(context).colorScheme.primary),
        ),
      ]),
    );
  }
}

/// Photos & Videos gallery grid
class _ServiceGalleryGrid extends StatelessWidget {
  final List<String> images;
  final ScrollController scrollController;
  const _ServiceGalleryGrid(
      {required this.images, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final List<String> previewImages = images.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('photos_&_videos'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          InkWell(
            onTap: () =>
                Get.dialog(_GalleryFullViewDialog(images: images)),
            child: Text('see_all'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          itemCount: previewImages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: Dimensions.paddingSizeSmall,
            mainAxisSpacing: Dimensions.paddingSizeSmall,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => Get.dialog(
                  _GalleryFullViewDialog(
                      images: images, initialIndex: index)),
              borderRadius:
                  BorderRadius.circular(Dimensions.radiusDefault),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusDefault),
                child: CustomImage(
                  image: previewImages[index],
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: Images.placeholder,
                ),
              ),
            );
          },
        ),
      ]),
    );
  }
}

/// Ratings & Reviews section
class _ReviewsSection extends StatefulWidget {
  final String serviceId;
  final ScrollController scrollController;
  const _ReviewsSection(
      {required this.serviceId, required this.scrollController});

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  @override
  void initState() {
    super.initState();
    Get.find<ServiceTabController>().getServiceReview(widget.serviceId, 1);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceTabController>(
        builder: (serviceTabController) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Row(children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFF9900), size: 22),
                const SizedBox(width: Dimensions.paddingSizeMini),
                Flexible(
                  child: Text(
                    '${serviceTabController.rating.averageRating?.toStringAsFixed(1) ?? '0.0'} (${serviceTabController.rating.ratingCount ?? 0} ${'reviews'.tr})',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color:
                          Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ),
            InkWell(
              onTap: () {
                Get.to(() => Scaffold(
                      appBar: CustomAppBar(
                          centerTitle: false, title: 'reviews'.tr),
                      body: SafeArea(
                          child: ServiceDetailsReview(
                              serviceID: widget.serviceId)),
                    ));
              },
              child: Text('see_all'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        serviceTabController.reviewList != null &&
                serviceTabController.reviewList!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: serviceTabController.reviewList!.length,
                  itemBuilder: (context, index) {
                    return ServiceReviewItem(
                      review: serviceTabController.reviewList![index],
                      isProviderReview: false,
                      index: index,
                    );
                  },
                ),
              )
            : const Padding(
                padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Center(child: Text('no_review_yet')),
              ),
      ]);
    });
  }
}

/// Bottom Action buttons
class _BottomActionButtons extends StatelessWidget {
  final Service service;
  const _BottomActionButtons({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Theme.of(context).cardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Get.isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeDefault),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        Dimensions.radiusExtraLarge)),
                elevation: 0,
              ),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ServiceCenterDialog(
                          service: service,
                          isFromDetails: true,
                        ));
              },
              child: Text('add'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeDefault),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        Dimensions.radiusExtraLarge)),
                elevation: 0,
              ),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ServiceCenterDialog(
                          service: service,
                          isFromDetails: true,
                        ));
              },
              child: Text('book_now'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Full gallery view dialog
class _GalleryFullViewDialog extends StatelessWidget {
  final List<String> images;
  final int initialIndex;
  const _GalleryFullViewDialog(
      {required this.images, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Stack(children: [
        Center(
          child: CarouselSlider.builder(
            options: CarouselOptions(
              height: Get.height * 0.6,
              viewportFraction: 1.0,
              enableInfiniteScroll: images.length > 1,
              initialPage: initialIndex,
            ),
            itemCount: images.length,
            itemBuilder: (context, index, _) {
              return ClipRRect(
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusLarge),
                child: CustomImage(
                  image: images[index],
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: Images.placeholder,
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: InkWell(
            onTap: () => Get.back(),
            child: Container(
              height: 36,
              width: 36,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.black54),
              child: const Icon(Icons.close,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
      ]),
    );
  }
}
