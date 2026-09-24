import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingSetupTabItemWidget extends StatelessWidget {
  const BookingSetupTabItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessSettingController>(builder: ( businessSettingController){

      final config = Get.find<SplashController>().configModel.content;

      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column( children: [

                  Container(
                    decoration: BoxDecoration(
                      boxShadow: context.customThemeColors.lightShadow,
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('booking_requirest_setup'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                            SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Text('here_you_can_setup_for_service_man_where_hint'.tr, style: robotoRegular.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                            )),
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      ListView.builder(
                        itemBuilder: (context, index){
                          final config = Get.find<SplashController>().configModel.content;
                          final item = businessSettingController.settingItem[index];

                          bool isDisabled = false;
                          switch (item.settingTitle) {
                            case 'Cancel Booking Request':
                              isDisabled = !(config?.canServiceManCancelBooking ?? true);
                              break;
                            case 'Edit Booking Request':
                              isDisabled = !(config?.canServiceManEditBooking ?? true);
                              break;
                            default:
                              isDisabled = false;
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              IgnorePointer(
                                ignoring: isDisabled,
                                child: Opacity(
                                  opacity: isDisabled ? 0.5 : 1.0,
                                  child: SwitchButton(
                                    titleText: businessSettingController.settingItem[index].settingTitle!,
                                    value: businessSettingController.settingItem[index].settingsValue!,
                                    onTap: (bool value) {
                                      businessSettingController.toggleSettingsValue(index , value == true ? 1 : 0);
                                    },
                                    // tooltipController: businessSettingController.settingItem[index].toolTipController!,
                                    tootTipText: '',
                                    showOutSideBorder: true,
                                    titleTextStyle: robotoMedium,

                                  ),
                                ),
                              ),
                              SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Text((businessSettingController.settingItem[index].toolTipText ?? '').tr,
                                style: robotoRegular.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    fontSize: Dimensions.fontSizeSmall + 1,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              SizedBox(height: Dimensions.paddingSizeDefault),

                            ]),
                          );

                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: businessSettingController.settingItem.length,
                      ),
                    ]),
                  ),




                  SizedBox(height: Dimensions.paddingSizeSmall),

                  _AutoAssignCardWidget(),

                  SizedBox(height: Dimensions.paddingSizeSmall),

                  config?.serviceAtProviderPlace == 1 ? Container(
                    decoration: BoxDecoration(
                      boxShadow: context.customThemeColors.lightShadow,
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('service_location'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text('service_location_business_setting_hint'.tr,
                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
                      ),
                      SizedBox(height: Dimensions.paddingSizeDefault),

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),

                        child: Column(children: [

                          _CheckBoxWidget(
                            title: "customer_location",
                            subTitle: "by_check_this_option_you_will_able_to_provide_service_at_customer_location",
                            value: businessSettingController.isActiveServiceInCustomerLocation,
                            onChanged: (bool? newValue) {
                              if(!businessSettingController.isActiveServiceInProviderLocation &&  businessSettingController.isActiveServiceInCustomerLocation){
                               showCustomSnackBar("you_can_not_disable_both_option_at_a_time".tr);
                              }else{
                                businessSettingController.updateServiceLocationValue(value: (newValue ?? false));
                              }

                            },
                          ),

                          Opacity(
                            opacity: config?.serviceAtProviderPlace == 1 ? 1.0 :  0.5,
                            child: _CheckBoxWidget(
                              title: "your_location",
                              subTitle: "by_check_this_option_you_will_able_to_provide_service_at_business_location",
                              value: businessSettingController.isActiveServiceInProviderLocation,
                              onChanged: (bool? newValue) {
                                if(config?.serviceAtProviderPlace == 1){
                                  if(!businessSettingController.isActiveServiceInCustomerLocation &&  businessSettingController.isActiveServiceInProviderLocation){
                                    showCustomSnackBar("you_can_not_disable_both_option_at_a_time".tr);
                                  }else{
                                    businessSettingController.updateServiceLocationValue(value: (newValue ?? false), isCustomerLocation: false);
                                  }
                                }else{
                                  showCustomSnackBar("admin_has_disable_this_option".tr);
                                }
                              },
                            ),
                          ),

                        ]),
                      ),
                    ]),
                  ) : SizedBox()

                ]),
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault,),

            CustomButton(btnTxt: "update_settings".tr,
              onPressed: ()=> businessSettingController.updateBookingSettingsIntoServer(),
              isLoading: businessSettingController.isLoading,
            )
          ],
        ),
      );
    });
  }
}

class _AutoAssignCardWidget extends StatelessWidget {
  const _AutoAssignCardWidget();

  String _formatWaitTime(int seconds) {
    if (seconds < 60) return '$seconds ${'seconds'.tr}';
    final int minutes = seconds ~/ 60;
    final int rem = seconds % 60;
    return rem == 0 ? '$minutes ${'minutes'.tr}' : '$minutes ${'minutes'.tr} $rem ${'seconds'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (userProfileController) {

      // profile se latest values sync karo (sirf pehli baar)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        userProfileController.initAutoAssignSettings();
      });

      final bool autoAssignOn = userProfileController.autoAssignMode;
      final int waitTime = userProfileController.autoAssignWaitTime;

      return Container(
        decoration: BoxDecoration(
          boxShadow: context.customThemeColors.lightShadow,
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text('auto_assign_mode'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))),

            userProfileController.autoAssignLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                :            Switch.adaptive(
                    value: autoAssignOn,
                    activeTrackColor: Theme.of(context).primaryColor,
                    onChanged: (bool value) => userProfileController.toggleAutoAssignMode(value),
                  ),
          ]),
          SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Text(autoAssignOn
              ? 'auto_assign_mode_on_hint'.tr
              : 'auto_assign_mode_off_hint'.tr,
            style: robotoRegular.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: Dimensions.paddingSizeDefault),

          Text('${'wait_time'.tr}: ${_formatWaitTime(waitTime)}',
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Slider(
            min: 30,
            max: 600,
            divisions: 19,
            value: waitTime.toDouble().clamp(30, 600),
            activeColor: Theme.of(context).primaryColor,
            onChanged: (double value) {
              userProfileController.autoAssignWaitTimeLocal = value.round();
            },
            onChangeEnd: (double value) {
              userProfileController.updateAutoAssignWaitTime(value.round());
            },
          ),

          Text('auto_assign_wait_time_hint'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.justify,
          ),
        ]),
      );
    });
  }
}

class _CheckBoxWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _CheckBoxWidget({ required this.title, required this.subTitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row( crossAxisAlignment: CrossAxisAlignment.start, children: [

        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
            width: 1,
            color: states.contains(WidgetState.selected)
                ? Theme.of(context).primaryColor
                : Colors.grey, // Use your desired border color
          )),
        ),

        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 5, children: [
            Text(title.tr, style: value ? robotoMedium : robotoRegular),

            Text(subTitle.tr, style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              height: 1.5,
            )),
          ]),
        )),

        SizedBox(width: Dimensions.paddingSizeDefault)
      ]),
    );
  }
}

