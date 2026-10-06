import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_bottom_sheet.dart';

/// nest. style header (reference: design_refrence/home-harmony-hub app-shell)
/// - Left  : black rounded square logo + brand name
/// - Right : bordered circular icon buttons
/// - Bottom: bordered location pill
class AddressAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? backButton;
  const AddressAppBar({super.key, this.backButton = true});
  @override
  Widget build(BuildContext context) {
    bool isloggedIn = Get.find<AuthController>().isLoggedIn();
    bool isDark = Get.isDarkMode;
    final Color borderColor = isDark
        ? Theme.of(context).primaryColorLight.withValues(alpha: 0.4)
        : Theme.of(context).shadowColor.withValues(alpha: 0.6);
    final Color foreground = Theme.of(context).textTheme.bodyLarge!.color!;

    String userName = '';
    if (isloggedIn) {
      final userInfo = Get.find<UserController>().userInfoModel;
      userName = '${userInfo?.fName ?? ''} ${userInfo?.lName ?? ''}'.trim();
    }
    if (userName.isEmpty) {
      userName = 'guest'.tr;
    }

    return AppBar(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      shape: Border(bottom: BorderSide(width: 0.6, color: borderColor)),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Row(children: [

          /// Brand - black rounded square with white home icon (nest. style)
          InkWell(
            onTap: () => Get.offAllNamed(RouteHelper.getinitialRoute()),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Row(children: [
              Container(
                height: 32, width: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault - 2),
                ),
                child: Icon(Icons.home_rounded, size: 17, color: isDark ? Colors.black : Colors.white),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                AppConstants.appName,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: foreground,
                  letterSpacing: -0.3,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
          const Spacer(),

          /// Notification - bordered circle button (nest. style)
          _HeaderCircleButton(
            icon: Icons.notifications_none_rounded,
            onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          /// Favorite - bordered circle button (nest. style)
          _HeaderCircleButton(
            icon: Icons.bookmark_border_rounded,
            onTap: () => Get.toNamed(RouteHelper.getMyFavoriteScreen()),
          ),
        ]),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall, Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
          child: InkWell(
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraMoreLarge),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              useRootNavigator: true,
              routeSettings: const RouteSettings(name: '/'),
              builder: (context) => const AddressSelectionBottomSheet(),
            ),
            child: GetBuilder<LocationController>(builder: (locationController) {
              return Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraMoreLarge),
                ),
                child: Row(children: [
                  Icon(Icons.location_on_outlined, color: foreground.withValues(alpha: 0.8), size: 16),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall + 1),
                  Expanded(
                    child: Text(
                      locationController.getUserAddress()?.address ?? 'set_location'.tr,
                      style: robotoMedium.copyWith(
                        color: foreground.withValues(alpha: 0.85),
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 18,
                    color: foreground.withValues(alpha: 0.4)),
                ]),
              );
            }),
          ),
        ),
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(108); // kToolbarHeight(56) + bottom(52)
}

/// Bordered circular icon button used in the header - nest. style
class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final Function() onTap;

  const _HeaderCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Get.isDarkMode;
    final Color borderColor = isDark
        ? Theme.of(context).primaryColorLight.withValues(alpha: 0.4)
        : Theme.of(context).shadowColor.withValues(alpha: 0.6);

    return InkWell(
      hoverColor: Colors.transparent,
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        height: 40, width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Icon(icon, size: 19, color: Theme.of(context).textTheme.bodyLarge!.color),
      ),
    );
  }
}



