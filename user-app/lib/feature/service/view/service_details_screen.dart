// ignore_for_file: deprecated_member_use
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';
import 'package:readmore/readmore.dart';
import 'package:google_fonts/google_fonts.dart';

/// nest. style Service Details screen (reference: design_refrence/home-harmony-hub)
/// Square hero, bold black title, grey meta row, grey price strip, warranty card,
/// single black "Book now" CTA - all content from the app's existing API.
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
                            /// 1. Hero image - nest. square-ish (1.5:1)
                            NestDetailHeroImage(coverImage: coverImage),

                            /// 2. nest. info section : category eyebrow, bold name, meta row
                            NestDetailInfo(service: service),

                            /// 3. nest. price strip (grey rounded box)
                            NestDetailPriceStrip(lowestPrice: lowestPrice, discount: discount),

                            /// 4. About
                            NestDetailAbout(description: service.description ?? ''),

                            /// 5. nest. warranty note
                            const NestDetailWarranty(),

                            /// 6. Photos & Videos gallery grid (API data)
                            if (galleryImages.isNotEmpty)
                              NestDetailGallery(
                                images: galleryImages,
                                scrollController: _scrollController,
                              ),

                            /// 7. Ratings & Reviews (API data)
                            NestDetailReviews(
                                serviceId: service.id ?? '',
                                scrollController: _scrollController),

                            /// Bottom padding for CTA
                            const SizedBox(height: 100),
                          ]),
                    ),
                  ),

                  /// Top back + cart buttons overlaid
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: NestDetailTopBar(),
                  ),

                  /// Bottom CTA - nest. single black "Book now Â· price" button
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: NestDetailBottomBar(service: service, lowestPrice: lowestPrice),
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

/// Top bar with back + cart icons overlaid on hero (updated design)
class NestDetailTopBar extends StatelessWidget {
  const NestDetailTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF050505).withValues(alpha: 0.42),
            Colors.transparent,
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16),
          child: Row(children: [
            InkWell(
              onTap: () => Get.back(),
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: bgColor.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 19, color: isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414)),
              ),
            ),
            const Spacer(),
            GetBuilder<CartController>(builder: (cartController) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getCartRoute()),
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: bgColor.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_cart_outlined,
                          size: 19, color: isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414)),
                    ),
                  ),
                  if (cartController.cartList.isNotEmpty)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414),
                          shape: BoxShape.circle,
                          border: Border.all(color: bgColor, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            cartController.cartList.length > 9 ? '9+' : '${cartController.cartList.length}',
                            style: TextStyle(
                                color: bgColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ]),
        ),
      ),
    );
  }
}

/// nest. hero image - 1.5:1 aspect (square-ish like reference)
class NestDetailHeroImage extends StatelessWidget {
  final String coverImage;
  const NestDetailHeroImage({super.key, required this.coverImage});

  @override
  Widget build(BuildContext context) {
    if (coverImage.isEmpty) {
      return Container(
        width: double.infinity,
        height: 260,
        color: Theme.of(context).primaryColorLight,
        child: Center(
          child: Image.asset(Images.placeholder, width: 150),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 1.5,
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

/// nest. info section : uppercase category eyebrow, big bold name, meta row (updated design)
class NestDetailInfo extends StatelessWidget {
  final Service service;
  const NestDetailInfo({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        /// Category eyebrow - nest. uppercase tracking style
        Text((service.category?.name ?? '').toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.14,
            color: mutedColor,
          ),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        /// Name + favorite
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(service.name ?? '',
              style: GoogleFonts.manrope(
                fontSize: 28, height: 1.04, fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          FavoriteIconWidget(
            value: service.isFavorite,
            serviceId: service.id,
          ),
        ]),
        const SizedBox(height: 8),

        /// Meta row - rating Â· reviews (nest. mono mintmal)
        Row(children: [
          Icon(Icons.star_rounded, size: 14, color: primaryColor, fill: 1.0),
          const SizedBox(width: 4),
          Text((service.avgRating ?? 0.0).toStringAsFixed(2),
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          Text(' Â· ${service.ratingCount ?? 0}',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: mutedColor,
            ),
          ),
        ]),
      ]),
    );
  }
}

/// nest. price strip : grey rounded box - "Starts at" + price + "Pay after service" (updated design)
class NestDetailPriceStrip extends StatelessWidget {
  final double lowestPrice;
  final Discount discount;
  const NestDetailPriceStrip({super.key, required this.lowestPrice, required this.discount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF171717) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Starts at', style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: mutedColor,
            )),
            const SizedBox(height: 3),
            if ((discount.discountAmount ?? 0) > 0)
              Text(PriceConverter.convertPrice(lowestPrice, isShowLongPrice: true),
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  decoration: TextDecoration.lineThrough,
                  color: mutedColor,
                )),
            Text(PriceConverter.convertPrice(
              lowestPrice,
              discount: discount.discountAmount?.toDouble() ?? 0.0,
              discountType: discount.discountAmountType ?? 'amount',
            ),
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              )),
          ]),
          Text('pay_after_service'.tr,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: mutedColor,
            ),
          ),
        ]),
      ),
    );
  }
}

/// About section (updated design)
class NestDetailAbout extends StatelessWidget {
  final String description;
  const NestDetailAbout({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('about_me'.tr,
          style: GoogleFonts.manrope(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 10),
        ReadMoreText(
          description,
          trimCollapsedText: "see_more".tr,
          trimExpandedText: "  ${"see_less".tr}",
          trimMode: TrimMode.Line,
          trimLines: 3,
          style: GoogleFonts.dmSans(
            color: mutedColor,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          moreStyle: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primaryColor),
          lessStyle: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primaryColor),
        ),
      ]),
    );
  }
}

/// nest. warranty note - hatrline border card (updated design)
class NestDetailWarranty extends StatelessWidget {
  const NestDetailWarranty({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF171717) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);
    final iconBgColor = isDark ? const Color(0xFF262626) : const Color(0xFFF6F6F6);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: bgColor,
          border: Border.all(color: borderColor),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_outlined, size: 20,
              color: primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Service warranty', style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            )),
            const SizedBox(height: 3),
            Text('If something isn\'t right within 7 days, we\'ll send a pro back at no extra cost.',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: mutedColor,
              )),
          ])),
        ]),
      ),
    );
  }
}

/// Photos & Videos gallery grid
class NestDetailGallery extends StatelessWidget {
  final List<String> images;
  final ScrollController scrollController;
  const NestDetailGallery(
      {super.key, required this.images, required this.scrollController});

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
                Get.dialog(NestGalleryFullViewDialog(images: images)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('see_all'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 15,
                color: Theme.of(context).textTheme.bodyLarge!.color),
            ]),
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
                  NestGalleryFullViewDialog(
                      images: images, inttialIndex: index)),
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
class NestDetailReviews extends StatefulWidget {
  final String serviceId;
  final ScrollController scrollController;
  const NestDetailReviews(
      {super.key, required this.serviceId, required this.scrollController});

  @override
  State<NestDetailReviews> createState() => _NestDetailReviewsState();
}

class _NestDetailReviewsState extends State<NestDetailReviews> {
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
                Icon(Icons.star_rounded,
                    color: Theme.of(context).textTheme.bodyLarge!.color, size: 18),
                const SizedBox(width: Dimensions.paddingSizeMint),
                Flexible(
                  child: Text(
                    '${serviceTabController.rating.averageRating?.toStringAsFixed(1) ?? '0.0'} (${serviceTabController.rating.ratingCount ?? 0} ${'reviews'.tr})',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
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
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('see_all'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, size: 15,
                  color: Theme.of(context).textTheme.bodyLarge!.color),
              ]),
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

/// nest. bottom bar - single black "Book now Â· price" CTA (reference footer style) (updated design)
class NestDetailBottomBar extends StatelessWidget {
  final Service service;
  final double lowestPrice;
  const NestDetailBottomBar({super.key, required this.service, required this.lowestPrice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: bgColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
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
            child: Text(
              'Book now',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: bgColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full gallery view dialog
class NestGalleryFullViewDialog extends StatelessWidget {
  final List<String> images;
  final int inttialIndex;
  const NestGalleryFullViewDialog(
      {super.key, required this.images, this.inttialIndex = 0});

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
              initialPage: inttialIndex,
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



