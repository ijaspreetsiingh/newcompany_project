import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void _onTap(BuildContext context, MenuModel menu, {required bool isLogout}) async {
    if (isLogout) {
      Get.back();
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.dialog(
          ConfirmationDialog(
            icon: Images.logout,
            title: 'are_you_sure_to_logout'.tr,
            onNoPressed: () => Get.back(),
            onYesPressed: () {
              Get.find<AuthController>().clearSharedData();
              Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
            },
            description: '',
          ),
          useSafeArea: false,
        );
      }
    } else if (menu.route!.contains('profile')) {
      Get.offNamed(RouteHelper.getProfileRoute());
    } else if (menu.route!.contains('language')) {
      Get.back();
      Get.bottomSheet(const ChooseLanguageBottomSheet(),
          backgroundColor: Colors.transparent, isScrollControlled: true);
    } else {
      Get.offNamed(menu.route!);
    }
  }

  List<MenuGroupItem> _groupItems(
      BuildContext context, List<MenuModel> items) {
    return items
        .map(
          (menu) => MenuGroupItem(
            icon: menu.icon as IconData,
            label: menu.title ?? '',
            onTap: () => _onTap(context, menu, isLogout: false),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel = Get.find<SplashController>().configModel;

    final List<MenuModel> accountItems = [
      MenuModel(
          icon: Icons.person_outline_rounded,
          title: 'profile'.tr,
          route: RouteHelper.getProfileRoute()),
      MenuModel(
          icon: Icons.language_rounded,
          title: 'language'.tr,
          route: RouteHelper.getLanguageRoute()),
      MenuModel(
          icon: Icons.mail_outline,
          title: 'inbox'.tr,
          route: RouteHelper.getInboxScreenRoute()),
      MenuModel(
          icon: Icons.replay_rounded,
          title: 'recheck_tasks'.tr,
          route: RouteHelper.getRecheckTasksRoute()),
    ];

    final List<MenuModel> legalItems =
        (configModel?.content?.businessPages ?? []).map((page) => MenuModel(
              icon: page.pageKey == HtmlType.aboutUs.value
                  ? Icons.description_outlined
                  : page.pageKey == HtmlType.termsAndCondition.value
                      ? Icons.description_outlined
                      : page.pageKey == HtmlType.privacyPolicy.value
                          ? Icons.privacy_tip_outlined
                          : page.pageKey == HtmlType.cancellationPolicy.value
                              ? Icons.cancel_outlined
                              : page.pageKey == HtmlType.refundPolicy.value
                                  ? Icons.replay_rounded
                                  : Icons.article_outlined,
              title: page.pageKey == HtmlType.aboutUs.value
                  ? 'about_us'.tr
                  : page.pageKey == HtmlType.termsAndCondition.value
                      ? 'terms'.tr
                      : page.pageKey == HtmlType.privacyPolicy.value
                          ? 'privacy_policy_title'.tr
                          : page.pageKey == HtmlType.cancellationPolicy.value
                              ? 'cancellation_policy'.tr
                              : page.pageKey == HtmlType.refundPolicy.value
                                  ? 'refund_policy'.tr
                                  : page.title ?? '',
              route: RouteHelper.getHtmlRoute(page.pageKey!),
            )).toList();

    final List<MenuModel> appItems = [
      MenuModel(
          icon: Icons.build_outlined,
          title: 'Service status'.tr,
          route: RouteHelper.getMaintenanceRoute()),
      MenuModel(
          icon: Icons.smartphone,
          title: 'App update'.tr,
          route: RouteHelper.getUpdateRoute(true)),
    ];

    final MenuModel logoutItem = MenuModel(
        icon: Icons.logout_rounded,
        title: 'logout'.tr,
        route: RouteHelper.signIn);

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Container(
        color: context.kPrimary.withValues(alpha: 0.4),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(height: 80),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.kBackground,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding:
                    const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'more'.tr,
                                    style: robotoBold.copyWith(
                                      fontSize: 24,
                                      color: context.kForeground,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'app_settings'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: 12,
                                      color: context.kMutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            KIconButton(
                              icon: Icons.close_rounded,
                              onTap: () => Get.back(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        MenuGroup(
                          title: 'settings'.tr,
                          items: _groupItems(context, accountItems),
                        ),
                        const SizedBox(height: 20),
                        if (legalItems.isNotEmpty) ...[
                          MenuGroup(
                            title: 'support'.tr,
                            items: _groupItems(context, legalItems),
                          ),
                          const SizedBox(height: 20),
                        ],
                        MenuGroup(
                          title: 'app'.tr,
                          items: _groupItems(context, appItems),
                        ),
                        const SizedBox(height: 24),
                        KButton(
                          label: 'log_out'.tr,
                          icon: Icons.logout_rounded,
                          outline: true,
                          destructive: true,
                          onTap: () =>
                              _onTap(context, logoutItem, isLogout: true),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
