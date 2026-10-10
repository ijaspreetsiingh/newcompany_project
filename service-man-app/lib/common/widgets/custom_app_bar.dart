import 'package:jassdbx_serviceman/utils/core_export.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: context.kBackground,
        border: showDivider
            ? Border(bottom: BorderSide(color: context.kBorder, width: 1))
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
          child: Row(
            children: [
              KIconButton(
                icon: Icons.arrow_back_rounded,
                color: context.kForeground,
                onTap: onBackPressed ??
                    () {
                      if (Navigator.canPop(context)) {
                        Get.back();
                      } else {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      }
                    },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: centerTitle
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoBold.copyWith(
                        fontSize: 20,
                        color: context.kForeground,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: context.kMutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (title == 'my_profile'.tr)
                KIconButton(
                  icon: Icons.edit_outlined,
                  iconSize: 18,
                  color: context.kForeground,
                  onTap: () => Get.toNamed(RouteHelper.profileInformation),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size(double.maxFinite, showDivider ? 85 : 84);
}
