import 'package:demandium_provider/helper/help_me.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  const DashboardHeader({super.key});

  @override
  Size get preferredSize => const Size(double.maxFinite, 55);

  static String _initialsOf(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return AppConstants.appName.substring(0, 1);
    final String first = parts.first[0];
    final String second = parts.length > 1 ? parts.last[0] : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        final providerInfo =
            userProfileController.providerModel?.content?.providerInfo;
        final String ownerName =
            '${providerInfo?.owner?.firstName ?? ''} ${providerInfo?.owner?.lastName ?? ''}'
                .trim();
        final String companyName = (providerInfo?.companyName ?? '').trim();
        final String businessName = companyName.isNotEmpty
            ? companyName
            : (ownerName.isNotEmpty ? ownerName : AppConstants.appName);

        String cityName = userProfileController.myZone.trim();
        if (cityName.isEmpty) cityName = (providerInfo?.companyAddress ?? '').trim();

        return AppBar(
          elevation: 0,
          titleSpacing: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: InkColors.background,
          shape:  Border(
            bottom: BorderSide(color: InkColors.border, width: 1),
          ),
          leadingWidth: 64,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Center(
              child: Container(
                height: 36,
                width: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: InkColors.foreground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _initialsOf(businessName),
                  style: displayBold.copyWith(
                    fontSize: 14,
                    color: InkColors.background,
                  ),
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                businessName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoBold.copyWith(
                  fontSize: 14,
                  height: 1.2,
                  color: InkColors.foreground,
                ),
              ),
              if (cityName.isNotEmpty)
                Text(
                  cityName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(
                    fontSize: 11,
                    height: 1.3,
                    color: InkColors.mutedForeground,
                  ),
                ),
            ],
          ),
          actions: [
            InkIconButton(
              icon: Icons.chat_bubble_outline_rounded,
              onTap: () {
                if (isRedundentClick(DateTime.now())) return;
                Get.toNamed(RouteHelper.getInboxScreenRoute());
              },
            ),
            const SizedBox(width: 10),
            GetBuilder<NotificationController>(
              builder: (notificationController) {
                final int unseenCount =
                    notificationController.unseenNotificationCount;
                return InkIconButton(
                  icon: Icons.notifications_outlined,
                  badge: unseenCount > 0 ? '$unseenCount' : null,
                  onTap: () => Get.toNamed(
                    RouteHelper.getNotificationRoute(fromPage: 'notification'),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
          ],
        );
      },
    );
  }
}
