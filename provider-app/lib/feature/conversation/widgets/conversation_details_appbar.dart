import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ConversationDetailsAppBar extends StatelessWidget {
  final String? name;
  final String? image;
  final String? phone;
  final String userType;
  final String fromNotification;
  final String? channelId;
  const ConversationDetailsAppBar({
    super.key,
    this.name,
    this.image,
    this.phone,
    this.userType = "",
    this.fromNotification = "",
    this.channelId,
  });

  bool get _canCall {
    if (userType == "super-admin" || userType == "provider-admin") return false;
    return phone != null && phone!.trim().isNotEmpty;
  }

  String get _role {
    switch (userType) {
      case "customer":
        return "Customer";
      case "provider-serviceman":
        return "Serviceman";
      case "super-admin":
        return "technical_support_team".tr;
      case "provider-admin":
        return "You";
      default:
        return phone?.isNotEmpty == true ? phone! : "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkTopBar(
      title: name?.tr ?? "",
      subtitle: _role,
      right: _canCall
          ? InkIconButton(
              icon: Icons.call_rounded,
              filled: true,
              onTap: () {
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
              },
            )
          : null,
      onBack: () {
        if (fromNotification == "fromNotification") {
          Get.offNamed(RouteHelper.getInboxScreenRoute(fromNotification: fromNotification));
        } else {
          Get.back();
        }
      },
    );
  }
}
