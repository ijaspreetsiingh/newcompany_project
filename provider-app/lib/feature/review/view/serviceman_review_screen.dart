import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

/// Provider app ki nayi screen:
/// - Top serviceman + Lowest serviceman
/// - Har serviceman ki rating + review count (ranking)
/// - Ek jagah saare reviews jo provider ke servicemen ko mile hain
class ServicemanReviewScreen extends StatefulWidget {
  const ServicemanReviewScreen({super.key});

  @override
  State<ServicemanReviewScreen> createState() => _ServicemanReviewScreenState();
}

class _ServicemanReviewScreenState extends State<ServicemanReviewScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<ReviewController>().getServicemanRatings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'serviceman_reviews'.tr),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColorLight,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () => Get.find<ReviewController>().getServicemanRatings(),
        child: GetBuilder<ReviewController>(
          builder: (reviewController) {
            if (reviewController.servicemenRatingList == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<ServicemanRatingItem> servicemen = reviewController.servicemenRatingList ?? [];
            final List<Review> allReviews = reviewController.servicemanReviewsList ?? [];

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReviewHeading(rating: reviewController.servicemanOverallRating, showTitle: true),
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                        ReviewLinearChart(
                          rating: reviewController.servicemanOverallRating ??
                              Rating(ratingCount: 0, averageRating: 0, ratingGroupCount: []),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        Divider(height: 0.5, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        if (servicemen.isEmpty)
                          const EmptyReviewWidget()
                        else ...[
                          Row(children: [
                            Expanded(child: _topLowestCard(
                              context: context,
                              title: 'top_serviceman'.tr,
                              icon: Icons.workspace_premium_rounded,
                              serviceman: reviewController.topServiceman,
                              color: Theme.of(context).colorScheme.primary,
                            )),
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                            Expanded(child: _topLowestCard(
                              context: context,
                              title: 'lowest_serviceman'.tr,
                              icon: Icons.trending_down_rounded,
                              serviceman: reviewController.lowestServiceman,
                              color: Theme.of(context).colorScheme.error,
                            )),
                          ]),

                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Text('all_servicemen'.tr,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          ...List.generate(servicemen.length, (index) =>
                              _servicemanRankingCard(context, index + 1, servicemen[index])),

                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Divider(height: 0.5, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Text('all_reviews'.tr,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          if (allReviews.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                                child: Text('no_review_yet'.tr, style: robotoLight),
                              ),
                            )
                          else
                            ...allReviews.map((review) => ReviewItem(
                              review: review,
                              backgroundColor: Theme.of(context).cardColor,
                            )),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topLowestCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required ServicemanRatingItem? serviceman,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: serviceman == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: color)),
                const SizedBox(height: 4),
                Text('not_available'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Expanded(child: Text(title,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: color),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  )),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(serviceman.name ?? '',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.star_rounded, color: Theme.of(context).colorScheme.tertiary, size: 16),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text('${(serviceman.averageRating ?? 0).toStringAsFixed(1)} / 5',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                ]),
                const SizedBox(height: 2),
                Text('${serviceman.ratingCount ?? 0} ${'ratings'.tr}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _servicemanRankingCard(BuildContext context, int rank, ServicemanRatingItem serviceman) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(children: [
        Container(
          height: 28, width: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: rank <= 3 ? Theme.of(context).colorScheme.tertiary : Theme.of(context).disabledColor,
            shape: BoxShape.circle,
          ),
          child: Text('$rank',
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: rank <= 3 ? Colors.white : Theme.of(context).hintColor,
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          child: CustomImage(
            height: 36, width: 36,
            image: serviceman.profileImage ?? '',
            placeholder: Images.userPlaceHolder,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(serviceman.name ?? '',
              style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 1)),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            Text('${serviceman.ratingCount ?? 0} ${'ratings'.tr} • ${serviceman.reviewCount ?? 0} ${'reviews'.tr}',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
          ]),
        ),
        Row(children: [
          Icon(Icons.star_rounded, color: Theme.of(context).colorScheme.tertiary, size: 16),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text((serviceman.averageRating ?? 0).toStringAsFixed(1),
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ]),
      ]),
    );
  }
}
