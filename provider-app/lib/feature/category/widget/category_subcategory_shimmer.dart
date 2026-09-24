import 'package:demandium_provider/util/core_export.dart';


class CategorySubcategoryShimmer extends StatelessWidget {
  const CategorySubcategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Hero banner shimmer
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall, Dimensions.paddingSizeDefault, 0,
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
              ),
            ),
          ),
        ),

        /// Categories title shimmer
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
          ),
          child: Row(
            children: [
              Container(
                height: 18, width: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Container(
                height: 16, width: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),

        /// Horizontal chips shimmer
        SizedBox(
          height: 86,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            itemCount: 6,
            itemBuilder: (context, index) => const CategoryItemShimmer(index: 0),
          ),
        ),

        /// Sub categories title shimmer
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
          ),
          child: Row(
            children: [
              Container(
                height: 18, width: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Container(
                height: 16, width: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),

        const Expanded(
          child: SubCategoryItemShimmer(),
        ),
      ],
    );
  }
}
