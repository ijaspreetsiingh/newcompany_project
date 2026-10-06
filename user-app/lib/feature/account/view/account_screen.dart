import 'package:get/get.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/util/core_export.dart';

/// nest. Account screen (reference: designnew AccountScreen)
/// simple title · theme-aware profile card · menu cards · logout · footer
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
        final ConfigModel configModel =
            Get.find<SplashController>().configModel;

        /// Group 1 — reference `accountItems`
        final List<Widget> accountRows = [
          NestMenuRow(
            icon: Icons.inbox_outlined,
            title: 'inbox'.tr,
            onTap: () => Get.toNamed(RouteHelper.getInboxScreenRoute()),
          ),
          NestMenuRow(
            icon: Icons.person_outline_rounded,
            title: 'profile'.tr,
            onTap: () => isLoggedIn
                ? Get.toNamed(RouteHelper.getProfileRoute())
                : Get.toNamed(RouteHelper.getSignInRoute()),
          ),
          NestMenuRow(
            icon: Icons.calendar_month_outlined,
            title: configModel.content?.guestCheckout == 0 || isLoggedIn
                ? 'bookings'.tr
                : "track_booking".tr,
            onTap: () => !isLoggedIn && configModel.content?.guestCheckout == 1
                ? Get.toNamed(RouteHelper.getTrackBookingRoute())
                : Get.toNamed(RouteHelper.getBookingScreenRoute(true)),
          ),
          NestMenuRow(
            icon: Icons.local_offer_outlined,
            title: 'offers'.tr,
            onTap: () => Get.toNamed(RouteHelper.getOffersRoute()),
          ),
          NestMenuRow(
            icon: Icons.confirmation_number_outlined,
            title: 'vouchers'.tr,
            onTap: () =>
                Get.toNamed(RouteHelper.getVoucherRoute(fromPage: 'account')),
          ),
          NestMenuRow(
            icon: Icons.favorite_border_rounded,
            title: 'my_favorite'.tr,
            onTap: () => Get.toNamed(RouteHelper.getMyFavoriteScreen()),
          ),
          if (configModel.content?.biddingStatus == 1)
            NestMenuRow(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'my_posts'.tr,
              onTap: () => Get.toNamed(RouteHelper.getMyPostScreen()),
            ),
          if (configModel.content!.walletStatus != 0 && isLoggedIn)
            NestMenuRow(
              icon: Icons.account_balance_wallet_outlined,
              title: 'my_wallet'.tr,
              onTap: () => Get.toNamed(RouteHelper.getMyWalletScreen()),
            ),
          if (configModel.content!.loyaltyPointStatus != 0 && isLoggedIn)
            NestMenuRow(
              icon: Icons.emoji_events_outlined,
              title: 'loyalty_point'.tr,
              onTap: () => Get.toNamed(RouteHelper.getLoyaltyPointScreen()),
            ),
          if (configModel.content?.referEarnStatus == 1)
            NestMenuRow(
              icon: Icons.card_giftcard_outlined,
              title: 'refer_and_earn'.tr,
              onTap: () => Get.toNamed(RouteHelper.getReferAndEarnScreen()),
            ),
          NestMenuRow(
            icon: Icons.language_outlined,
            title: 'language'.tr,
            onTap: () =>
                Get.toNamed(RouteHelper.getLanguageScreen('fromSettingsPage')),
          ),
          NestMenuRow(
            icon: Icons.settings_outlined,
            title: 'settings'.tr,
            onTap: () => Get.toNamed(RouteHelper.getSettingRoute()),
          ),
        ];

        /// Group 2 — reference second `.menu-card`
        final List<Widget> supportRows = [
          NestMenuRow(
            icon: Icons.map_outlined,
            title: 'service_area'.tr,
            onTap: () => Get.toNamed(RouteHelper.getServiceArea()),
          ),
          NestMenuRow(
            icon: Icons.support_agent_outlined,
            title: 'help_&_support'.tr,
            onTap: () => Get.toNamed(RouteHelper.getSupportRoute()),
          ),
          if (configModel.content?.providerSelfRegistration == 1)
            NestMenuRow(
              icon: Icons.handyman_outlined,
              title: 'become_a_provider'.tr,
              onTap: () => _openProvider(context),
            ),
          NestMenuRow(
            icon: Icons.info_outline_rounded,
            title: 'about_us'.tr,
            onTap: () => Get.toNamed(RouteHelper.getAboutUsRoute()),
          ),
          ...(configModel.content!.businessPages ?? [])
              .where((page) => page.pageKey != HtmlType.aboutUs.value)
              .map(
                (page) => NestMenuRow(
                  icon: Icons.shield_outlined,
                  title: _getPageTitle(page),
                  onTap: () {
                    final String route = _getPageRoute(page);
                    if (route.isNotEmpty) Get.toNamed(route);
                  },
                ),
              ),
        ];

        return Scaffold(
          backgroundColor: NestInk.background,
          body: FooterBaseView(
            isScrollView: true,
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: NestScreenBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// simple-title : "Account" + notifications icon button
                      NestBigTitle(
                        title: 'my_account'.tr,
                        action: NestRoundButton(
                          icon: Icons.notifications_none_rounded,
                          onTap: () =>
                              Get.toNamed(RouteHelper.getNotificationRoute()),
                        ),
                      ),

                      /// black profile card
                      _ProfileCard(isLoggedIn: isLoggedIn),
                      const SizedBox(height: 15),

                      NestMenuCard(children: accountRows),
                      NestMenuCard(children: supportRows),

                      /// logout — reference `.logout`
                      NestOutlineAction(
                        label: isLoggedIn ? 'logout'.tr : 'sign_in'.tr,
                        danger: isLoggedIn,
                        onTap: () => _handleLogout(isLoggedIn),
                      ),

                      /// footer
                      NestPageFooter(
                        text:
                            '${AppConstants.appName} · v${AppConstants.appVersion}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openProvider(BuildContext context) async {
    final String url = GetPlatform.isWeb
        ? '${AppConstants.baseUrl}/provider/auth/sign-up'
        : RouteHelper.getProviderWebView();
    if (url.startsWith('http') && await canLaunchUrlString(url)) {
      launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      Get.toNamed(url);
    }
  }

  void _handleLogout(bool isLoggedIn) {
    if (isLoggedIn) {
      Get.dialog(
        ConfirmationDialog(
          icon: Images.logoutIcon,
          title: 'are_you_sure_to_logout'.tr,
          description: "if_you_logged_out_your_cart_will_be_removed".tr,
          onYesPressed: () {
            Get.find<AuthController>().clearSharedData();
            Get.find<AuthController>().logOut();
            Get.find<AuthController>().googleLogout();
            Get.find<AuthController>().signOutWithFacebook();
            Get.find<LocationController>().updateSelectedAddress(null);
            Get.offAllNamed(RouteHelper.getinitialRoute());
          },
        ),
        useSafeArea: false,
      );
    } else {
      Get.toNamed(RouteHelper.getSignInRoute());
    }
  }

  String _getPageTitle(BusinessPage page) {
    return page.pageKey == HtmlType.aboutUs.value
        ? 'about_us'.tr
        : page.pageKey == HtmlType.termsAndCondition.value
        ? 'terms_and_conditions'.tr
        : page.pageKey == HtmlType.privacyPolicy.value
        ? 'privacy_policy'.tr
        : page.pageKey == HtmlType.cancellationPolicy.value
        ? 'cancellation_policy'.tr
        : page.pageKey == HtmlType.refundPolicy.value
        ? 'refund_policy'.tr
        : page.title ?? '';
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

/// Profile surface follows the active theme like the rest of the account page.
class _ProfileCard extends StatelessWidget {
  final bool isLoggedIn;
  const _ProfileCard({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    String userName = '';
    String? userImage;
    if (isLoggedIn) {
      final userInfo = Get.find<UserController>().userInfoModel;
      userName = '${userInfo?.fName ?? ''} ${userInfo?.lName ?? ''}'.trim();
      userImage = userInfo?.imageFullPath;
    }
    if (userName.isEmpty) userName = 'guest'.tr;

    final String initials = _initialsOf(userName);

    return InkWell(
      onTap: () => isLoggedIn
          ? Get.toNamed(RouteHelper.getProfileRoute())
          : Get.toNamed(RouteHelper.getSignInRoute()),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 105),
        margin: const EdgeInsets.only(top: 24, bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: NestInk.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: NestInk.border),
        ),
        child: Row(
          children: [
            (userImage ?? '').isNotEmpty
                ? ClipOval(
                    child: CustomImage(
                      image: userImage!,
                      height: 44,
                      width: 44,
                      fit: BoxFit.cover,
                      placeholder: Images.userPlaceHolder,
                    ),
                  )
                : Container(
                    height: 44,
                    width: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: NestInk.soft,
                    ),
                    child: Text(
                      initials,
                      style: NestInk.display(
                        size: 12,
                        weight: FontWeight.w800,
                        color: NestInk.primary,
                      ),
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NestInk.display(
                      size: 15,
                      weight: FontWeight.w800,
                      color: NestInk.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLoggedIn ? 'view_or_edit_profile'.tr : 'sign_in'.tr,
                    style: NestInk.body(size: 10, color: NestInk.mutedText),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: NestInk.mutedText,
            ),
          ],
        ),
      ),
    );
  }

  String _initialsOf(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
