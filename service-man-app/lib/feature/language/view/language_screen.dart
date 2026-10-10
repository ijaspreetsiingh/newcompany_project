import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class ChooseLanguageScreen extends StatelessWidget {
  const ChooseLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kBackground,
      body: SafeArea(
        child: GetBuilder<LocalizationController>(
          initState: (_) => Get.find<LocalizationController>().filterLanguage(shouldUpdate: false, isChooseLanguage: true),
          builder: (localizationController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: KIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Get.back(),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Icon(
                            Icons.language,
                            size: 36,
                            color: context.kForeground,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'choose_language_title'.tr,
                            style: robotoBold.copyWith(
                              fontSize: 30,
                              color: context.kForeground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'language_change_note'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: 14,
                              color: context.kMutedForeground,
                            ),
                          ),
                          const SizedBox(height: 32),
                          GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : ResponsiveHelper.isTab(context) ? 3 : 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              mainAxisExtent: 96,
                            ),
                            itemCount: localizationController.localLanguages.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) => LanguageWidget(
                              languageModel: localizationController.localLanguages[index],
                              localizationController: localizationController,
                              index: index,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  KButton(
                    label: 'save_continue'.tr,
                    height: 48,
                    onTap: () {
                      Get.find<SplashController>().disableIntro();
                      if (localizationController.localLanguages.isNotEmpty && localizationController.selectedIndex != -1) {
                        localizationController.setLanguage(
                          Locale(
                            localizationController.localLanguages[localizationController.selectedIndex].languageCode!,
                            localizationController.localLanguages[localizationController.selectedIndex].countryCode,
                          ),
                          isInitial: true,
                        );
                        Get.find<SplashController>().getConfigData();
                        Get.offNamed(RouteHelper.signIn);
                      } else {
                        showCustomSnackBar('select_a_language'.tr, type: ToasterMessageType.info);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
