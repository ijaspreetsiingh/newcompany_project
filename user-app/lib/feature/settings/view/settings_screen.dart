import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _offersUpdates = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return CustomPopWidget(
          child: Scaffold(
            drawer: ResponsiveHelper.isDesktop(context)
                ? const AddressSelectionDrawer()
                : null,
            endDrawer: ResponsiveHelper.isDesktop(context)
                ? const MenuDrawer()
                : null,
            backgroundColor: NestInk.background,
            appBar: CustomAppBar(
              isBackButtonExist: true,
              bgColor: NestInk.background,
              title: 'settings'.tr,
            ),
            body: FooterBaseView(
              isScrollView: true,
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: NestScreenBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NestMenuCard(
                        margin: EdgeInsets.zero,
                        children: [
                          GetBuilder<ThemeController>(
                            builder: (themeController) {
                              return NestToggleRow(
                                icon: Icons.dark_mode_rounded,
                                title: 'dark_mode'.tr,
                                subtitle: 'Reduce glare at night',
                                value: themeController.darkTheme,
                                onChanged: (_) => themeController.toggleTheme(),
                              );
                            },
                          ),
                          GetBuilder<AuthController>(
                            builder: (authController) {
                              return NestToggleRow(
                                icon: Icons.notifications_none_rounded,
                                title: 'booking_updates'.tr,
                                subtitle: 'Status and reminder alerts',
                                value: authController.isNotificationActive(),
                                onChanged: (_) =>
                                    authController.toggleNotificationSound(),
                              );
                            },
                          ),
                          NestToggleRow(
                            icon: Icons.card_giftcard_rounded,
                            title: 'offers_updates'.tr,
                            subtitle: 'Deals picked for you',
                            value: _offersUpdates,
                            onChanged: (value) {
                              setState(() => _offersUpdates = value);
                              customSnackBar(
                                'notification_setting_updated'.tr,
                                type: ToasterMessageType.success,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      NestOutlineAction(
                        label: 'delete_account'.tr,
                        icon: Icons.delete_outline_rounded,
                        danger: true,
                        radius: 14,
                        height: 51,
                        onTap: _confirmDeleteAccount,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NestInk.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
          side: BorderSide(color: NestInk.border),
        ),
        title: Text(
          'delete_account'.tr,
          style: NestInk.display(size: 16, weight: FontWeight.w700),
        ),
        content: Text(
          'delete_account_confirmation'.tr,
          style: NestInk.body(size: 12, color: NestInk.mutedText),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr,
              style: NestInk.display(
                size: 12,
                weight: FontWeight.w700,
                color: NestInk.mutedText,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              customSnackBar(
                'Your delete account request has been received.',
                type: ToasterMessageType.success,
              );
            },
            child: Text(
              'delete'.tr,
              style: NestInk.display(
                size: 12,
                weight: FontWeight.w700,
                color: NestInk.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
