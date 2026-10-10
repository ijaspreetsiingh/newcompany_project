import 'dart:ui';

import 'package:get/get.dart';
import 'package:jassdbx_provider/feature/profile/model/provider_model.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  static const List<String> _groups = [
    'Business',
    'Operations',
    'Money',
    'Settings',
    'Legal',
  ];

  @override
  void initState() {
    super.initState();
    Get.find<UserProfileController>().getProviderInfo(reload: true);
  }

  bool get _subscriptionRequired => Get.isRegistered<UserProfileController>()
      ? Get.find<UserProfileController>().isSubscriptionRequired
      : true;

  /// Same menu structure & navigation targets as before — only the grouping
  /// label is added so rows can be rendered as the design's grouped lists.
  /// Entries with a custom [action] run it directly (moved here from Profile).
  List<_MenuEntry> _buildMenuEntries(bool isLoggedIn) {
    return [
      _MenuEntry(
        group: 'Business',
        menu: MenuModel(
          iconData: Icons.person_rounded,
          title: 'profile'.tr,
          route: RouteHelper.getProfileRoute(),
        ),
        action: null,
      ),
      _MenuEntry(
        group: 'Business',
        menu: MenuModel(
          iconData: Icons.edit_rounded,
          title: 'edit_profile'.tr,
          route: '',
        ),
        action: () => Get.to(() => const ProfileInformationScreen()),
      ),
      _MenuEntry(
        group: 'Business',
        menu: MenuModel(
          iconData: Icons.grid_view_rounded,
          title: 'all_services'.tr,
          route: '',
        ),
        action: () {
          final bool tutorialCurrentStatus =
              Get.find<UserProfileController>()
                  .providerModel
                  ?.content
                  ?.providerInfo!
                  .tutorialData?[AppConstants.serviceSubscriptionTutorialKey]
                  ?.contains('0') ??
              true;
          Get.to(
            () => AllServicesScreen(isTutorialActive: tutorialCurrentStatus),
          );
        },
      ),
      if (_subscriptionRequired)
        _MenuEntry(
          group: 'Business',
          menu: MenuModel(
            iconData: Icons.workspace_premium_rounded,
            title: 'mySubscription'.tr,
            route: RouteHelper.getMySubscriptionRoute(),
          ),
          action: null,
        ),
      _MenuEntry(
        group: 'Business',
        menu: MenuModel(
          iconData: Icons.tune_rounded,
          title: 'business_settings'.tr,
          route: '',
        ),
        action: () => Get.to(() => const BusinessSettingScreen()),
      ),
      _MenuEntry(
        group: 'Operations',
        menu: MenuModel(
          iconData: Icons.chat_bubble_rounded,
          title: 'chat'.tr,
          routeValidation: "chat",
          route: RouteHelper.getInboxScreenRoute(),
        ),
        action: null,
      ),
      _MenuEntry(
        group: 'Operations',
        menu: MenuModel(
          iconData: Icons.sync_alt_rounded,
          title: 'auto_assign_settings'.tr,
          route: '',
        ),
        action: () => Get.toNamed(RouteHelper.getAutoAssignSettingsRoute()),
      ),
      _MenuEntry(
        group: 'Operations',
        menu: MenuModel(
          iconData: Icons.star_rounded,
          title: 'reviews'.tr,
          route: '',
        ),
        action: () {
          Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial) {
            if (isTrial && Get.find<UserProfileController>().checkAvailableFeatureInSubscriptionPlan(featureType: 'review')) {
              Get.to(() => const ProviderReviewScreen());
            }
          });
        },
      ),
      _MenuEntry(
        group: 'Operations',
        menu: MenuModel(
          iconData: Icons.lightbulb_rounded,
          title: 'suggest_service'.tr,
          route: '',
        ),
        action: () {
          Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial) {
            if (isTrial && Get.find<UserProfileController>().checkAvailableFeatureInSubscriptionPlan(featureType: "service_request")) {
              Get.toNamed(RouteHelper.suggestService);
            }
          });
        },
      ),
      _MenuEntry(
        group: 'Settings',
        menu: MenuModel(
          iconData: Icons.settings_rounded,
          title: 'settings'.tr,
          route: RouteHelper.getLanguageBottomSheet('menu'),
        ),
        action: null,
      ),
      _MenuEntry(
        group: 'Money',
        menu: MenuModel(
          iconData: Icons.account_balance_wallet_rounded,
          title: 'payment_information'.tr,
          route: RouteHelper.getPaymentInformationRoute(),
        ),
        action: null,
      ),
      _MenuEntry(
        group: 'Money',
        menu: MenuModel(
          iconData: Icons.percent_rounded,
          title: 'commission'.tr,
          route: '',
        ),
        action: () => showCustomBottomSheet(child: const CommissionBottomSheet()),
      ),
      _MenuEntry(
        group: 'Money',
        menu: MenuModel(
          iconData: Icons.local_offer_rounded,
          title: 'promotional_cost'.tr,
          route: '',
        ),
        action: () => showCustomBottomSheet(child: const PromotionBottomSheet()),
      ),
      _MenuEntry(
        group: 'Settings',
        menu: MenuModel(
          iconData: Icons.notifications_rounded,
          title: 'notification_channel'.tr,
          route: RouteHelper.getNotificationScreen(),
        ),
        action: null,
      ),
      _MenuEntry(
        group: 'Money',
        menu: MenuModel(
          iconData: Icons.currency_exchange_rounded,
          title: 'withdraw_list'.tr,
          route: RouteHelper.transactions,
        ),
        action: null,
      ),
      _MenuEntry(
        group: 'Business',
        menu: MenuModel(
          iconData: Icons.insights_rounded,
          title: 'reports'.tr,
          routeValidation: "reports_&_analytics",
          route: RouteHelper.getReportingPageRoute('menu'),
        ),
        action: null,
      ),
      if (_subscriptionRequired)
        _MenuEntry(
          group: 'Business',
          menu: MenuModel(
            iconData: Icons.business_center_rounded,
            title: 'business_plan'.tr,
            route: RouteHelper.getBusinessPlanScreen(),
          ),
          action: null,
        ),
      _MenuEntry(
        group: 'Settings',
        menu: MenuModel(
          iconData: Icons.support_agent_rounded,
          title: 'help_&_support'.tr,
          route: RouteHelper.getHelpAndSupportScreen(),
        ),
        action: null,
      ),
      if (Get.find<SplashController>().configModel.content?.providerSlfDelete == 1)
        _MenuEntry(
          group: 'Settings',
          menu: MenuModel(
            iconData: Icons.delete_forever_rounded,
            title: 'delete_account'.tr,
            route: '',
          ),
          action: () => showCustomBottomSheet(child: const DeleteAccountBottomSheet()),
        ),
      ...(Get.find<SplashController>()
              .configModel
              .content!
              .businessPages ??
          [])
          .map(
            (page) => _MenuEntry(
              group: 'Legal',
              menu: MenuModel(
                iconData: page.pageKey == HtmlType.aboutUs.value
                    ? Icons.info_rounded
                    : page.pageKey == HtmlType.termsAndCondition.value
                    ? Icons.description_rounded
                    : page.pageKey == HtmlType.privacyPolicy.value
                    ? Icons.privacy_tip_rounded
                    : page.pageKey == HtmlType.cancellationPolicy.value
                    ? Icons.assignment_rounded
                    : page.pageKey == HtmlType.refundPolicy.value
                    ? Icons.replay_rounded
                    : Icons.article_rounded,
                title: page.pageKey == HtmlType.aboutUs.value
                    ? 'about_us'.tr
                    : page.pageKey == HtmlType.termsAndCondition.value
                    ? 'terms_and_conditions'.tr
                    : page.pageKey == HtmlType.privacyPolicy.value
                    ? 'privacy_policy'.tr
                    : page.pageKey == HtmlType.cancellationPolicy.value
                    ? 'cancellation_policy'.tr
                    : page.pageKey == HtmlType.refundPolicy.value
                    ? 'refund_policy'.tr
                    : page.title ?? '',
                route: RouteHelper.getHtmlRoute(page.pageKey!),
              ),
              action: null,
            ),
          ),
      _MenuEntry(
        group: '',
        menu: MenuModel(
          iconData: Icons.logout_rounded,
          title: isLoggedIn ? 'log_out'.tr : 'sign_in'.tr,
          route: RouteHelper.getSignInRoute("menu"),
        ),
        action: null,
      ),
    ];
  }

  Future<void> _onMenuTap(MenuModel menu, {VoidCallback? action}) async {
    if (action != null) {
      action();
      return;
    }
    if (menu.route!.startsWith('http')) {
      if (await canLaunchUrl(Uri.parse(menu.route!))) {
        launchUrl(Uri.parse(menu.route!));
      }
    } else if (menu.route!.contains('language')) {
      showCustomBottomSheet(child: const SettingBottomSheet());
    } else {
      if (menu.route == RouteHelper.businessPlan ||
          menu.route == RouteHelper.profile ||
          menu.route == RouteHelper.transactions ||
          menu.route!.contains(RouteHelper.html) ||
          menu.route == RouteHelper.mySubscription) {
        Get.toNamed(menu.route!);
      } else {
        Get.find<BusinessSubscriptionController>()
            .openTrialEndBottomSheet()
            .then((isTrial) {
              if (isTrial) {
                if ((menu.routeValidation != null &&
                        Get.find<UserProfileController>()
                            .checkAvailableFeatureInSubscriptionPlan(
                              featureType: menu.routeValidation!,
                            )) ||
                    menu.routeValidation == null) {
                  Get.toNamed(menu.route!);
                }
              }
            });
      }
    }
  }

  void _onLogout() {
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.dialog(
        ConfirmationDialog(
          icon: Images.logout,
          title: 'are_you_sure_to_logout'.tr,
          onNoPressed: () => Get.back(),
          onYesPressed: () {
            Get.find<AuthController>().clearSharedData();
            Get.find<UserProfileController>().clearUserProfileData();
            Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
          },
          description: '',
        ),
        barrierDismissible: true,
      );
    } else {
      Get.toNamed(RouteHelper.getSignInRoute("menu"));
    }
  }

  Widget _stickyHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: InkColors.background.withValues(alpha: 0.90),
        border:  Border(bottom: BorderSide(color: InkColors.border)),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'more'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: displayBold.copyWith(
                fontSize: 22,
                height: 1.15,
                color: InkColors.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _ownerName(ProviderInfo providerInfo) {
    final String name =
        '${providerInfo.owner?.firstName ?? ''} ${providerInfo.owner?.lastName ?? ''}'
            .trim();
    if (name.isNotEmpty) return name;
    return providerInfo.contactPersonName ?? '';
  }

  Widget _profileCard(ProviderInfo providerInfo, MenuModel profileMenu) {
    final String owner = _ownerName(providerInfo);
    final String? city = (providerInfo.companyAddress ?? '').trim().isEmpty
        ? null
        : providerInfo.companyAddress!.split(',').first.trim();
    final String meta = [
      if (owner.isNotEmpty) owner,
      if (city != null && city.isNotEmpty) city,
    ].join(' · ');
    final bool hasRating =
        (providerInfo.avgRating ?? 0) > 0 &&
        (providerInfo.ratingCount ?? 0) > 0;

    return InkCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _onMenuTap(profileMenu),
      child: Row(
        children: [
          InkAvatar(name: owner.isEmpty ? (providerInfo.companyName ?? '') : owner, size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  providerInfo.companyName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(
                    fontSize: 15,
                    height: 1.3,
                    color: InkColors.foreground,
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: 12,
                      height: 1.3,
                      color: InkColors.mutedForeground,
                    ),
                  ),
                ],
                if (hasRating) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                       Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: InkColors.foreground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        providerInfo.avgRating!.toStringAsFixed(2),
                        style: robotoSemiBold.copyWith(
                          fontSize: 11.5,
                          height: 1.3,
                          color: InkColors.foreground,
                        ),
                      ),
                      Text(
                        ' (${providerInfo.ratingCount})',
                        style: robotoRegular.copyWith(
                          fontSize: 11.5,
                          height: 1.3,
                          color: InkColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
           Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: InkColors.mutedForeground,
          ),
        ],
      ),
    );
  }

  /// InkRowLink draws a hairline at the bottom of every row — hide it on the
  /// last row of a group so only the card border remains (like the design).
  Widget _lastGroupRow(Widget child) {
    return Stack(
      children: [
        child,
         Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: InkColors.card),
          ),
        ),
      ],
    );
  }

  Widget _menuLeading(MenuModel menu) {
    return Container(
      height: 34,
      width: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: InkColors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(menu.iconData ?? Icons.chevron_right_rounded, size: 17, color: InkColors.foreground),
    );
  }

  Widget _groupSection(String title, List<_MenuEntry> entries) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: InkEyebrow(title),
          ),
          InkCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int index = 0; index < entries.length; index++)
                  index == entries.length - 1
                  ? _lastGroupRow(
                      InkRowLink(
                        title: entries[index].menu.title ?? '',
                        leading: _menuLeading(entries[index].menu),
                        onTap: () => _onMenuTap(
                          entries[index].menu,
                          action: entries[index].action,
                        ),
                      ),
                    )
                  : InkRowLink(
                      title: entries[index].menu.title ?? '',
                      leading: _menuLeading(entries[index].menu),
                      onTap: () => _onMenuTap(
                        entries[index].menu,
                        action: entries[index].action,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton(bool isLoggedIn) {
    return GestureDetector(
      onTap: _onLogout,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: InkColors.card,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: InkColors.destructive.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
              size: 16,
              color: InkColors.destructive,
            ),
            const SizedBox(width: 8),
            Text(
              isLoggedIn ? 'log_out'.tr : 'sign_in'.tr,
              style: robotoBold.copyWith(
                fontSize: 13.5,
                height: 1.2,
                color: InkColors.destructive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Scaffold(
      backgroundColor: InkColors.background,
      body: GetBuilder<UserProfileController>(
        builder: (userController) {
          final List<_MenuEntry> entries = _buildMenuEntries(isLoggedIn);

          final Map<String, List<_MenuEntry>> grouped = {
            for (final String group in _groups) group: [],
          };
          MenuModel? profileMenu;
          _MenuEntry? logoutMenu;

          for (final entry in entries) {
            if (entry.group.isEmpty) {
              logoutMenu = entry;
            } else {
              grouped[entry.group]!.add(entry);
              if (entry.menu.route == RouteHelper.getProfileRoute()) {
                profileMenu = entry.menu;
              }
            }
          }

          final ProviderInfo? providerInfo = userController
              .providerModel
              ?.content
              ?.providerInfo;

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _stickyHeader(),

                  if (providerInfo != null && profileMenu != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _profileCard(providerInfo, profileMenu),
                    ),

                  const SizedBox(height: 24),

                  for (final String group in _groups)
                    if (grouped[group]!.isNotEmpty)
                      _groupSection(group, grouped[group]!),

                  if (logoutMenu != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _logoutButton(isLoggedIn),
                    ),

                  const SizedBox(height: 14),

                  Center(
                    child: Text(
                      '${AppConstants.appName} · v${AppConstants.appVersion}',
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        height: 1.3,
                        color: InkColors.mutedForeground,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One row of the More menu — grouping label + the menu model + an optional
/// custom action (entries moved here from the Profile screen).
class _MenuEntry {
  final String group;
  final MenuModel menu;
  final VoidCallback? action;
  const _MenuEntry({required this.group, required this.menu, this.action});
}
