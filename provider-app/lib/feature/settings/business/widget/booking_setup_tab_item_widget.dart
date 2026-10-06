import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/profile/view/view/auto_assign_settings_screen.dart';
import 'package:get/get.dart';

class BookingSetupTabItemWidget extends StatelessWidget {
  const BookingSetupTabItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessSettingController>(builder: ( businessSettingController){

      final config = Get.find<SplashController>().configModel.content;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column( children: [

                  InkCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('booking_requirest_setup'.tr, style: robotoSemiBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground)),
                              const SizedBox(height: 4),

                              Text('here_you_can_setup_for_service_man_where_hint'.tr, style: robotoRegular.copyWith(
                                fontSize: 12,
                                height: 1.5,
                                color: InkColors.mutedForeground,
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

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
                            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              if (index != 0)  SizedBox(height: 1, child: ColoredBox(color: InkColors.border)),

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

                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                                child: Text((businessSettingController.settingItem[index].toolTipText ?? '').tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: InkColors.mutedForeground,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),

                            ]);

                          },
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: businessSettingController.settingItem.length,
                        ),
                      ]),
                    ),
                  ),




                  const SizedBox(height: 12),

                  _AutoAssignCardWidget(),

                  const SizedBox(height: 12),

                  config?.serviceAtProviderPlace == 1 ? InkCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('service_location'.tr, style: robotoSemiBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground)),
                      const SizedBox(height: 4),
                      Text('service_location_business_setting_hint'.tr,
                        style: robotoRegular.copyWith(fontSize: 12, height: 1.5, color: InkColors.mutedForeground),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: InkColors.secondary,
                          border: Border.all(color: InkColors.border),
                          borderRadius: BorderRadius.circular(12),
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

      return InkCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text('auto_assign_mode'.tr, style: robotoSemiBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground))),

            userProfileController.autoAssignLoading
                ?  SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: InkColors.foreground))
                :            Switch.adaptive(
                    value: autoAssignOn,
                    activeTrackColor: InkColors.foreground,
                    inactiveTrackColor: InkColors.accent,
                    thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
                    onChanged: (bool value) {
                      if (value && !autoAssignOn) {
                        // ON karne se pehle wait time confirm karo
                        AutoAssignSettingsScreen.showWaitTimeDialog(context, userProfileController, waitTime);
                      } else if (!value) {
                        userProfileController.toggleAutoAssignMode(false);
                      }
                    },
                  ),
          ]),
          const SizedBox(height: 6),

          Text(autoAssignOn
              ? 'auto_assign_mode_on_hint'.tr
              : 'auto_assign_mode_off_hint'.tr,
            style: robotoRegular.copyWith(
              fontSize: 12,
              height: 1.5,
              color: InkColors.mutedForeground,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 12),

          Text('${'wait_time'.tr}: ${_formatWaitTime(waitTime)}',
            style: robotoSemiBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground),
          ),
          const SizedBox(height: 6),

          Slider(
            min: 30,
            max: 600,
            divisions: 19,
            value: waitTime.toDouble().clamp(30, 600),
            activeColor: InkColors.foreground,
            inactiveColor: InkColors.accent,
            thumbColor: InkColors.foreground,
            onChanged: (double value) {
              userProfileController.autoAssignWaitTimeLocal = value.round();
            },
            onChangeEnd: (double value) {
              userProfileController.updateAutoAssignWaitTime(value.round());
            },
          ),

          Text('auto_assign_wait_time_hint'.tr,
            style: robotoRegular.copyWith(
              fontSize: 12,
              height: 1.5,
              color: InkColors.mutedForeground,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row( crossAxisAlignment: CrossAxisAlignment.start, children: [

          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: InkColors.foreground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
              width: 1,
              color: states.contains(WidgetState.selected)
                  ? InkColors.foreground
                  : InkColors.mutedForeground,
            )),
          ),

          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 5, children: [
              Text(title.tr, style: robotoSemiBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground)),

              Text(subTitle.tr, style: robotoRegular.copyWith(
                fontSize: 12,
                color: InkColors.mutedForeground,
                height: 1.5,
              )),
            ]),
          )),
        ]),
      ),
    );
  }
}
