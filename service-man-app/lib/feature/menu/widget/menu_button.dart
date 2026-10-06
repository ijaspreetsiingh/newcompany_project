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
            borderRadius: const BorderRadius.all(Radius.circular(kRadiusMd)),
            color: context.kCard,
            border: Border.all(color: context.kBorder, width: 1),
          ),
          height: 60,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          alignment: Alignment.center,
          child: menu!.icon is IconData
              ? Icon(menu!.icon as IconData, size: 26, color: context.kForeground)
              : Image.asset(menu!.icon!, width: 26, height: 26),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(menu!.title!,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: context.kForeground,
          ),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}
