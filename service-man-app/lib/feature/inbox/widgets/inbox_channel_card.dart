import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

String inboxLastMessage(ChannelData channelData, String userName) {
  if (channelData.lastSentMessage != null) {
    if (channelData.lastMessageSentUser == userName) {
      return "${'you'.tr}: ${channelData.lastSentMessage}";
    }
    return channelData.lastSentMessage!;
  }

  if (channelData.lastSentAttachmentType == null) {
    return '';
  }

  final bool isPhoto =
      channelData.lastSentAttachmentType == "png" ||
      channelData.lastSentAttachmentType == "jpg";
  final bool isMine = channelData.lastMessageSentUser == userName;
  final int fileCount = channelData.lastSentFileCount ?? 1;
  final bool isMultiple = fileCount > 1;

  if (isPhoto) {
    if (isMine) {
      return isMultiple
          ? "${'you_sent'.tr} $fileCount ${'photos'.tr}"
          : "you_sent_a_photo".tr;
    }
    return isMultiple
        ? "${'sent'.tr} $fileCount ${'photos'.tr}"
        : 'sent_a_photo'.tr;
  }

  if (isMine) {
    return isMultiple
        ? "${'you_sent'.tr} $fileCount ${'attachments'.tr}"
        : "you_sent_an_attachment".tr;
  }
  return isMultiple
      ? "${'sent'.tr} $fileCount ${'attachments'.tr}"
      : 'sent_an_attachment'.tr;
}

String _inboxRowTime(String? isoTime) {
  if (isoTime == null || isoTime.isEmpty) return '';
  try {
    final DateTime local = DateConverter.isoUtcStringToLocalDate(isoTime);
    final DateTime now = DateTime.now();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return DateConverter.convertStringTimeToDate(local);
    }
    return DateConverter.dateStringMonthYear(local);
  } catch (_) {
    return '';
  }
}

class InboxChannelCard extends StatelessWidget {
  final ChannelData channelData;
  final bool isAdmin;
  const InboxChannelCard({super.key, required this.channelData, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    ConversationUserModel? conversationUser;
    int? isRead;
    String? imageWithPath;
    final String userName =
        "${Get.find<UserController>().userInfo.firstName} ${Get.find<UserController>().userInfo.lastName}";

    if (channelData.channelUsers != null && channelData.channelUsers!.length > 1) {
      conversationUser = channelData.channelUsers?[0].user?.userType != "provider-serviceman"
          ? channelData.channelUsers![0]
          : channelData.channelUsers![1];
      isRead = channelData.channelUsers?[0].user?.userType == "provider-serviceman"
          ? channelData.channelUsers![0].isRead
          : channelData.channelUsers![1].isRead;

      final String? imageUrl = conversationUser.user?.userType == 'customer'
          ? conversationUser.user?.profileImageFullPath
          : conversationUser.user?.userType == 'super-admin'
              ? "${Get.find<SplashController>().configModel?.content?.faviconFullPath}"
              : conversationUser.user?.provider?.logoFullPath ?? "";
      imageWithPath = "$imageUrl";
    }

    if (conversationUser == null) {
      return const SizedBox();
    }

    final ConversationUserModel chatUser = conversationUser;

    final bool isUnread = isRead == 0;
    final String name = isAdmin
        ? "technical_support_team".tr
        : chatUser.user?.userType == "super-admin"
            ? "technical_support_team".tr
            : chatUser.user?.userType == "provider-admin"
            ? (chatUser.user?.provider?.companyName?.isNotEmpty == true
                  ? chatUser.user!.provider!.companyName!
                  : "zone_admin".tr)
            : "${chatUser.user?.firstName ?? ""} ${chatUser.user?.lastName ?? ""}";

    final String lastMessage = inboxLastMessage(channelData, userName);
    final String? serviceName =
        Get.find<ConversationController>().serviceNameForChannel(channelData);

    String time = '';
    final String? timeSource = chatUser.updatedAt ?? channelData.createdAt;
    time = _inboxRowTime(timeSource);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final String tappedName = name;
          final String image = imageWithPath ?? "";
          final String phone = chatUser.user?.phone ?? "";
          final String userType = chatUser.user?.userType ?? "";
          Get.toNamed(
            RouteHelper.getChatScreenRoute(
              chatUser.channelId ?? channelData.id ?? "",
              tappedName,
              image,
              phone,
              userType,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.kMuted,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: ClipOval(
                  child: (imageWithPath?.isNotEmpty ?? false)
                      ? CustomImage(
                          image: imageWithPath,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 44,
                          height: 44,
                          color: context.kMuted,
                          alignment: Alignment.center,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '',
                            style: robotoBold.copyWith(
                              fontSize: 16,
                              color: context.kMutedForeground,
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
                      name,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        fontWeight: FontWeight.w600,
                        color: context.kForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (serviceName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        serviceName,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: context.kMutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (lastMessage.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        lastMessage,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: context.kMutedForeground,
                        ),
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
                  if (time.isNotEmpty)
                    Text(
                      time,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: context.kMutedForeground,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  if (isUnread) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.kPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: context.kPrimaryForeground,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
