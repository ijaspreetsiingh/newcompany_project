import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color color;
  final double? titleFontSize;

  const MainAppBar({
    super.key,
    this.title,
    this.titleFontSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (userController) {
        return GetBuilder<NotificationController>(
          builder: (notificationController) {
            final userName = userController.userInfo.firstName ?? '';
            final profileImage =
                userController.userInfo.profileImageFullPath ?? '';

            return AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              leadingWidth: 0,
              leading: const SizedBox.shrink(),
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: profileImage.isNotEmpty
                            ? CustomImage(
                                height: 42,
                                width: 42,
                                image: profileImage,
                              )
                            : Container(
                                height: 42,
                                width: 42,
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.12),
                                alignment: Alignment.center,
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : 'S',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'hello'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          Text(
                            userName.isNotEmpty ? userName : 'service_man'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                _buildIconButton(
                  context,
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: () => Get.toNamed(RouteHelper.getInboxScreenRoute()),
                ),
                const SizedBox(width: 6),
                Stack(
                  children: [
                    _buildIconButton(
                      context,
                      icon: Icons.notifications_outlined,
                      onTap: () {
                        Get.to(const NotificationScreen());
                        notificationController.resetNotificationCount();
                      },
                    ),
                    if (notificationController.unseenNotificationCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0.5),
                child: Container(
                  height: 0.5,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 64);
}
