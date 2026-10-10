import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class ConversationDetailsAppBar extends StatelessWidget {
  final String? name;
  final String? image;
  final String? phone;
  final String userType;
  final String fromNotification;
  final String? channelId;
  const ConversationDetailsAppBar({super.key, this.name, this.image, this.phone, this.userType = "", this.fromNotification ="", this.channelId});

  String get _role {
    switch (userType) {
      case "customer":
        return "customer".tr;
      case "provider-admin":
        return "zone_admin".tr;
      case "super-admin":
        return "technical_support_team".tr;
      case "provider-serviceman":
        return "partner".tr;
      default:
        return hasPhone ? phone! : "";
    }
  }

  bool get hasPhone => phone != null && phone!.isNotEmpty;

  bool get _canCall => userType != "super-admin" && hasPhone;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: PageHeader(
        title: name?.tr ?? "",
        subtitle: _role,
        onBack: () {
          if(fromNotification == "fromNotification"){
            Get.offNamed(RouteHelper.getInboxScreenRoute(fromNotification: fromNotification));
          }else{
            Get.back();
          }
        },
        right: KIconButton(
          icon: Icons.call_outlined,
          onTap: _canCall
              ? () {
                  String? calleeId;
                  if (channelId != null && channelId!.isNotEmpty) {
                    calleeId = Get.find<ConversationController>().otherUserIdForChannel(channelId!);
                  }
                  if (calleeId != null) {
                    Get.find<CallController>().startCall(
                      calleeId: calleeId,
                      callType: 'voice',
                      name: name ?? "",
                      image: image ?? "",
                      phone: phone ?? "",
                    );
                  } else {
                    Get.to(() => ChatCallScreen(
                          name: name ?? "",
                          phone: phone ?? "",
                          image: image ?? "",
                          role: _role,
                        ));
                  }
                }
              : null,
        ),
      ),
    );
  }
}
