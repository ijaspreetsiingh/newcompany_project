import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_bottom_sheet.dart';

class AddressAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? backButton;
  const AddressAppBar({super.key, this.backButton = true});
  @override
  Widget build(BuildContext context) {
    bool isloggedIn = Get.find<AuthController>().isLoggedIn();
    bool isDark = Get.isDarkMode;

    String greeting;
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = 'good_morning'.tr;
    } else if (hour < 17) {
      greeting = 'good_afternoon'.tr;
    } else {
      greeting = 'good_evening'.tr;
    }

    String userName = '';
    String? userImage;
    if (isloggedIn) {
      final userInfo = Get.find<UserController>().userInfoModel;
      userName = '${userInfo?.fName ?? ''} ${userInfo?.lName ?? ''}'.trim();
      userImage = userInfo?.imageFullPath;
    }
    if (userName.isEmpty) {
      userName = 'guest'.tr;
    }

    final Color iconColor = isDark ? Theme.of(context).primaryColorLight : const Color(0xFF333333);

    return AppBar(
      backgroundColor: isDark
          ? Theme.of(context).cardColor.withValues(alpha: .2)
          : Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Row(children: [

          /// Avatar - SS layout
          Container(
            height: 48, width: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CustomImage(
                image: userImage ?? '',
                height: 48, width: 48,
                fit: BoxFit.cover,
                placeholder: Images.userPlaceHolder,
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          /// Greeting + name - SS layout
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(greeting, style: robotoRegular.copyWith(
                color: isDark ? Theme.of(context).hintColor : const Color(0xFF7D848D),
                fontSize: Dimensions.fontSizeSmall,
              ), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(userName, style: robotoBold.copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: Dimensions.fontSizeExtraLarge,
              ), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),

          /// Notification circle button - SS layout
          _HeaderCircleButton(
            icon: Icons.notifications_none_rounded,
            iconSize: 20,
            iconColor: iconColor,
            onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          /// Favorite circle button - SS layout
          _HeaderCircleButton(
            icon: Icons.bookmark_border_rounded,
            iconSize: 18,
            iconColor: iconColor,
            onTap: () => Get.toNamed(RouteHelper.getMyFavoriteScreen()),
          ),
        ]),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
          child: InkWell(
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              useRootNavigator: true,
              routeSettings: const RouteSettings(name: '/'),
              builder: (context) => const AddressSelectionBottomSheet(),
            ),
            child: GetBuilder<LocationController>(builder: (locationController) {
              return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 18),
                const SizedBox(width: Dimensions.paddingSizeMini + 2),
                Expanded(
                  child: Text(
                    locationController.getUserAddress()?.address ?? 'set_location'.tr,
                    style: robotoMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .7),
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14,
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .3)),
              ]);
            }),
          ),
        ),
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(98);
}

/// Circular white icon button used in the header - SS layout
class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final Function() onTap;

  const _HeaderCircleButton({
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Get.isDarkMode;

    return InkWell(
      hoverColor: Colors.transparent,
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        height: 40, width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          boxShadow: Get.find<ThemeController>().darkTheme ? null : searchBoxShadow,
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
