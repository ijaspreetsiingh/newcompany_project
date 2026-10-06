import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

String _channelRowTime(String? isoTime) {
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

class ChannelItem extends StatelessWidget {
  final ChannelData channelData;
  final bool isAdmin;
  const ChannelItem({super.key, required this.channelData, this.isAdmin = false}) ;
  @override
  Widget build(BuildContext context) {

    ConversationUserModel? conversationUser;
    int? isRead;
    String ? imageWithPath;
    String? lastMessage;
    String userName = "${Get.find<UserController>().userInfo.firstName} ${Get.find<UserController>().userInfo.lastName}";


    if(channelData.channelUsers !=null && channelData.channelUsers!.length > 1){
      conversationUser = channelData.channelUsers?[0].user?.userType != "provider-serviceman" ? channelData.channelUsers![0] : channelData.channelUsers![1];
      isRead = channelData.channelUsers?[0].user?.userType == "provider-serviceman" ? channelData.channelUsers![0].isRead : channelData.channelUsers?[1].isRead;

      String? imageUrl = conversationUser.user?.userType == 'customer' ?
      conversationUser.user?.profileImageFullPath  :  conversationUser.user?.userType == 'super-admin' ? "${Get.find<SplashController>().configModel?.content?.faviconFullPath}" : conversationUser.user?.provider?.logoFullPath ?? "";
      imageWithPath = "$imageUrl";
    }

    if(channelData.lastSentMessage !=null ){
      if(channelData.lastMessageSentUser == userName){
        lastMessage = "${'you'.tr}: ${channelData.lastSentMessage}";
      }else{
        lastMessage = channelData.lastSentMessage;
      }

    }else{
      if(channelData.lastSentAttachmentType !=null){
        if((channelData.lastSentAttachmentType == "png" || channelData.lastSentAttachmentType == "jpg")){
          if(channelData.lastMessageSentUser == userName){

            if(channelData.lastSentFileCount!=null && channelData.lastSentFileCount! > 1){
              lastMessage = "${'you_sent'.tr} ${channelData.lastSentFileCount} ${'photos'.tr}";
            }else{
              lastMessage = "you_sent_a_photo".tr;
            }

          }else{

            if(channelData.lastSentFileCount!=null && channelData.lastSentFileCount! > 1){
              lastMessage = "${'sent'.tr} ${channelData.lastSentFileCount!} ${'photos'.tr}";
            }else{
              lastMessage = 'sent_a_photo'.tr;
            }

          }
        }else{

          if(channelData.lastMessageSentUser == userName){
            if(channelData.lastSentFileCount!=null && channelData.lastSentFileCount! > 1){
              lastMessage = "${'you_sent'.tr} ${channelData.lastSentFileCount} ${"attachments".tr}";
            }else{
              lastMessage = "you_sent_an_attachment".tr;
            }

          }else{
            if(channelData.lastSentFileCount!=null && channelData.lastSentFileCount! > 1){
              lastMessage = "${'sent'.tr} ${channelData.lastSentFileCount!} ${'attachments'.tr}";
            }else{
              lastMessage = 'sent_an_attachment'.tr;
            }

          }
        }
      }
    }

    if(conversationUser == null) return const SizedBox();

    final ConversationUserModel chatUser = conversationUser;

    final String name = isAdmin ? "technical_support_team".tr : chatUser.user?.userType == "super-admin" ?
    "technical_support_team".tr : chatUser.user?.userType == "provider-admin" ?
    (chatUser.user?.provider?.companyName?.isNotEmpty == true ? chatUser.user!.provider!.companyName! : "zone_admin".tr)
    : "${ chatUser.user?.firstName ?? ""} ${ chatUser.user?.lastName ?? ""}";

    final String time = _channelRowTime(chatUser.updatedAt);
    final bool isUnread = isRead == 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          String image = '$imageWithPath';
          String phone =  chatUser.user?.phone??"";
          String userType =  chatUser.user?.userType??"";
          Get.toNamed(RouteHelper.getChatScreenRoute(
              chatUser.channelId ?? "",name,image,phone,userType));
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
                    if(lastMessage != null) ...[
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
                  if(time.isNotEmpty)
                    Text(
                      time,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: context.kMutedForeground,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  if(isUnread) ...[
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
