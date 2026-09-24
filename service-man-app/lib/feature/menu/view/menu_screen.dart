import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigModel? configModel = Get.find<SplashController>().configModel;

    final List<MenuModel> menuList = [
      MenuModel(icon: Icons.person_outline_rounded, title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
      MenuModel(icon: Icons.language_rounded, title: 'language'.tr, route: RouteHelper.getLanguageRoute()),
      MenuModel(icon: Icons.chat_bubble_outline_rounded, title: 'inbox'.tr, route: RouteHelper.getInboxScreenRoute()),

      ...(configModel?.content?.businessPages ?? []).map((page) => MenuModel(
        icon: page.pageKey == HtmlType.aboutUs.value
            ? Icons.info_outline_rounded
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
            ? 'terms_conditions'.tr
            : page.pageKey == HtmlType.privacyPolicy.value
            ? 'privacy_policy'.tr
            : page.pageKey == HtmlType.cancellationPolicy.value
            ? 'cancellation_policy'.tr
            : page.pageKey == HtmlType.refundPolicy.value
            ? 'refund_policy'.tr
            : page.title ?? '',
        route: RouteHelper.getHtmlRoute(page.pageKey!),
      )),

      MenuModel(icon: Icons.logout_rounded, title: 'logout'.tr, route: RouteHelper.signIn),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuList.length,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemBuilder: (context, index) {
                final menu = menuList[index];
                final isLogout = index == menuList.length - 1;

                return InkWell(
                  onTap: () async {
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
                      Get.bottomSheet(const ChooseLanguageBottomSheet(), backgroundColor: Colors.transparent, isScrollControlled: true);
                    } else {
                      Get.offNamed(menu.route!);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.06),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isLogout
                                ? Theme.of(context).colorScheme.error.withValues(alpha: 0.08)
                                : Theme.of(context).primaryColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            menu.icon as IconData,
                            size: 18,
                            color: isLogout
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            menu.title!,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: isLogout
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
