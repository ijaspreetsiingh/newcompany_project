import 'dart:ui';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class DashboardHeaderNew extends StatelessWidget implements PreferredSizeWidget {
  const DashboardHeaderNew({super.key});

  @override
  Size get preferredSize => const Size(double.maxFinite, 64);

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

  static bool isRedundentClick(DateTime lastClickTime,
      {int durationInMilliSeconds = 800}) {
    return DateTime.now().difference(lastClickTime).inMilliseconds <
        durationInMilliSeconds;
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
        if (cityName.isEmpty) {
          cityName = (providerInfo?.companyAddress ?? '').trim();
        }

        return Container(
          decoration: BoxDecoration(
            color: InkColors.background.withValues(alpha: 0.85),
            border:  Border(
              bottom: BorderSide(
                color: InkColors.border,
                width: 1,
              ),
            ),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        // Square rounded brand monogram tile
                        Container(
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
                              height: 1.1,
                              color: InkColors.background,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Business name + city
                        Expanded(
                          child: Column(
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
                        ),
                        const SizedBox(width: 12),
                        // Chat
                        InkWell(
                          onTap: () {
                            if (isRedundentClick(DateTime.now())) return;
                            Get.toNamed(RouteHelper.getInboxScreenRoute());
                          },
                          child: Container(
                            height: 36,
                            width: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: InkColors.border),
                            ),
                            child:  Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 17,
                              color: InkColors.foreground,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Notifications + unseen badge
                        GetBuilder<NotificationController>(
                          builder: (notificationController) {
                            final int unseenCount =
                                notificationController.unseenNotificationCount;
                            return InkWell(
                              onTap: () => Get.toNamed(
                                RouteHelper.getNotificationRoute(
                                    fromPage: 'notification'),
                              ),
                              child: Container(
                                height: 36,
                                width: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: InkColors.border),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                     Icon(
                                      Icons.notifications_outlined,
                                      size: 17,
                                      color: InkColors.foreground,
                                    ),
                                    if (unseenCount > 0)
                                      Positioned(
                                        top: -2,
                                        right: -2,
                                        child: Container(
                                          height: 16,
                                          width: 16,
                                          alignment: Alignment.center,
                                          decoration:  BoxDecoration(
                                            color: InkColors.foreground,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            unseenCount > 99
                                                ? '99+'
                                                : '$unseenCount',
                                            style: robotoBold.copyWith(
                                              fontSize: 9,
                                              height: 1.1,
                                              color: InkColors.background,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
