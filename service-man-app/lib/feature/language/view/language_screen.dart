import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class ChooseLanguageScreen extends StatelessWidget {
  const ChooseLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).primaryColor,
              size: 16,
            ),
          ),
        ),
        title: Text(
          "select_language".tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      body: GetBuilder<LocalizationController>(
        initState: (_) => Get.find<LocalizationController>().filterLanguage(shouldUpdate: false, isChooseLanguage: true),
        builder: (localizationController) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        "language_hint_text".tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : ResponsiveHelper.isTab(context) ? 3 : 2,
                          childAspectRatio: (1 / 1),
                        ),
                        itemCount: localizationController.localLanguages.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
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
              GetBuilder<LocalizationController>(
                builder: (localizationController) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
                      ),
                    ),
                    child: CustomButton(
                      btnTxt: 'save'.tr,
                      onPressed: () {
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
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
