import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class ChannelItem extends StatelessWidget {
  final ChannelData channelData;
  final bool isAdmin;
  const ChannelItem({
    super.key,
    required this.channelData,
    this.isAdmin = false,
  });
  @override
  Widget build(BuildContext context) {
    ConversationUserModel? conversationUser;
    int? isRead;
    String? lastMessage;

    final userInfo = Get.find<UserController>().userInfoModel;
    final String userName = '${userInfo?.fName ?? ''} ${userInfo?.lName ?? ''}'
        .trim();
    for (final channelUser
        in channelData.channelUsers ?? <ConversationUserModel>[]) {
      if (channelUser.user?.userType == 'customer') {
        isRead = channelUser.isRead;
      } else {
        conversationUser ??= channelUser;
      }
    }

    final userType = conversationUser?.user?.userType;
    final String imageWithPath = userType == 'super-admin'
        ? Get.find<SplashController>().configModel.content?.logoFullPath ?? ''
        : userType == 'provider-admin'
        ? conversationUser?.user?.provider?.logoFullPath ?? ''
        : conversationUser?.user?.profileImageFullPath ?? '';

    if (channelData.lastSentMessage != null) {
      if (channelData.lastMessageSentUser == userName) {
        lastMessage = "${'you'.tr}: ${channelData.lastSentMessage}";
      } else {
        lastMessage = "${channelData.lastSentMessage}";
      }
    } else {
      if (channelData.lastSentAttachmentType != null) {
        if ((channelData.lastSentAttachmentType == "png" ||
            channelData.lastSentAttachmentType == "jpg")) {
          if (channelData.lastMessageSentUser == userName) {
            if (channelData.lastSentFileCount != null &&
                channelData.lastSentFileCount! > 1) {
              lastMessage =
                  "${'you_sent'.tr} ${channelData.lastSentFileCount} ${'photos'.tr}";
            } else {
              lastMessage = "you_sent_a_photo".tr;
            }
          } else {
            if (channelData.lastSentFileCount != null &&
                channelData.lastSentFileCount! > 1) {
              lastMessage =
                  "${'sent'.tr} ${channelData.lastSentFileCount!} ${'photos'.tr}";
            } else {
              lastMessage = 'sent_a_photo'.tr;
            }
          }
        } else {
          if (channelData.lastMessageSentUser == userName) {
            if (channelData.lastSentFileCount != null &&
                channelData.lastSentFileCount! > 1) {
              lastMessage =
                  "${'you_sent'.tr} ${channelData.lastSentFileCount} ${"attachments".tr}";
            } else {
              lastMessage = "you_sent_an_attachment".tr;
            }
          } else {
            if (channelData.lastSentFileCount != null &&
                channelData.lastSentFileCount! > 1) {
              lastMessage =
                  "${'sent'.tr} ${channelData.lastSentFileCount!} ${'attachments'.tr}";
            } else {
              lastMessage = 'sent_an_attachment'.tr;
            }
          }
        }
      }
    }

    /// nest. `.conversation` — flat row · avatar · name · message · time · dot
    if (conversationUser == null) return const SizedBox();

    final String? serviceName = Get.find<ConversationController>()
        .serviceNameForChannel(channelData);

    final String contactName =
        '${conversationUser.user?.firstName ?? ''} ${conversationUser.user?.lastName ?? ''}'
            .trim();
    final String displayName = isAdmin
        ? "technical_support_team".tr
        : conversationUser.user?.userType == 'super-admin'
        ? "technical_support_team".tr
        : conversationUser.user?.userType == 'provider-admin'
        ? (conversationUser.user?.provider?.companyName?.trim().isNotEmpty ==
                  true
              ? conversationUser.user!.provider!.companyName!.trim()
              : 'zone_admin'.tr)
        : contactName.isEmpty
        ? 'partner'.tr
        : contactName;
    final String? updatedAtValue =
        conversationUser.updatedAt ??
        channelData.updatedAt ??
        channelData.createdAt;
    final DateTime? updatedAt = updatedAtValue == null || updatedAtValue.isEmpty
        ? null
        : DateTime.tryParse(updatedAtValue)?.toLocal();

    return InkWell(
      onTap: () {
        Get.find<ConversationController>().resetImageFile();
        final String name = displayName;
        Get.toNamed(
          RouteHelper.getChatScreenRoute(
            conversationUser?.channelId ?? channelData.id ?? "",
            name,
            imageWithPath,
            conversationUser?.user?.phone ?? "",
            conversationUser?.user?.userType ?? "",
          ),
        );
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: NestInk.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// avatar (44px circle)
            ClipOval(
              child: (imageWithPath.isNotEmpty)
                  ? CustomImage(
                      height: 44,
                      width: 44,
                      image: imageWithPath,
                      fit: BoxFit.cover,
                      placeholder: isAdmin
                          ? Images.adminPlaceHolder
                          : Images.userPlaceHolder,
                    )
                  : Container(
                      height: 44,
                      width: 44,
                      alignment: Alignment.center,
                      color: NestInk.primary,
                      child: Text(
                        _inttials(displayName),
                        style: NestInk.display(
                          size: 12,
                          weight: FontWeight.w800,
                          color: NestInk.background,
                        ),
                      ),
                    ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: NestInk.display(
                            size: 12,
                            weight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversationUser.user?.userType == "super-admin") ...[
                        const SizedBox(width: 6),
                        Text(
                          'support'.tr,
                          style: NestInk.body(
                            size: 8,
                            weight: FontWeight.w700,
                            color: NestInk.mutedText,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (serviceName != null && serviceName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      serviceName,
                      style: NestInk.body(
                        size: 10,
                        weight: FontWeight.w600,
                        color: NestInk.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (lastMessage != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      lastMessage.capitalizeFirst ?? "",
                      style: NestInk.body(size: 10, color: NestInk.mutedText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  updatedAt == null ? '' : _shortTime(updatedAt),
                  style: NestInk.body(size: 8, color: NestInk.mutedText),
                  textDirection: TextDirection.ltr,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                isRead == 0
                    ? Container(
                        height: 7,
                        width: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: NestInk.primary,
                        ),
                      )
                    : const SizedBox(height: 7),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _inttials(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _shortTime(DateTime time) {
    final Duration diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateConverter.dateMonthYearTime(time);
  }
}
