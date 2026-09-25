import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';


class BannerView extends StatelessWidget {
  const BannerView({super.key});

  /// Local fallback banners: shown only until admin banners load / if none exist
  static const List<String> _localBanners = [
    'assets/1.png',
    'assets/2.png',
    'assets/3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(
      builder: (bannerController) {
        final List<BannerModel> adminBanners = (bannerController.banners ?? [])
            .where((banner) => (banner.bannerImageFullPath ?? '').isNotEmpty)
            .toList();

        /// Admin banners jab tak nahi aaye ya na hon, local banners dikhao
        final bool useAdminBanners = adminBanners.isNotEmpty;
        final int totalBanners = useAdminBanners ? adminBanners.length : _localBanners.length;

        /// Admin-controlled auto slide duration (seconds), fallback 5s
        final int autoSlideSeconds = Get.find<SplashController>()
                .configModel
                .content
                ?.bannerAutoSlideDuration ??
            5;

        final int currentIndex = (bannerController.currentIndex ?? 0).clamp(0, totalBanners - 1);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
          child: SizedBox(
            height: ResponsiveHelper.isTab(context) || MediaQuery.of(context).size.width > 450 ? 390 : (MediaQuery.of(context).size.width * 0.50) + 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(children: [
                    CarouselSlider.builder(
                      options: CarouselOptions(
                        enableInfiniteScroll: totalBanners > 1,
                        autoPlay: totalBanners > 1,
                        autoPlayInterval: Duration(seconds: autoSlideSeconds < 1 ? 5 : autoSlideSeconds),
                        autoPlayAnimationDuration: const Duration(milliseconds: 600),
                        autoPlayCurve: Curves.easeInOut,
                        enlargeCenterPage: true,
                        viewportFraction: 0.88,
                        disableCenter: false,
                        onPageChanged: (index, reason) {
                          bannerController.setCurrentIndex(index, true);
                        },
                      ),
                      itemCount: totalBanners,
                      itemBuilder: (context, index, _) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                            child: SizedBox.expand(
                              /// BoxFit.contain => poori image complete dikhe, crop nahi hogi
                              child: useAdminBanners
                                  ? InkWell(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                      onTap: () => _onBannerTap(bannerController, adminBanners[index]),
                                      child: CustomImage(
                                        image: adminBanners[index].bannerImageFullPath,
                                        fit: BoxFit.contain,
                                        height: double.infinity,
                                        width: double.infinity,
                                      ),
                                    )
                                  : Image.asset(
                                      _localBanners[index],
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                      errorBuilder: (_, _, _) => Container(
                                        color: Theme.of(context).cardColor,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 40,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),

                    /// Dots indicator
                    if (totalBanners > 1)
                      Positioned(
                        left: 0, right: 0, bottom: Dimensions.paddingSizeSmall,
                        child: Center(
                          child: AnimatedSmoothIndicator(
                            activeIndex: currentIndex,
                            count: totalBanners,
                            effect: ExpandingDotsEffect(
                              dotHeight: 7,
                              dotWidth: 7,
                              spacing: 5,
                              activeDotColor: Theme.of(context).colorScheme.primary,
                              dotColor: Theme.of(context).cardColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onBannerTap(BannerController bannerController, BannerModel banner) {
    bannerController.navigateFromBanner(
      banner.resourceType ?? '',
      banner.id ?? '',
      banner.redirectLink ?? '',
      banner.resourceId ?? '',
      categoryName: banner.category?.name ?? '',
    );
  }
}
