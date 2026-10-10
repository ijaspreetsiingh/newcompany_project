import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class ChooseLanguageBottomSheet extends StatelessWidget {
  const ChooseLanguageBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      initState: (_) {
        Get.find<LocalizationController>().filterLanguage(shouldUpdate: false);
      },
      builder: (localizationController) {
        return Container(
          width: Dimensions.webMaxWidth,
          decoration: BoxDecoration(
            color: context.kBackground,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Ios27Tokens.radiusLg)),
            border: Border(top: BorderSide(color: context.kBorder, width: 1)),
          ),
          padding: EdgeInsets.only(
            left: Dimensions.paddingSizeLarge,
            right: Dimensions.paddingSizeLarge,
            top: Dimensions.paddingSizeSmall,
            bottom: Dimensions.paddingSizeLarge + MediaQuery.of(context).padding.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    color: context.kMuted,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.kMuted,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.language_rounded,
                        color: context.kForeground,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "select_language".tr,
                            style: robotoBold.copyWith(
                              fontSize: 20,
                              color: context.kForeground,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "choose_your_language_to_proceed".tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: context.kMutedForeground,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: Get.height * 0.45,
                    minHeight: Get.height * 0.1,
                  ),
                  child: ListView.builder(
                    itemCount: localizationController.localLanguages.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      final bool isSelected =
                          localizationController.selectedIndex == index;
                      final LanguageModel language =
                          localizationController.localLanguages[index];

                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeSmall),
                        child: InkWell(
                          onTap: () =>
                              localizationController.setSelectIndex(index),
                          borderRadius: BorderRadius.circular(kRadiusMd),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeSmall + 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(kRadiusMd),
                              color: isSelected
                                  ? context.kPrimary
                                  : context.kCard,
                              border: Border.all(
                                color: isSelected
                                    ? context.kPrimary
                                    : context.kBorder,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    language.imageUrl!,
                                    width: 34,
                                    height: 34,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeDefault),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        language.languageName!,
                                        style: robotoMedium.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeDefault,
                                          color: isSelected
                                              ? context.kPrimaryForeground
                                              : context.kForeground,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        (language.languageCode ?? '')
                                            .toUpperCase(),
                                        style: robotoRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color: isSelected
                                              ? context.kPrimaryForeground
                                                  .withValues(alpha: 0.8)
                                              : context.kMutedForeground,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_rounded,
                                    size: 18,
                                    color: context.kPrimaryForeground,
                                  )
                                else
                                  const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeSmall),
                  child: KButton(
                    label: 'select'.tr,
                    height: 48,
                    onTap: () {
                      Get.find<SplashController>().disableIntro();
                      if (localizationController.localLanguages.isNotEmpty &&
                          localizationController.selectedIndex != -1) {
                        localizationController.setLanguage(Locale(
                          localizationController
                              .localLanguages[
                                  localizationController.selectedIndex]
                              .languageCode!,
                          localizationController
                              .localLanguages[
                                  localizationController.selectedIndex]
                              .countryCode,
                        ));
                        Get.find<SplashController>().getConfigData();
                        Get.back();
                      } else {
                        showCustomSnackBar('select_a_language'.tr,
                            type: ToasterMessageType.info);
                      }
                    },
                  ),
                ),
                SizedBox(
                    height:
                        ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : 0),
              ],
            ),
          ),
        );
      },
    );
  }
}
