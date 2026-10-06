import 'package:demandium_provider/feature/tutorial/controller/tutorial_controller.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';


class ServiceAvailabilityTabItemWidget extends StatelessWidget {
  const ServiceAvailabilityTabItemWidget({super.key});

  @override
  Widget build(BuildContext context) {

    JustTheController tooltipController = JustTheController();


    return GetBuilder<BusinessSettingController>(builder: ( businessSettingController){

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    /// Service availability toggle card
                    InkCard(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          SwitchButton(
                            titleText: "service_availability",
                            value: businessSettingController.serviceAvailabilitySettings ? 1 : 0,
                            onTap: (bool value) {
                              businessSettingController.toggleServiceAvailabilitySettings();
                            },
                            tootTipText: "",
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                            child: Text("service_availability_hint".tr,
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                height: 1.5,
                                color: InkColors.mutedForeground,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// Availability schedule card
                    InkCard(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(children: [
                              Container(
                                height: 34, width: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: InkColors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child:  Icon(Icons.calendar_month_rounded, size: 17, color: InkColors.foreground),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text("availability_schedule".tr,
                                  style: robotoSemiBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground)),
                              ),
                              const SizedBox(width: 8),
                              JustTheTooltip( backgroundColor: Colors.black87, controller: tooltipController,
                                preferredDirection: AxisDirection.down, tailLength: 14, tailBaseWidth: 20,
                                content: Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                  child:  Text("service_availability_hint_text".tr, style: robotoRegular.copyWith(color: Colors.white,)),
                                ),
                                child:  InkWell( onTap: ()=> tooltipController.showTooltip(),
                                  child:  Icon(Icons.info_outline_rounded, color: InkColors.mutedForeground, size: 18,),
                                ),
                              )
                            ],),
                          ),

                           SizedBox(height: 1, child: ColoredBox(color: InkColors.border)),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                            child: InkEyebrow("service_providing_time".tr),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [

                                Text("from".tr, style: robotoMedium.copyWith(fontSize: 13, color: InkColors.foreground)),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                                TimePickerWidget(
                                  title: 'open_time'.tr,
                                  time: businessSettingController.serviceStartTime,
                                  onTimeChanged: (time){
                                    businessSettingController.setServiceStartTime = time;
                                  },
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                                Text("till".tr, style: robotoMedium.copyWith(fontSize: 13, color: InkColors.foreground)),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                                TimePickerWidget(
                                  title: 'close_time'.tr, time: businessSettingController.serviceEndTime,
                                  onTimeChanged: (time) =>businessSettingController.setServiceEndTime = time,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                           SizedBox(height: 1, child: ColoredBox(color: InkColors.border)),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                            child: InkEyebrow("weekend".tr),
                          ),

                          GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 40,
                            ),
                            itemBuilder: (context,index){
                            return InkWell(
                              onTap: ()=>businessSettingController.toggleDaysCheckedValue(index),
                              child: CustomCheckBox(title:  businessSettingController.daysList[index],
                                value: businessSettingController.daysCheckList[index],
                                onTap: ()=>businessSettingController.toggleDaysCheckedValue(index),
                              ),
                            );
                          },itemCount: businessSettingController.daysList.length,
                            shrinkWrap: true,
                            physics : const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),

                          const SizedBox(height: 16),

                        ]),
                      ),
                    ),

                    const SizedBox(height: 4),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            CustomButton(btnTxt: "save_information".tr,
              onPressed: () {
                final tutorialData = Get.find<UserProfileController>().providerModel?.content?.providerInfo?.tutorialData;

                if(tutorialData?[AppConstants.serviceAvailabilityTutorialKey]?.contains('0') ?? true) {
                  Get.find<TutorialController>().updateTutorial(key: AppConstants.serviceAvailabilityTutorialKey);
                }

                businessSettingController.updateServiceAvailabilitySettingsIntoServer();
              },
              isLoading: businessSettingController.isLoading,
            )
          ],
        ),
      );
    });
  }
}
