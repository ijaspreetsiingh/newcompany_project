import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ServicemanNotificationSetup extends StatelessWidget {
  const ServicemanNotificationSetup({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<NotificationSetupController>(builder: ( notificationSetupController){

      List<NotificationSetup>? nList = notificationSetupController.tabController?.index == 1 && notificationSetupController.isActiveSuffixIcon ?
      notificationSetupController.searchedServicemanNotificationSetupList : notificationSetupController.servicemanNotificationSetupList;

      final bool canUpdate = nList != null && nList.isNotEmpty;

      return Padding( padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child:  nList != null && nList.isNotEmpty ? ListView.separated(itemBuilder: (context, index){
                return  NotificationItemWidget(
                  notificationSetup: nList[index],
                  index: index, userType: "serviceman",
                );
              }, itemCount: nList.length,
                separatorBuilder: (context, index){
                  return const SizedBox(height: 12,);
                },
              ) :  nList != null && nList.isEmpty ? NoDataScreen(text: "no_data_found".tr,
              ) : nList == null ? const NotificationSetupShimmer() : const SizedBox(),
            ),

            const SizedBox(height: 12,),

            CustomButton(btnTxt: "update".tr,
              onPressed: canUpdate ? (){
                dynamic body;
                if (!notificationSetupController.isActiveSuffixIcon) {
                  body = notificationSetupController.getNotificationObject(notificationSetupController.servicemanNotificationSetupList);
                }else{
                  body = notificationSetupController.getNotificationObject(notificationSetupController.searchedServicemanNotificationSetupList);
                }
                notificationSetupController.updateNotificationSetup(body: body);
              } : null,
              isLoading: notificationSetupController.isLoading,
              color: InkColors.foreground,
              textColor: canUpdate ? InkColors.background : InkColors.foreground,
              radius: 50,
              height: 44,
            ),
            const SizedBox(height: 16,),
          ],
        ),
      );
    });
  }
}
