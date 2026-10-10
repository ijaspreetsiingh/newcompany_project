import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationSetup notificationSetup;
  final String userType;
  final int index;
  const NotificationItemWidget({super.key, required this.notificationSetup, required this.index, required this.userType});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<NotificationSetupController>(builder: (controller){
      return InkCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start , children: [

          Text(notificationSetup.title ?? "",
            style: robotoSemiBold.copyWith(
              fontSize: 14,
              height: 1.3,
              color: InkColors.foreground,
            ),
          ),

          const SizedBox(height: 5,),

          Text(notificationSetup.subTitle ??"",
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              height: 1.4,
              color: InkColors.mutedForeground,
            ),
          ),

          const SizedBox(height: 12,),

          Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            if(notificationSetup.value?.notification != null) _InkCheckBox(title:  "push_notification".tr,
              value: notificationSetup.value?.notification == 1
                  ? (notificationSetup.providerNotifications?.value?.notification == 1 || notificationSetup.providerNotifications?.value?.notification == null)
                  ? true : false : false,
              onTap: notificationSetup.value?.notification == 1 ? (){
                var value = notificationSetup.providerNotifications?.value?.notification ?? notificationSetup.value?.notification ?? 0;
                controller.toggleCheckbox(userType: userType,type: "notification", value: value, index: index);
              } : (){
              showCustomSnackBar("this_option_is_disabled_from_admin".tr,type: ToasterMessageType.info);
              },
            ),
            if (notificationSetup.value?.sms != null) _InkCheckBox(title:  "sms".tr,
              value: notificationSetup.value?.sms == 1
                  ? (notificationSetup.providerNotifications?.value?.sms == 1 || notificationSetup.providerNotifications?.value?.sms == null)
                  ? true : false : false,
              onTap: notificationSetup.value?.sms == 1 ? (){
                var value = notificationSetup.providerNotifications?.value?.sms ?? notificationSetup.value?.sms ?? 0;
                controller.toggleCheckbox(userType: userType,type: "sms", value: value, index: index);
              } : (){
                showCustomSnackBar("this_option_is_disabled_from_admin".tr, type: ToasterMessageType.info);
              },
            ) ,
            if (notificationSetup.value?.email != null) _InkCheckBox(title:  "mail".tr,
              value: notificationSetup.value?.email == 1
                  ? ( notificationSetup.providerNotifications?.value?.email == 1 || notificationSetup.providerNotifications?.value?.email == null)
                  ? true : false : false,
              onTap: notificationSetup.value?.email == 1 ? (){
                var value = notificationSetup.providerNotifications?.value?.email ?? notificationSetup.value?.email ?? 0;
                controller.toggleCheckbox(userType: userType,type: "email", value: value, index: index);
              } : (){
                showCustomSnackBar("this_option_is_disabled_from_admin".tr, type: ToasterMessageType.info);
              },
            ),
          ])

        ],),
      );
    });
  }
}

class _InkCheckBox extends StatelessWidget {
  final String title;
  final bool value;
  final Function()? onTap;
  const _InkCheckBox({required this.title, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 18,
          width: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: value ? InkColors.foreground : InkColors.card,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: value ? InkColors.foreground : InkColors.border),
          ),
          child: value ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
        ),
      ),
      const SizedBox(width: 6),
      Text(title, style: robotoMedium.copyWith(
        fontSize: 12,
        height: 1.2,
        color: value ? InkColors.foreground : InkColors.mutedForeground,
      )),
    ]);
  }
}
