import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdds/common/design_system/nest_icon_button.dart';

class HomeSearchWidget extends StatelessWidget {
  const HomeSearchWidget({super.key}) ;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? const Color(0xFF262626) : const Color(0xFFF6F6F6);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

    return  SliverPersistentHeader(
      pinned: true,
      delegate: SliverDelegate(extentSize: 72,
        child: InkWell(

          onTap: () => Get.dialog(const SearchSuggestionDialog(), transitionCurve: Curves.easeIn),

          child: Container(
            color: isDark ? const Color(0xFF0D0D0D) : Colors.white,
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall,),
            child: Container(
              height: 52,
              padding: EdgeInsets.only(
                left: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeDefault : 0,
                right:   Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeDefault,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
                color: fillColor,
              ),
              child: Row( children: [

                Icon(Icons.search_outlined, size: 19, color: mutedColor),
                const SizedBox(width: 10),

                Text('search_services'.tr, style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: mutedColor,
                )),
                const Spacer(),

                /// Tune (filter) button - nest. style : soft dark-tinted rounded chip
                NestIconButton(
                  icon: Icons.tune,
                  onPressed: () {
                    // TODO: Open filter dialog
                  },
                  tooltip: 'Filter',
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


