import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';


class MenuButton extends StatelessWidget {
  final MenuModel? menu;
  final bool? isLogout;
  const MenuButton({super.key, required this.menu, required this.isLogout});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if(isLogout!) {
          Get.back();
          if(Get.find<AuthController>().isLoggedIn()) {
            Get.dialog(
              ConfirmationDialog(
                icon: Images.logout,
                title: 'are_you_sure_to_logout'.tr,
                onNoPressed: () {
                  Get.back();
                },
                onYesPressed: () {
                  Get.find<AuthController>().clearSharedData();
                  Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                }, description: '',),
              useSafeArea: false,
            );
          }
        }
        else if(menu!.route!.contains('profile')) {
          Get.offNamed(RouteHelper.getProfileRoute());
        }else if(menu!.route!.contains('language')) {
          Get.back();
          Get.bottomSheet(const ChooseLanguageBottomSheet(), backgroundColor: Colors.transparent, isScrollControlled: true);
        }
        else {
          Get.offNamed(menu!.route!);
        }
      },
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(Ios27Tokens.radiusSm)),
            color: Get.isDarkMode ? Colors.grey.withValues(alpha: 0.2) : Theme.of(context).primaryColor.withValues(alpha: 0.08),
            border: Border.all(color: Ios27Tokens.rim(context), width: 0.5),
          ),
          height: 60,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          alignment: Alignment.center,
          child: menu!.icon is IconData
              ? Icon(menu!.icon as IconData, size: 28, color: Theme.of(context).primaryColor)
              : Image.asset(menu!.icon!, width: 28, height: 28),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(menu!.title!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center),
      ]),
    );
  }
}
