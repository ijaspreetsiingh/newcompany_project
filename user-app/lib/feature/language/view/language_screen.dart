import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

/// nest. `LanguageScreen` (reference: designnew/src/routes/index.tsx)
class LanguageScreen extends StatefulWidget {
  final String? fromPage;
  const LanguageScreen({super.key, this.fromPage});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<LocalizationController>().filterLanguage(shouldUpdate: false, isChooseLanguage: true, fromPage: widget.fromPage);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      isExit: true,
      child: Scaffold(
        backgroundColor: NestInk.background,
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
        endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        appBar: widget.fromPage == "fromSettingsPage"
            ? CustomAppBar(title: 'language'.tr)
            : null,
        body: SafeArea(
          child: GetBuilder<LocalizationController>(
            builder: (localizationController) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.fromPage != "fromSettingsPage") ...[
                      const SizedBox(height: 28),
                      Center(
                        child: Container(
                          height: 45,
                          width: 160,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/logo.png'),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    Text(
                      'Language',
                      style: NestInk.display(size: 26, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the language you prefer for the app.',
                      style: NestInk.body(size: 14, color: NestInk.mutedText),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      decoration: BoxDecoration(
                        color: NestInk.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NestInk.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (int index = 0; index < localizationController.languages.length; index++)
                            Builder(builder: (context) {
                              final bool isSelected = localizationController.selectedIndex == index;
                              final String name = localizationController.languages[index].languageName ?? '';
                              final String code = (localizationController.languages[index].languageCode ?? '').toUpperCase();
                              return InkWell(
                                onTap: () => localizationController.setSelectIndex(index),
                                child: Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(minHeight: 59),
                                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                                  decoration: BoxDecoration(
                                    border: index == localizationController.languages.length - 1
                                        ? null
                                        : Border(bottom: BorderSide(color: NestInk.border)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 34,
                                        width: 34,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: NestInk.soft,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          code.length > 3 ? code.substring(0, 2) : code,
                                          style: NestInk.display(size: 9, weight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: NestInk.display(size: 12, weight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        height: 20,
                                        width: 20,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isSelected ? NestInk.primary : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: isSelected ? NestInk.primary : NestInk.border),
                                        ),
                                        child: isSelected
                                            ? Icon(Icons.check, size: 11, color: NestInk.background)
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: NestPillButton(
                        label: 'Save language',
                        onTap: () {
                          Get.find<SplashController>().disableShowinttialLanguageScreen();
                          localizationController.setLanguage(
                            Locale(
                              localizationController.languages[localizationController.selectedIndex].languageCode!,
                              localizationController.languages[localizationController.selectedIndex].countryCode,
                            ),
                            isinttial: true,
                          );
                          if (Get.find<SplashController>().isShowOnboardingScreen() && !kIsWeb) {
                            Get.offNamed(RouteHelper.onBoardScreen);
                          } else {
                            Get.find<SplashController>().getConfigData();
                            HomeScreen.loadData(true);
                            Get.offAllNamed(RouteHelper.getMainRoute("home"));
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


