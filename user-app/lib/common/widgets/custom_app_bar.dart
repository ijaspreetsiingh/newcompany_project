import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/util/core_export.dart';

/// nest. `.page-header` : 42px circular back Â· centered 18px title Â· 42px action
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subTitle;
  final bool? isBackButtonExist;
  final Function()? onBackPressed;
  final bool? showCart;
  final bool? centerTitle;
  final Color? bgColor;
  final Widget? actionWidget;
  final GlobalKey<CustomShakingWidgetState>? shakeKey;
  final bool isBackgroundTransparent;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isBackButtonExist = true,
    this.onBackPressed,
    this.showCart = false,
    this.centerTitle = true,
    this.bgColor,
    this.actionWidget,
    this.subTitle,
    this.shakeKey,
    this.isBackgroundTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Get.isDarkMode;

    return ResponsiveHelper.isDesktop(context)
        ? WebMenuBar(searchbarShakeKey: shakeKey)
        : AppBar(
            backgroundColor: isBackgroundTransparent
                ? Colors.transparent
                : bgColor ??
                    (isDark
                        ? Theme.of(context).cardColor.withValues(alpha: .2)
                        : Theme.of(context).scaffoldBackgroundColor),
            surfaceTintColor: Colors.transparent,
            centerTitle: centerTitle,
            elevation: 0,
            scrolledUnderElevation: 0,
            shape: const Border(),
            titleSpacing: 0,
            toolbarHeight: 56,
            title: Column(
              crossAxisAlignment: centerTitle == true
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                if (subTitle != null)
                  Text(
                    subTitle!,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
              ],
            ),

            /// 42px circular back button (nest. style)
            leadingWidth: 62,
            leading: isBackButtonExist!
                ? Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: NestRoundButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      iconSize: 17,
                      onTap: () => onBackPressed != null
                          ? onBackPressed!()
                          : Navigator.of(context).canPop()
                              ? Navigator.pop(context)
                              : Get.offAllNamed(RouteHelper.getinitialRoute()),
                    ),
                  )
                : const SizedBox(width: 62),

            actions: [
              if (showCart!)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: NestRoundButton(
                    icon: Icons.shopping_bag_outlined,
                    onTap: () => Get.toNamed(RouteHelper.getCartRoute()),
                    child: Center(
                      child: CartWidget(
                        color: isDark ? NestInk.primary : const Color(0xFF333333),
                        size: Dimensions.cartwidgetsize,
                      ),
                    ),
                  ),
                )
              else if (actionWidget != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: actionWidget!,
                ),

              /// reserved 42px action slot (grid balance)
              const SizedBox(width: 62),
            ],
          );
  }

  @override
  Size get preferredSize => Size(
        Dimensions.webMaxWidth,
        ResponsiveHelper.isDesktop(Get.context)
            ? Dimensions.preferredSizeWhenDesktop
            : Dimensions.preferredSize,
      );
}



