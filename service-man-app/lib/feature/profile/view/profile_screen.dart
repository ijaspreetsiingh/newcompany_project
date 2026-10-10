import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kBackground,
      body: GetBuilder<UserController>(
        builder: (userController) {
          return userController.isLoading
              ? const ProfileShimmer()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, userController),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAvailabilityCard(context),
                            const SizedBox(height: 20),
                            _buildSettingsSection(context),
                            const SizedBox(height: 20),
                            _buildSupportSection(context),
                            const SizedBox(height: 20),
                            _buildLogoutButton(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserController controller) {
    final String name =
        "${controller.userInfo.firstName ?? ""} ${controller.userInfo.lastName ?? ""}"
            .trim();
    final String subtitle = controller.userInfo.email ?? "";

    return Container(
      width: double.infinity,
      color: context.kPrimary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            children: [
              Row(
                children: [
                  KIconButton(
                    icon: Icons.menu_rounded,
                    color: context.kPrimaryForeground,
                    onTap: BottomNavScreen.openMenu,
                  ),
                  const Spacer(),
                  KIconButton(
                    icon: Icons.edit_outlined,
                    color: context.kPrimaryForeground,
                    onTap: () => Get.toNamed(RouteHelper.profileInformation),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: WorkStatusService.online,
                    builder: (context, online, _) => UserAvatar(
                      large: true,
                      imageUrl: controller.userInfo.profileImageFullPath,
                      name: controller.userInfo.firstName ?? "",
                      online: online,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      fontSize: 24,
                      color: context.kPrimaryForeground,
                    ),
                  ),
                  Text(
                    subtitle.isNotEmpty ? subtitle : 'service_man'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: 14,
                      color: context.kPrimaryForeground.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.kPrimaryForeground.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'service_professional'.tr,
                      style: robotoBold.copyWith(
                        fontSize: 10,
                        color: context.kPrimaryForeground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatsRow(context, controller),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, UserController controller) {
    return Row(
      children: [
        Expanded(
          child: _miniStat(
            context,
            value: "${controller.totalDays ?? 0}",
            label: 'days_joined'.tr,
          ),
        ),
        _statDivider(context),
        Expanded(
          child: _miniStat(
            context,
            value: "${controller.contents?.completedBookingsCount ?? 0}",
            label: 'completed'.tr,
          ),
        ),
        _statDivider(context),
        Expanded(
          child: _miniStat(
            context,
            value: "${controller.contents?.bookingsCount ?? 0}",
            label: 'total_jobs'.tr,
          ),
        ),
      ],
    );
  }

  Widget _miniStat(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: robotoBold.copyWith(
            fontSize: 18,
            color: context.kPrimaryForeground,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: robotoRegular.copyWith(
            fontSize: 10,
            color: context.kPrimaryForeground.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  Widget _statDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: context.kPrimaryForeground.withValues(alpha: 0.2),
    );
  }

  Widget _buildAvailabilityCard(BuildContext context) {
    return KCard(
      padding: const EdgeInsets.all(16),
      child: ValueListenableBuilder<bool>(
        valueListenable: WorkStatusService.online,
        builder: (context, online, _) => ToggleRow(
          title: 'available_for_jobs'.tr,
          text: 'receive_new_requests'.tr,
          value: online,
          onChanged: (value) => WorkStatusService.setStatus(value),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return MenuGroup(
      title: 'settings'.tr,
      items: [
        MenuGroupItem(
          icon: Icons.person_outline_rounded,
          label: 'edit_profile'.tr,
          onTap: () => Get.toNamed(RouteHelper.profileInformation),
        ),
        MenuGroupItem(
          icon: Icons.notifications_outlined,
          label: 'notification'.tr,
          onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
        ),
        MenuGroupItem(
          icon: Icons.dark_mode_outlined,
          label: 'dark_mode'.tr,
          onTap: () => Get.find<ThemeController>().toggleTheme(),
        ),
        MenuGroupItem(
          icon: Icons.language_rounded,
          label: 'language'.tr,
          onTap: () => Get.bottomSheet(
            const ChooseLanguageBottomSheet(),
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return MenuGroup(
      title: 'support'.tr,
      items: [
        MenuGroupItem(
          icon: Icons.description_outlined,
          label: 'terms'.tr,
          onTap: () =>
              Get.toNamed(RouteHelper.getHtmlRoute("terms-and-conditions")),
        ),
        MenuGroupItem(
          icon: Icons.verified_user_outlined,
          label: 'privacy_policy_title'.tr,
          onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy')),
        ),
        MenuGroupItem(
          icon: Icons.help_outline_rounded,
          label: 'help_support'.tr,
          onTap: () => Get.toNamed(RouteHelper.getSupportScreenRoute()),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showLogoutDialog,
        borderRadius: BorderRadius.circular(kRadiusMd),
        child: Container(
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: Border.all(color: context.kInputBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 16,
                color: context.kDestructive,
              ),
              const SizedBox(width: 8),
              Text(
                'log_out'.tr,
                style: robotoMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.kDestructive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
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
}
