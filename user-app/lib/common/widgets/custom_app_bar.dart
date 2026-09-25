import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subTitle;
  final bool? isBackButtonExist;
  final Function()? onBackPressed;
  final bool? showCart;
  final bool? centerTitle;
  final Color? bgColor;
  final Widget? actionWidget;
  final GlobalKey<CustomShakingWidgetState>?  shakeKey;
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

    return ResponsiveHelper.isDesktop(context) ?  WebMenuBar(searchbarShakeKey: shakeKey ) : AppBar(
      backgroundColor: isBackgroundTransparent
          ? Colors.transparent
          : bgColor ?? (isDark ? Theme.of(context).cardColor.withValues(alpha: .2) : Theme.of(context).scaffoldBackgroundColor),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      shape: Border(bottom: BorderSide(width: .4, color: Theme.of(context).primaryColorLight.withValues(alpha: .2))), elevation: 0,
      titleSpacing: 0,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color),),
          if(subTitle!=null) Text(subTitle!,style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).hintColor),),

        ],
      ),

      leading: isBackButtonExist! ? IconButton(
        hoverColor:Colors.transparent,
        icon: Icon(Icons.arrow_back_ios, color: isBackgroundTransparent ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge!.color),
        color: Theme.of(context).textTheme.bodyLarge!.color,
        onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.of(context).canPop() ? Navigator.pop(context) : Get.offAllNamed(RouteHelper.getInitialRoute()),
      ) : const SizedBox(),

      actions: showCart! ? [
        IconButton(
          onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
          icon: CartWidget(color: isDark ? Theme.of(context).primaryColorLight : const Color(0xFF333333), size: Dimensions.cartWidgetSize),
        )] : actionWidget != null ? [actionWidget!] : [
        /// Rounded outlined action button - SS-3 style
        Container(
          height: 36, width: 36,
          margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Theme.of(context).primaryColorLight.withValues(alpha: .3)
                  : const Color(0xFFE9EAEC),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.more_horiz, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
      ],
    );
  }
  @override
  Size get preferredSize => Size(Dimensions.webMaxWidth, ResponsiveHelper.isDesktop(Get.context) ? Dimensions.preferredSizeWhenDesktop : Dimensions.preferredSize );
}
