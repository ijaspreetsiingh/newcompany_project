import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vertical list view for All Services - similar to "Popular near you" format
class AllServicesVerticalList extends StatelessWidget {
  final List<Service>? serviceList;

  const AllServicesVerticalList({super.key, required this.serviceList});

  @override
  Widget build(BuildContext context) {
    if (serviceList == null || serviceList!.isEmpty) {
      return const SizedBox();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
        ),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: List.generate(serviceList!.length, (index) {
          final isLast = index == serviceList!.length - 1;
          return Column(
            children: [
              AllServicesRow(service: serviceList![index]),
              if (!isLast)
                Divider(
                  height: 1,
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
                ),
            ],
          );
        }),
      ),
    );
  }
}

/// Individual service row for vertical list display
class AllServicesRow extends StatelessWidget {
  final Service service;

  const AllServicesRow({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

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
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            /// Service image
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

            /// Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Category
                  Text(
                    service.category?.name ?? 'Service',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 2),

                  /// Service name
                  Text(
                    service.name ?? '',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  /// Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: primaryColor,
                        fill: 1.0,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        (service.avgRating ?? 0).toStringAsFixed(2),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: mutedColor,
                        ),
                      ),
                      Text(
                        ' · ${service.ratingCount ?? 0}',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  /// Price
                  Row(
                    children: [
                      Text(
                        PriceConverter.convertPrice(lowestPrice.toDouble()),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        ' onwards',
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Arrow button
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_forward_outlined,
                  size: 18,
                  color: mutedColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
