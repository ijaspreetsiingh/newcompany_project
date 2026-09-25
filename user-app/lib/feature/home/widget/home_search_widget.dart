import 'package:jdds/helper/extension_helper.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class HomeSearchWidget extends StatelessWidget {
  const HomeSearchWidget({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return  SliverPersistentHeader(
      pinned: true,
      delegate: SliverDelegate(extentSize: 72,
        child: InkWell(

          onTap: () => Get.dialog(const SearchSuggestionDialog(), transitionCurve: Curves.easeIn),

          child: Padding(padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall,),
            child: Container(
              height: 52,
              padding: EdgeInsets.only(
                left: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeDefault : 0,
                right:   Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeDefault,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                boxShadow: Get.find<ThemeController>().darkTheme ? null : searchBoxShadow,
                border: Border.all(
                  color: context.customThemeColors.searchBarBorder,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                color: Theme.of(context).cardColor,
              ),
              child: Row( children: [

                Image.asset(Images.searchIcon, width: 20, height: 20,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Text('search_services'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                const Spacer(),

                /// Tune (filter) button - SS : right end par, divider ke saath, square rounded chip
                Container(height: 36, width: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(
                      color: Theme.of(context).primaryColorLight,
                      width: 1,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                  child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall - 2),
                    child: Icon(Icons.tune, size: 18, color: Theme.of(context).colorScheme.primary),
                  ),
                ),

              ]),
            ),
          ),
        ),
      ),
    );
  }
}


class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget? child;
  double? extentSize;
  SliverDelegate({required this.child,required this.extentSize});
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    /// Child ko exact header extent ke barabar stretch karna zaroori hai
    /// warna pinned header me paintExtent != layoutExtent -> invalid geometry crash
    return SizedBox(
      height: extentSize,
      width: double.infinity,
      child: child,
    );
  }
  @override
  double get maxExtent => extentSize!;
  @override
  double get minExtent => extentSize!;
  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != maxExtent || child != oldDelegate.child;
  }
}
