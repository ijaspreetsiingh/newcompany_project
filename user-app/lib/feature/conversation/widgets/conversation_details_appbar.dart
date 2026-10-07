import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class ConversationDetailsAppBar extends StatelessWidget implements PreferredSizeWidget{
  final String? name;
  final String? image;
  final String? phone;
  final String userType;
  final String fromNotification;
  final String? channelId;
  const ConversationDetailsAppBar({super.key, this.name, this.image, this.phone, this.userType = "", this.fromNotification ="", this.channelId}) ;

  String get _role {
    switch (userType) {
      case "customer":
        return "customer".tr;
      case "provider-serviceman":
        return "partner".tr;
      case "super-admin":
        return "technical_support_team".tr;
      case "provider-admin":
        return "zone_admin".tr;
      default:
        return phone?.isNotEmpty == true ? phone! : "";
    }
  }

  bool get _canCall {
    if (userType == "super-admin") return false;
    return phone != null && phone!.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: Get.isDarkMode ? Theme.of(context).cardColor.withValues(alpha: .2):Theme.of(context).primaryColor,
      title: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CustomImage(image: image),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text( name?.tr ??"", maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
              color:  Colors.white,
            )),

            Padding(padding: const EdgeInsets.only(top: 3),
              child: Text(phone != null && phone!.isNotEmpty ? _role : _role,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoLight.copyWith( fontSize: Dimensions.fontSizeSmall,
                color:  Colors.white.withValues(alpha: 0.85),
              )),
            ),

          ])),

          if (_canCall)
            IconButton(
              onPressed: () {
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
              icon: const Icon(Icons.call_rounded, color: Colors.white, size: 22),
            ),
        ],
      ),
      leading: IconButton(onPressed: () {
        if(fromNotification == "fromNotification"){
          Get.offNamed(RouteHelper.getInboxScreenRoute(fromNotification: fromNotification));
        }else{
          Get.back();
        }
      },
        icon: Icon(Icons.arrow_back_ios,color:Theme.of(context).primaryColorLight,size: 20,),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 55);
}

