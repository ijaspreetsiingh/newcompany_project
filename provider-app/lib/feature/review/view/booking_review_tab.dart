import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

/// Provider app booking details -> 3rd tab (Reviews):
/// is booking ke saare reviews (customer, rating, comment, serviceman).
class BookingReviewTab extends StatefulWidget {
  final String? bookingId;

  const BookingReviewTab({super.key, required this.bookingId});

  @override
  State<BookingReviewTab> createState() => _BookingReviewTabState();
}

class _BookingReviewTabState extends State<BookingReviewTab> {
  List<Review>? _reviews;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String bookingId = widget.bookingId ?? '';
    if (bookingId.isEmpty || bookingId == 'null') {
      setState(() => _reviews = []);
      return;
    }
    final List<Review> reviews = await Get.find<ReviewController>().getBookingReviews(bookingId);
    if (mounted) {
      setState(() => _reviews = reviews);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_reviews == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviews!.isEmpty) {
      return const Center(child: EmptyReviewWidget());
    }

    final double avgRating =
        _reviews!.map((review) => review.reviewRating ?? 0).reduce((a, b) => a + b) / _reviews!.length;

    return RefreshIndicator(
      color: Theme.of(context).primaryColorLight,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Row(children: [
              Text(avgRating.toStringAsFixed(1),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: List.generate(5, (index) {
                    return Icon(
                      index < avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 15,
                      color: index < avgRating.round()
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).hintColor,
                    );
                  })),
                  const SizedBox(height: 2),
                  Text('${_reviews!.length} ${'reviews'.tr}',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          ..._reviews!.map((review) => _BookingReviewTile(review: review)),
        ],
      ),
    );
  }
}

class _BookingReviewTile extends StatelessWidget {
  final Review review;

  const _BookingReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: review.isActive == 0
            ? Theme.of(context).disabledColor.withValues(alpha: Get.isDarkMode ? 0.3 : 0.1)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            child: CustomImage(
              height: 34, width: 34,
              image: review.customer?.profileImageFullPath ?? '',
              placeholder: Images.userPlaceHolder,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "${review.customer?.firstName ?? ''} ${review.customer?.lastName ?? ''}".trim().isEmpty
                    ? 'customer_not_available'.tr
                    : "${review.customer?.firstName ?? ''} ${review.customer?.lastName ?? ''}".trim(),
                style: robotoMedium.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 1),
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              if ((review.service?.name ?? '').isNotEmpty)
                Text(review.service!.name!,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
            ]),
          ),
          Row(children: [
            Icon(Icons.star_rounded, color: Theme.of(context).colorScheme.tertiary, size: 15),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text('${review.reviewRating ?? 0}',
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
            ),
          ]),
        ]),

        if ((review.reviewComment ?? '').isNotEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(review.reviewComment!,
            style: robotoRegular.copyWith(
              color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
              fontSize: Dimensions.fontSizeSmall + 1,
            ),
            textAlign: TextAlign.justify,
          ),
        ],

        if ((review.servicemanName ?? '').isNotEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(children: [
            Icon(Icons.person_outline_rounded, size: 14, color: Theme.of(context).hintColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text("${'serviceman'.tr}: ${review.servicemanName}",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}
