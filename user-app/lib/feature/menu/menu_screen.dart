import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<BottomNavController>().updateMenuPageIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    ConfigModel configModel = Get.find<SplashController>().configModel;

    /// Group 1 : account related items
    final List<MenuModel> accountMenuList = [
      MenuModel(icon: Images.profileIcon, title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
      MenuModel(icon: Images.translate, title: 'language'.tr, route: RouteHelper.getLanguageScreen('fromSettingsPage')),
      MenuModel(icon: Images.chatImage, title: 'inbox'.tr, route: RouteHelper.getInboxScreenRoute()),

      MenuModel(
        icon: Images.bookingsIcon,
        title: configModel.content?.guestCheckout == 0 || isLoggedIn ? 'bookings'.tr : "track_booking".tr,
        route: !isLoggedIn && configModel.content?.guestCheckout == 1
            ? RouteHelper.getTrackBookingRoute()
            : RouteHelper.getBookingScreenRoute(true),
      ),

      MenuModel(icon: Images.voucherIcon, title: 'vouchers'.tr, route: RouteHelper.getVoucherRoute(fromPage: 'menu')),
      MenuModel(icon: Images.myFavorite, title: 'my_favorite'.tr, route: RouteHelper.getMyFavoriteScreen()),

      if(configModel.content?.biddingStatus == 1)
        MenuModel(
          icon: Images.customPostIcon,
          title: 'my_posts'.tr,
          route: RouteHelper.getMyPostScreen(),
        ),

      if(configModel.content!.walletStatus != 0 && isLoggedIn)
        MenuModel(icon: Images.walletMenu, title: 'my_wallet'.tr, route: RouteHelper.getMyWalletScreen()),

      if(configModel.content!.loyaltyPointStatus != 0 && isLoggedIn)
        MenuModel(icon: Images.myPoint, title: 'loyalty_point'.tr, route: RouteHelper.getLoyaltyPointScreen()),

      if(Get.find<SplashController>().configModel.content?.referEarnStatus == 1)
        MenuModel(
          title: 'refer_and_earn'.tr,
          icon: Images.shareIcon,
          route: RouteHelper.getReferAndEarnScreen(),
        ),

      MenuModel(icon: Images.settings, title: 'settings'.tr, route: RouteHelper.getSettingRoute()),
    ];

    /// Group 2 : support and info items
    final List<MenuModel> supportMenuList = [
      MenuModel(icon: Images.areaMenuIcon, title: 'service_area'.tr, route: RouteHelper.getServiceArea()),
      MenuModel(icon: Images.helpIcon, title: 'help_&_support'.tr, route: RouteHelper.getSupportRoute()),

      if(configModel.content?.providerSelfRegistration == 1)
        MenuModel(icon: Images.providerImage, title: 'become_a_provider'.tr, route: GetPlatform.isWeb ? '${AppConstants.baseUrl}/provider/auth/sign-up' : RouteHelper.getProviderWebView()),

      MenuModel(icon: Images.aboutUs, title: 'about_us'.tr, route: RouteHelper.getAboutUsRoute()),

      ...(configModel.content!.businessPages ?? []).where((page) => page.pageKey != HtmlType.aboutUs.value).map((page) => MenuModel(
        icon: page.pageKey == HtmlType.termsAndCondition.value
            ? Images.termsIcon : page.pageKey == HtmlType.privacyPolicy.value
            ? Images.privacyPolicyIcon : page.pageKey == HtmlType.cancellationPolicy.value
            ? Images.cancellationPolicy : page.pageKey == HtmlType.refundPolicy.value ? Images.refundPolicy : Images.othersPageIcon,
        title: _getPageTitle(page),
        route: _getPageRoute(page),
      )),
    ];

    return PointerInterceptor(
      child: Container(
        width: Dimensions.webMaxWidth,
        margin: const EdgeInsets.only(top: 60),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
          color: Theme.of(context).cardColor,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          /// Drag handle - SS exact
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            height: 4, width: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Column(children: [

                /// Profile header card - SS layout (Image 2)
                _ProfileHeaderCard(isLoggedIn: isLoggedIn),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                /// Account group card - SS layout
                _MenuGroupCard(menuList: accountMenuList),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                /// Support & info group card - SS layout
                _MenuGroupCard(menuList: supportMenuList),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                /// Sign in / Sign out tile - SS layout
                _MenuTile(menu: MenuModel(
                  icon: Images.logout,
                  title: isLoggedIn ? 'logout'.tr : 'sign_in'.tr,
                  route: '',
                  isLogout: true,
                )),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ]),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ]),
      ),
    );
  }

  String _getPageTitle(BusinessPage page) {
    return page.pageKey == HtmlType.aboutUs.value
        ? 'about_us'.tr
        : page.pageKey == HtmlType.termsAndCondition.value
        ? 'terms_and_conditions'.tr : page.pageKey == HtmlType.privacyPolicy.value
        ? 'privacy_policy'.tr : page.pageKey == HtmlType.cancellationPolicy.value
        ? 'cancellation_policy'.tr : page.pageKey == HtmlType.refundPolicy.value ? 'refund_policy'.tr : page.title ?? '';
  }

  String _getPageRoute(BusinessPage page) {
    return page.pageKey == HtmlType.aboutUs.value
        ? RouteHelper.getAboutUsRoute()
        : page.pageKey == HtmlType.termsAndCondition.value
        ? RouteHelper.getTermsAndConditionsRoute()
        : page.pageKey == HtmlType.privacyPolicy.value
        ? RouteHelper.getPrivacyPolicyRoute()
        : page.pageKey == HtmlType.cancellationPolicy.value
        ? RouteHelper.getCancellationPolicyRoute()
        : page.pageKey == HtmlType.refundPolicy.value
        ? RouteHelper.getRefundPolicyRoute()
        : '';
  }
}

/// Profile header card - SS layout (Image 2) : avatar left, name + subtitle, chevron right
class _ProfileHeaderCard extends StatelessWidget {
  final bool isLoggedIn;
  const _ProfileHeaderCard({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    String userName = '';
    String? userImage;
    if (isLoggedIn) {
      final userInfo = Get.find<UserController>().userInfoModel;
      userName = '${userInfo?.fName ?? ''} ${userInfo?.lName ?? ''}'.trim();
      userImage = userInfo?.imageFullPath;
    }
    if (userName.isEmpty) {
      userName = 'guest'.tr;
    }

    return InkWell(
      onTap: () => isLoggedIn
          ? Get.offNamed(RouteHelper.getProfileRoute())
          : Get.toNamed(RouteHelper.getSignInRoute()),
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          border: isDark ? Border.all(color: Theme.of(context).primaryColorLight.withValues(alpha:0.15)) : null,
          boxShadow: Get.find<ThemeController>().darkTheme ? null : searchBoxShadow,
        ),
        child: Row(children: [

          /// Avatar - SS layout
          Container(
            height: 54, width: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withValues(alpha:0.12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CustomImage(
                image: userImage ?? '',
                height: 54, width: 54,
                fit: BoxFit.cover,
                placeholder: Images.userPlaceHolder,
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          /// Name + subtitle - SS layout
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(userName, style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('view_or_edit_profile'.tr, style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),

          Icon(Icons.arrow_forward_ios_rounded, size: 16,
            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.3),
          ),
        ]),
      ),
    );
  }
}

/// Grouped menu card - SS layout (Image 2) : soft white rounded card, icon chips + chevrons
class _MenuGroupCard extends StatelessWidget {
  final List<MenuModel> menuList;
  const _MenuGroupCard({required this.menuList});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        border: Get.isDarkMode ? Border.all(color: Theme.of(context).primaryColorLight.withValues(alpha:0.15)) : null,
        boxShadow: Get.find<ThemeController>().darkTheme ? null : searchBoxShadow,
      ),
      child: Column(children: List.generate(menuList.length, (index) {
        return _MenuTile(menu: menuList[index]);
      })),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final MenuModel menu;
  const _MenuTile({required this.menu});

  @override
  Widget build(BuildContext context) {
    final bool isLogout = menu.isLogout;
    final bool isDark = Get.isDarkMode;
    final Color accent = isLogout
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      onTap: () => _onTap(context, menu),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
        child: Row(children: [

          /// Soft rounded icon chip - SS exact
          Container(
            height: 44, width: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha:isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              menu.icon!,
              width: 22, height: 22,
              color: accent,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          /// Title
          Expanded(
            child: Text(
              menu.title!,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: isLogout
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),

          /// Chevron - SS exact
          Icon(Icons.arrow_forward_ios_rounded, size: 16,
            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.3),
          ),
        ]),
      ),
    );
  }

  void _onTap(BuildContext context, MenuModel menu) async {
    if(menu.isLogout) {
      Get.back();
      if(Get.find<AuthController>().isLoggedIn()) {
        Get.dialog(ConfirmationDialog(
            icon: Images.logoutIcon,
            title: 'are_you_sure_to_logout'.tr,
            description: "if_you_logged_out_your_cart_will_be_removed".tr,
            onYesPressed: () {
              Get.find<AuthController>().clearSharedData();
              Get.find<AuthController>().logOut();
              Get.find<AuthController>().googleLogout();
              Get.find<AuthController>().signOutWithFacebook();
              Get.find<LocationController>().updateSelectedAddress(null);
              Get.offAllNamed(RouteHelper.getInitialRoute());
            }), useSafeArea: false);
      }else {
        Get.toNamed(RouteHelper.getSignInRoute());
      }
    }
    else if(menu.route!.startsWith('http')) {
      if(await canLaunchUrlString(menu.route!)) {
        launchUrlString(menu.route!, mode: LaunchMode.externalApplication);
      }
    } else {
      if(menu.route!.contains('/language')){
        Get.back();
        Get.bottomSheet(const ChooseLanguageBottomSheet(), backgroundColor: Colors.transparent, isScrollControlled: true);
      } else {
        Get.offNamed(menu.route!);
      }
    }
  }
}
