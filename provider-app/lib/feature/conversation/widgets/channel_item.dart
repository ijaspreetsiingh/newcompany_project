import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ChannelItem extends StatelessWidget {
  final ChannelData channelData;
  final bool isAdmin;
  const ChannelItem({super.key, required this.channelData, this.isAdmin = false});

  String _relativeTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    final DateTime time = DateConverter.isoUtcStringToLocalDate(isoString);
    final Duration diff = DateTime.now().difference(time);
    if (diff.isNegative || diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return DateConverter.dateStringMonthYear(time, format: 'd MMM');
  }

  @override
  Widget build(BuildContext context) {
    ConversationUserModel? conversationUser;
    int? isRead;

    final String providerOwnerName =
        "${Get.find<UserProfileController>().providerModel?.content?.providerInfo?.owner?.firstName} ${Get.find<UserProfileController>().providerModel?.content?.providerInfo?.owner?.lastName}";

    if (channelData.channelUsers != null && channelData.channelUsers!.length > 1) {
      conversationUser =
          channelData.channelUsers?[0].user?.userType != "provider-admin" ? channelData.channelUsers![0] : channelData.channelUsers![1];
      isRead = channelData.channelUsers![0].user?.userType == "provider-admin"
          ? channelData.channelUsers![0].isRead!
          : channelData.channelUsers![1].isRead!;
    }

    final bool isChannelAdmin = isAdmin || conversationUser?.user?.userType == "super-admin";

    String? lastMessage;
    if (channelData.lastSentMessage != null) {
      lastMessage =
          channelData.lastMessageSentUser == providerOwnerName ? "${'you'.tr}: ${channelData.lastSentMessage}" : channelData.lastSentMessage;
    } else if (channelData.lastSentAttachmentType != null) {
      final bool isImage =
          channelData.lastSentAttachmentType == "png" || channelData.lastSentAttachmentType == "jpg";
      final bool isSender = channelData.lastMessageSentUser == providerOwnerName;
      final int fileCount = channelData.lastSentFileCount ?? 1;

      if (isImage) {
        if (fileCount > 1) {
          lastMessage = isSender
              ? "${'you_sent'.tr} $fileCount ${'photos'.tr}"
              : "${'sent'.tr} $fileCount ${'photos'.tr}";
        } else {
          lastMessage = isSender ? "you_sent_a_photo".tr : 'sent_a_photo'.tr;
        }
      } else {
        if (fileCount > 1) {
          lastMessage = isSender
              ? "${'you_sent'.tr} $fileCount ${"attachments".tr}"
              : "${'sent'.tr} $fileCount ${"attachments".tr}";
        } else {
          lastMessage = isSender ? "you_sent_an_attachment".tr : 'sent_an_attachment'.tr;
        }
      }
    }

    if (conversationUser == null) return const SizedBox();

    final String name =
        isChannelAdmin ? "technical_support_team".tr : "${conversationUser.user?.firstName ?? ""} ${conversationUser.user?.lastName ?? ""}".trim();

    final bool isUnread = isRead == 0;
    final String time = _relativeTime(channelData.updatedAt ?? conversationUser.updatedAt);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final String image = conversationUser!.user?.userType == "super-admin"
            ? (Get.find<SplashController>().configModel.content?.faviconFullPath ?? "")
            : (conversationUser.user?.profileImageFullPath ?? "");
        Get.toNamed(RouteHelper.getChatScreenRoute(
          conversationUser.channelId ?? "",
          name,
          image,
          conversationUser.user?.phone ?? "",
          conversationUser.user?.userType ?? "",
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          InkAvatar(name: name, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: InkColors.foreground,
                    ),
                  ),
                ),
                if (isChannelAdmin) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: InkColors.inkTint,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: InkColors.inkLine),
                    ),
                    child: Text(
                      'support'.tr.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8.5,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: InkColors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ],),
              const SizedBox(height: 4),
              if (lastMessage != null)
                Text(
                  lastMessage.capitalizeFirst ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                    color: isUnread ? InkColors.foreground : InkColors.mutedForeground,
                  ),
                )
              else
                const SizedBox(height: 1),
            ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
            if (time.isNotEmpty)
              Text(
                time,
                style:  TextStyle(fontSize: 10.5, height: 1.2, color: InkColors.mutedForeground),
              ),
            if (isUnread) ...[
              if (time.isNotEmpty) const SizedBox(height: 5),
              Container(
                height: 8,
                width: 8,
                decoration:  BoxDecoration(color: InkColors.foreground, shape: BoxShape.circle),
              ),
            ],
          ]),
        ]),
      ),
    );
  }
}
