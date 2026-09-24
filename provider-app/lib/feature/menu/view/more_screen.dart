import 'package:get/get.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<UserProfileController>().getProviderInfo(reload: true);
  }

  IconData _iconFor(MenuModel menu, int index, int totalLength, bool isLogout) {
    if (menu.iconData != null) return menu.iconData!;
    if (isLogout || index == totalLength - 1) return Icons.logout_rounded;
    return Icons.circle_outlined;
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    final List<MenuModel> menuList = [
      MenuModel(
        iconData: Icons.person_rounded,
        title: 'profile'.tr,
        route: RouteHelper.getProfileRoute(),
      ),
      MenuModel(
        iconData: Icons.workspace_premium_rounded,
        title: 'mySubscription'.tr,
        route: RouteHelper.getMySubscriptionRoute(),
      ),
      MenuModel(
        iconData: Icons.chat_bubble_rounded,
        title: 'chat'.tr,
        routeValidation: "chat",
        route: RouteHelper.getInboxScreenRoute(),
      ),
      MenuModel(
        iconData: Icons.settings_rounded,
        title: 'settings'.tr,
        route: RouteHelper.getLanguageBottomSheet('menu'),
      ),
      MenuModel(
        iconData: Icons.account_balance_wallet_rounded,
        title: 'payment_information'.tr,
        route: RouteHelper.getPaymentInformationRoute(),
      ),
      MenuModel(
        iconData: Icons.notifications_rounded,
        title: 'notification_channel'.tr,
        route: RouteHelper.getNotificationScreen(),
      ),
      MenuModel(
        iconData: Icons.currency_exchange_rounded,
        title: 'withdraw_list'.tr,
        route: RouteHelper.transactions,
      ),
      MenuModel(
        iconData: Icons.insights_rounded,
        title: 'reports'.tr,
        routeValidation: "reports_&_analytics",
        route: RouteHelper.getReportingPageRoute('menu'),
      ),
      MenuModel(
        iconData: Icons.campaign_rounded,
        title: 'advertisements'.tr,
        routeValidation: "advertisement",
        route: RouteHelper.getAdvertisementListScreen(
          count:
              Get.find<DashboardController>()
                  .additionalInfoCount
                  ?.advertisementCount ??
              0,
        ),
      ),
      MenuModel(
        iconData: Icons.business_center_rounded,
        title: 'business_plan'.tr,
        route: RouteHelper.getBusinessPlanScreen(),
      ),
      MenuModel(
        iconData: Icons.support_agent_rounded,
        title: 'help_&_support'.tr,
        route: RouteHelper.getHelpAndSupportScreen(),
      ),

      ...(Get.find<SplashController>().configModel.content!.businessPages ?? [])
          .map(
            (page) => MenuModel(
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
          ),

      MenuModel(
        iconData: Icons.logout_rounded,
        title: isLoggedIn ? 'log_out'.tr : 'sign_in'.tr,
        route: RouteHelper.getSignInRoute("menu"),
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Text(
            'more'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ),
      ),
      body: GetBuilder<UserProfileController>(
        builder: (userController) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userController.providerModel?.content?.providerInfo != null)
                  _buildProfileHeader(context, userController),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                ...List.generate(menuList.length, (index) {
                  final bool isLogout = index == menuList.length - 1;
                  return _buildMenuItem(
                    context,
                    menuList[index],
                    isLogout,
                    _iconFor(menuList[index], index, menuList.length, isLogout),
                  );
                }),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "app_version".tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: " ${AppConstants.appVersion} ",
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserProfileController userController,
  ) {
    final providerInfo = userController.providerModel!.content!.providerInfo!;
    final Color primary = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeExtraSmall,
        Dimensions.paddingSizeDefault,
        0,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            Color.lerp(primary, const Color(0xFF1E40AF), 0.55)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -30,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CustomImage(
                    height: 58,
                    width: 58,
                    image: providerInfo.logoFullPath ?? "",
                    placeholder: Images.userPlaceHolder,
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerInfo.companyName ?? "",
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        providerInfo.companyPhone ??
                            providerInfo.companyEmail ??
                            "",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    MenuModel menu,
    bool isLogout,
    IconData icon,
  ) {
    final Color primary = Theme.of(context).primaryColor;
    final Color accentIcon = isLogout ? Colors.red : primary;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: isLogout
              ? Colors.red.withValues(alpha: 0.15)
              : Theme.of(context).hintColor.withValues(alpha: 0.08),
        ),
        boxShadow: context.customThemeColors.lightShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          onTap: () async {
            if (isLogout) {
              if (Get.find<AuthController>().isLoggedIn()) {
                Get.dialog(
                  ConfirmationDialog(
                    icon: Images.logout,
                    title: 'are_you_sure_to_logout'.tr,
                    onNoPressed: () => Get.back(),
                    onYesPressed: () {
                      Get.find<AuthController>().clearSharedData();
                      Get.find<UserProfileController>().clearUserProfileData();
                      Get.offAllNamed(
                        RouteHelper.getSignInRoute(RouteHelper.splash),
                      );
                    },
                    description: '',
                  ),
                  barrierDismissible: true,
                );
              } else {
                Get.toNamed(RouteHelper.getSignInRoute("menu"));
              }
            } else if (menu.route!.startsWith('http')) {
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
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall + 2,
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    gradient: isLogout
                        ? null
                        : LinearGradient(
                            colors: [
                              primary.withValues(alpha: 0.12),
                              Color.lerp(
                                primary,
                                const Color(0xFF1E40AF),
                                0.25,
                              )!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: isLogout ? Colors.red.withValues(alpha: 0.10) : null,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                  ),
                  child: Icon(icon, size: 21, color: accentIcon),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Text(
                    menu.title!,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: isLogout
                          ? Colors.red
                          : Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isLogout
                      ? Colors.red.withValues(alpha: 0.5)
                      : Theme.of(context).hintColor.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
