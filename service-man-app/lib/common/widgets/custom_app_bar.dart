import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final String? subtitle;
  final Function()? onBackPressed;
  final bool showDivider;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.onBackPressed,
    this.subtitle,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      centerTitle: centerTitle,
      leading: IconButton(
        onPressed: onBackPressed ??
            () {
              if (Navigator.canPop(context)) {
                Get.back();
              } else {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              }
            },
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).primaryColor,
            size: 16,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
      actions: [
        if (title == 'my_profile'.tr)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Get.toNamed(RouteHelper.profileInformation),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
      ],
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(
                height: 0.5,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size(double.maxFinite, showDivider ? 56 : 55);
}
