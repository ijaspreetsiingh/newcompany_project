import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/design_system/nest_brand.dart';
import 'package:jdds/common/design_system/nest_icon_button.dart';
import 'package:google_fonts/google_fonts.dart';

/// nest. style widgets (reference: designnew - updated design system)
/// Greeting + big heading, black "Most booked" hero, "Popular near you" rows, trust badges.

class NestGreetingHeader extends StatelessWidget {
  const NestGreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final String greeting = hour < 12
        ? 'good_morning'.tr
        : hour < 17 ? 'good_afternoon'.tr : 'good_evening'.tr;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF0D0D0D) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeDefault, 6,
          Dimensions.paddingSizeDefault, 0,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GetBuilder<LocationController>(builder: (locationController) {
            final address = locationController.getUserAddress()?.address?.trim();
            final locationLabel = address == null || address.isEmpty
                ? 'set_location'.tr
                : address;
            return InkWell(
              onTap: () => EnableLocationPopup.show(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.location_on_outlined,
                    size: 16,
                    color: isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414),
                      )),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D)),
                ]),
              ),
            );
          }),
          Text(greeting, style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D),
          )),
          const SizedBox(height: 6),
          Text('What can we help\nwith today?',
            style: GoogleFonts.manrope(
              fontSize: 32, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -0.5,
              color: isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414),
            ),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
        ]),
      ),
    );
  }
}

/// nest. Home Header with Brand and Action Buttons
class NestHomeHeader extends StatelessWidget {
  const NestHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const NestBrand(fontSize: 22),
          Row(
            children: [
              Stack(
                children: [
                  NestIconButton(
                    icon: Icons.notifications_none_outlined,
                    onPressed: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                    tooltip: 'Notifications',
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? const Color(0xFFF1F1F1) 
                            : const Color(0xFF141414),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              NestIconButton(
                icon: Icons.favorite_border_outlined,
                onPressed: () => Get.toNamed(RouteHelper.getMyFavoriteScreen()),
                tooltip: 'Favorites',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Full-bleed admin banner images, sized to the existing home banner slot.
class NestHeroBanner extends StatelessWidget {
  final List<Service>? serviceList;
  const NestHeroBanner({super.key, required this.serviceList});

  @override
  Widget build(BuildContext context) {
    if (serviceList == null || serviceList!.isEmpty) {
      return const SizedBox();
    }

    final Service service = serviceList!.first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final double cardHeight = (cardWidth * 0.50)
            .clamp(184.0, 224.0)
            .toDouble();
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: () =>
                Get.toNamed(RouteHelper.getServiceRoute(service.slug ?? '')),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              height: cardHeight,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
              ),
              child: GetBuilder<BannerController>(
                builder: (bannerController) {
                  final adminImages = (bannerController.banners ?? [])
                      .map((banner) => banner.bannerImageFullPath?.trim() ?? '')
                      .where((image) => image.isNotEmpty)
                      .toList();

                  if (adminImages.isEmpty) {
                    return const SizedBox.expand();
                  }

                  final autoSlideSeconds = Get.find<SplashController>()
                          .configModel.content?.bannerAutoSlideDuration ??
                      5;

                  if (adminImages.length == 1) {
                    return CustomImage(
                      image: adminImages.first,
                      width: cardWidth,
                      height: cardHeight,
                      fit: BoxFit.cover,
                    );
                  }

                  return CarouselSlider.builder(
                    key: ValueKey(adminImages.join('|')),
                    itemCount: adminImages.length,
                    options: CarouselOptions(
                      height: cardHeight,
                      viewportFraction: 1,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayInterval: Duration(
                        seconds: autoSlideSeconds < 1 ? 5 : autoSlideSeconds,
                      ),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 750),
                      autoPlayCurve: Curves.easeInOutCubic,
                      scrollPhysics: const BouncingScrollPhysics(),
                    ),
                    itemBuilder: (context, index, _) => CustomImage(
                      image: adminImages[index],
                      width: cardWidth,
                      height: cardHeight,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// nest. "Popular near you" - vertical service rows (API data) - updated design
class NestPopularRows extends StatelessWidget {
  final List<Service>? serviceList;
  const NestPopularRows({super.key, required this.serviceList});

  @override
  Widget build(BuildContext context) {
    if (serviceList == null) {
      return const NestRowsShimmer();
    }
    if (serviceList!.isEmpty) {
      return const SizedBox();
    }

    final int count = serviceList!.length > 3 ? 3 : serviceList!.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Popular near you', style: GoogleFonts.manrope(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: primaryColor,
        )),
        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getSearchResultRoute(fromPage: "popular")),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('See all', style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            )),
            Icon(Icons.arrow_forward_rounded, size: 15,
              color: primaryColor),
          ]),
        ),
      ]),
      const SizedBox(height: 14),

      /// Service list with border (designnew style)
      Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
          ),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(children: List.generate(count, (index) {
          final isLast = index == count - 1;
          return Column(
            children: [
              NestServiceRow(service: serviceList![index]),
              if (!isLast)
                Divider(
                  height: 1,
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
                ),
            ],
          );
        })),
      ),
    ]);
  }
}

/// nest. ServiceRow : image left, name + rating + price, bookmark button (updated design)
class NestServiceRow extends StatelessWidget {
  final Service service;
  const NestServiceRow({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

    num lowestPrice = 0.0;
    if (service.variationsAppFormat?.zoneWiseVariations != null && service.variationsAppFormat!.zoneWiseVariations!.isNotEmpty) {
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
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomImage(
              image: (service.thumbnailFullPath ?? '').trim().isNotEmpty
                  ? service.thumbnailFullPath
                  : (service.coverImageFullPath ?? ''),
              height: 72,
              width: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          /// Name + rating + price
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(service.category?.name ?? 'Service',
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: mutedColor,
                )),
              const SizedBox(height: 2),
              Text(service.name ?? '',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.star_rounded, size: 12,
                  color: primaryColor, fill: 1.0),
                const SizedBox(width: 3),
                Text((service.avgRating ?? 0).toStringAsFixed(2),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: mutedColor,
                  )),
                Text(' Â· ${service.ratingCount ?? 0}',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: mutedColor,
                  )),
              ]),
              const SizedBox(height: 5),
              Row(children: [
                Text(PriceConverter.convertPrice(lowestPrice.toDouble()),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  )),
                Text(' onwards',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: mutedColor,
                  )),
              ]),
            ]),
          ),

          /// Bookmark button
          NestIconButton(
            icon: Icons.bookmark_border_outlined,
            onPressed: () {
              // TODO: Add to favorites logic
            },
            tooltip: 'Save',
          ),
        ]),
      ),
    );
  }
}

/// Compact, theme-aware trust badges.
class NestTrustBadges extends StatelessWidget {
  const NestTrustBadges({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF777777);
    final bgColor = isDark ? const Color(0xFF191919) : const Color(0xFFF8F8F8);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE6E6E6);
    final iconBgColor = isDark ? const Color(0xFF252525) : Colors.white;

    final List<Map<String, dynamic>> items = [
      {'icon': Icons.verified_user_outlined, 'title': 'Verified pros', 'desc': 'Background checked'},
      {'icon': Icons.local_offer_outlined, 'title': 'Upfront pricing', 'desc': 'No hidden charges'},
      {'icon': Icons.inventory_2_outlined, 'title': '7-day warranty', 'desc': "We've got you covered"},
      {'icon': Icons.support_agent_outlined, 'title': 'Real support', 'desc': 'Help when you need it'},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.34,
      ),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0 : 0.025),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: borderColor.withValues(alpha: 0.8)),
                ),
                child: Icon(
                  items[index]['icon'] as IconData,
                  size: 21,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                items[index]['title'] as String,
                style: GoogleFonts.dmSans(
                  fontSize: 14.5,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                items[index]['desc'] as String,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w400,
                  color: mutedColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Simple shimmer for the popular rows while API data loads
class NestRowsShimmer extends StatelessWidget {
  const NestRowsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 20, width: 150,
        decoration: BoxDecoration(
          color: Theme.of(context).shadowColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),
      Column(children: List.generate(3, (index) => Container(
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
    ]);
  }
}


