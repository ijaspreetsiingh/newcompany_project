import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool centerTitle;
  final Function()? onBackPressed;
  final Widget? actionWidget;
  final double? elevation;
  final Color? bgColor;
  final bool isBackButtonExist;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.onBackPressed,
    this.actionWidget,
    this.subtitle,
    this.elevation,
    this.bgColor,
    this.isBackButtonExist = true,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Get.isDarkMode;
    final Color softFill = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);

    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: bgColor ?? (isDark ? Theme.of(context).cardColor.withValues(alpha: 0.2) : Theme.of(context).scaffoldBackgroundColor),
      centerTitle: false,
      shape: Border(
        bottom: BorderSide(
          width: 0.5,
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
        ],
      ),
      leading: isBackButtonExist
          ? Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              child: Center(
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: softFill,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      hoverColor: Colors.transparent,
                      splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      onTap: () => onBackPressed != null
                          ? onBackPressed!()
                          : Navigator.of(context).canPop()
                              ? Navigator.pop(context)
                              : Get.offAllNamed(RouteHelper.getInitialRoute()),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 17,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(),
      actions: actionWidget != null
          ? [actionWidget!]
          : [
              Container(
                height: 38,
                width: 38,
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: softFill,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ],
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 55);
}
