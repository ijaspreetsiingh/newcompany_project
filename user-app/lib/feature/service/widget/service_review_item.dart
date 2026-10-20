import 'package:jdds/common/widgets/ldashed_line_printer.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';

class ServiceReviewItem extends StatelessWidget {
  final Review review;
  final bool isProviderReview;
  final int index;
  const ServiceReviewItem({
    super.key,
    required this.review,
    required this.isProviderReview,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final hintColor = Theme.of(context).hintColor;
    final bodyColor = Theme.of(context).textTheme.bodyLarge!.color!;

    // Whether this review has a serviceman who carried it out
    final bool hasServiceman =
        (review.servicemanName?.isNotEmpty ?? false);

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E5E5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Customer row ────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge),
                child: CustomImage(
                  image: review.customer?.profileImageFullPath ?? '',
                  height: 40,
                  width: 40,
                  placeholder: Images.userPlaceHolder,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customer == null
                          ? 'customer_not_available'.tr
                          : '${review.customer?.firstName ?? ''} ${review.customer?.lastName ?? ''}'.trim(),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: bodyColor.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(children: [
                      RatingBar(
                        rating: review.reviewRating!.toDouble(),
                        color: primaryColor,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        review.reviewRating!.toStringAsFixed(1),
                        style: robotoMedium.copyWith(
                          color: hintColor,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                DateConverter.dateStringMonthYear(
                    DateConverter.isoUtcStringToLocalDate(review.updatedAt!)),
                style: robotoRegular.copyWith(
                  color: hintColor,
                  fontSize: Dimensions.fontSizeSmall + 1,
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),

          // ── Serviceman chip ─────────────────────────────────────────────
          if (hasServiceman) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomImage(
                  image: review.servicemanImage ?? '',
                  height: 24,
                  width: 24,
                  placeholder: Images.userPlaceHolder,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${'serviceman'.tr}: ',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: hintColor,
                ),
              ),
              Flexible(
                child: Text(
                  review.servicemanName!,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: bodyColor.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ],

          // ── Review comment ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(
              top: Dimensions.paddingSizeDefault,
              bottom: Dimensions.paddingSizeEight,
            ),
            child: ReadMoreText(
              review.reviewComment?.capitalizeFirst ?? '',
              trimCollapsedText: 'see_more'.tr,
              trimExpandedText: '  ${"see_less".tr}',
              trimMode: TrimMode.Line,
              trimLines: 3,
              style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                fontSize: Dimensions.fontSizeSmall,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
              moreStyle: robotoMedium.copyWith(color: primaryColor),
              lessStyle: robotoMedium.copyWith(color: primaryColor),
            ),
          ),

          // ── Provider reply ──────────────────────────────────────────────
          if (review.reviewReply != null && review.isExpended == 1)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              CustomPaint(
                size: const Size(15, 50),
                painter: LDashedLinePainter(),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: primaryColor.withValues(alpha: 0.04),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(children: [
                              Image.asset(Images.reviewReply, width: 25),
                              const SizedBox(width: Dimensions.paddingSizeEight),
                              ResponsiveHelper.isDesktop(context)
                                  ? Text(
                                      'replied_by_provider'.tr,
                                      style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'replied_by_provider'.tr,
                                            style: robotoRegular.copyWith(
                                                fontSize: Dimensions.fontSizeDefault),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (review.provider != null &&
                                              !ResponsiveHelper.isDesktop(context))
                                            TextButton(
                                              onPressed: () => Get.toNamed(
                                                  RouteHelper.getProviderDetails(
                                                      review.provider!.id!)),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(60, 20),
                                                tapTargetSize:
                                                    MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: Text(
                                                review.provider?.companyName ?? '',
                                                style: robotoRegular.copyWith(
                                                  decoration: TextDecoration.underline,
                                                  color: primaryColor,
                                                  fontSize: Dimensions.fontSizeSmall,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                              if (review.provider != null &&
                                  ResponsiveHelper.isDesktop(context))
                                TextButton(
                                  onPressed: () => Get.toNamed(
                                      RouteHelper.getProviderDetails(review.provider!.id!)),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 30),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Row(children: [
                                    const Text(' - '),
                                    Text(
                                      review.provider?.companyName ?? '',
                                      style: robotoRegular.copyWith(
                                        decoration: TextDecoration.underline,
                                        color: Get.isDarkMode
                                            ? bodyColor
                                            : primaryColor,
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),
                                  ]),
                                ),
                            ]),
                          ),
                          Text(
                            DateConverter.dateStringMonthYear(
                                DateConverter.isoUtcStringToLocalDate(
                                    review.reviewReply!.updatedAt!)),
                            style: robotoRegular.copyWith(
                              color: hintColor,
                              fontSize: Dimensions.fontSizeSmall + 1,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      ReadMoreText(
                        review.reviewReply?.reply?.capitalizeFirst ?? '',
                        trimCollapsedText: 'see_more'.tr,
                        trimExpandedText: '  ${"see_less".tr}',
                        trimMode: TrimMode.Line,
                        trimLines: 3,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.6),
                          fontSize: Dimensions.fontSizeSmall,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                        moreStyle: robotoMedium.copyWith(color: primaryColor),
                        lessStyle: robotoMedium.copyWith(color: primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ])
          else if (review.reviewReply != null && review.isExpended == 0)
            InkWell(
              onTap: () {
                if (isProviderReview) {
                  Get.find<ProviderBookingController>()
                      .updateProviderReviewExpendedStatus(index: index);
                } else {
                  Get.find<ServiceTabController>()
                      .updateProviderReviewExpendedStatus(index: index);
                }
              },
              child: Text(
                'view_reply'.tr,
                style: robotoMedium.copyWith(
                  color: primaryColor,
                  fontSize: Dimensions.fontSizeDefault - 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
