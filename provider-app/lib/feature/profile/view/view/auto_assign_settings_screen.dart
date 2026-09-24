import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Dedicated Auto-Assign settings screen (opened directly from Profile screen).
/// UI only — logic same _AutoAssignCardWidget jaisa (UserProfileController).
class AutoAssignSettingsScreen extends StatelessWidget {
  const AutoAssignSettingsScreen({super.key});

  String _formatWaitTime(int seconds) {
    if (seconds < 60) return '$seconds ${'seconds'.tr}';
    final int minutes = seconds ~/ 60;
    final int rem = seconds % 60;
    return rem == 0 ? '$minutes ${'minutes'.tr}' : '$minutes ${'minutes'.tr} $rem ${'seconds'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'auto_assign_settings'.tr),
      body: GetBuilder<UserProfileController>(builder: (userProfileController) {
        // profile se latest values sync karo (sirf pehli baar)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          userProfileController.initAutoAssignSettings();
        });

        final bool autoAssignOn = userProfileController.autoAssignMode;
        final int waitTime = userProfileController.autoAssignWaitTime;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(children: [

            /// Main toggle card
            Container(
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
                      : Switch.adaptive(
                          value: autoAssignOn,
                          activeTrackColor: Theme.of(context).primaryColor,
                          onChanged: (bool value) => userProfileController.toggleAutoAssignMode(value),
                        ),
                ]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(autoAssignOn
                    ? 'auto_assign_mode_on_hint'.tr
                    : 'auto_assign_mode_off_hint'.tr,
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                /// Wait time section (toggle ON hone par active)
                Opacity(
                  opacity: autoAssignOn ? 1.0 : 0.5,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${'wait_time'.tr}: ${_formatWaitTime(waitTime)}',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

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
                ),
              ]),
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            /// Info card — how it works
            Container(
              decoration: BoxDecoration(
                boxShadow: context.customThemeColors.lightShadow,
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text('how_it_works'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                _infoRow(context, 'auto_assign_info_on'.tr),
                _infoRow(context, 'auto_assign_info_off'.tr),
                _infoRow(context, 'auto_assign_info_timeout'.tr),
              ]),
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),
          ]),
        );
      }),
    );
  }

  Widget _infoRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          height: 6, width: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Text(text.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ),
      ]),
    );
  }
}
