import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "my_profile".tr),
      body: GetBuilder<UserController>(
        builder: (userController) {
          return userController.isLoading
              ? const ProfileShimmer()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileHeader(context, userController),
                      const SizedBox(height: 24),
                      _buildMenuSection(context, userController),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CustomImage(
              image: controller.userInfo.profileImageFullPath ?? "",
              height: 80,
              width: 80,
              placeholder: Images.userPlaceHolder,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "${controller.userInfo.firstName ?? ""} ${controller.userInfo.lastName ?? ""}",
            style: robotoBold.copyWith(
              fontSize: 18,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.userInfo.email ?? "",
            style: robotoRegular.copyWith(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                value: "${controller.totalDays}",
                label: "since_joined".tr,
              ),
              Container(
                width: 1,
                height: 36,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
              _buildStatItem(
                context,
                value: "${controller.contents?.completedBookingsCount ?? 0}",
                label: "completed".tr,
              ),
              Container(
                width: 1,
                height: 36,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
              _buildStatItem(
                context,
                value: "${controller.contents?.bookingsCount ?? 0}",
                label: "total".tr,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: robotoBold.copyWith(
            fontSize: 18,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, UserController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.dark_mode_outlined,
            title: "dark_mode".tr,
            trailing: Switch.adaptive(
              value: Get.isDarkMode,
              onChanged: (val) => Get.find<ThemeController>().toggleTheme(),
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.edit_outlined,
            title: "edit_profile".tr,
            onTap: () => Get.toNamed(RouteHelper.profileInformation),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.notifications_outlined,
            title: "notification".tr,
            onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.description_outlined,
            title: "terms_conditions".tr,
            onTap: () => Get.toNamed(RouteHelper.getHtmlRoute("terms-and-conditions")),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: "privacy_policy".tr,
            onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy')),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.logout_rounded,
            title: "logout".tr,
            isDestructive: true,
            onTap: () => Get.dialog(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Theme.of(context).colorScheme.error.withValues(alpha: 0.06)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDestructive
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: robotoMedium.copyWith(
                  fontSize: 14,
                  color: isDestructive
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.only(left: 70, right: 20),
      color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
    );
  }
}
