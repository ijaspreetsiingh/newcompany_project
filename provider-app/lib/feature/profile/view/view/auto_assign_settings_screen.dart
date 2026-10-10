import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Dedicated Auto-Assign settings screen (opened directly from Profile screen).
/// UI only — logic same _AutoAssignCardWidget jaisa (UserProfileController).
class AutoAssignSettingsScreen extends StatelessWidget {
  const AutoAssignSettingsScreen({super.key});

  static String _formatWaitTime(int seconds) {
    if (seconds < 60) return '$seconds ${'seconds'.tr}';
    final int minutes = seconds ~/ 60;
    final int rem = seconds % 60;
    return rem == 0 ? '$minutes ${'minutes'.tr}' : '$minutes ${'minutes'.tr} $rem ${'seconds'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<UserProfileController>(builder: (userProfileController) {
          // profile se latest values sync karo (sirf pehli baar)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProfileController.initAutoAssignSettings();
          });

          final bool autoAssignOn = userProfileController.autoAssignMode;
          final int waitTime = userProfileController.autoAssignWaitTime;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              InkTopBar(
                title: 'auto_assign_settings'.tr,
                onBack: () => Get.back(),
                right: const InkIconButton(icon: Icons.more_horiz),
              ),

              const SizedBox(height: 16),

              /// Main toggle card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(
                            child: Text('auto_assign_mode'.tr,
                              style: robotoSemiBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground)),
                          ),
                          userProfileController.autoAssignLoading
                              ?  SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: InkColors.foreground))
                               : Switch.adaptive(
                                  value: autoAssignOn,
                                  activeTrackColor: InkColors.foreground,
                                  inactiveTrackColor: InkColors.accent,
                                  thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
                                  onChanged: (bool value) {
                                    if (value && !autoAssignOn) {
                                      // ON karne se pehle wait time confirm karo
                                      showWaitTimeDialog(context, userProfileController, waitTime);
                                    } else if (!value) {
                                      userProfileController.toggleAutoAssignMode(false);
                                    }
                                  },
                                ),
                        ]),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        child: Text(
                          autoAssignOn ? 'auto_assign_mode_on_hint'.tr : 'auto_assign_mode_off_hint'.tr,
                          style: robotoRegular.copyWith(fontSize: 12, height: 1.5, color: InkColors.mutedForeground),
                          textAlign: TextAlign.justify,
                        ),
                      ),

                       SizedBox(height: 1, child: ColoredBox(color: InkColors.border)),

                      /// Wait time section (toggle ON hone par active)
                      Opacity(
                        opacity: autoAssignOn ? 1.0 : 0.5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${'wait_time'.tr}: ${_formatWaitTime(waitTime)}',
                              style: robotoSemiBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground)),
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
                              style: robotoRegular.copyWith(fontSize: 12, height: 1.5, color: InkColors.mutedForeground),
                              textAlign: TextAlign.justify,
                            ),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// Info box — how it works
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: InkColors.secondary,
                    border: Border.all(color: InkColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                       Icon(Icons.info_outline_rounded, size: 17, color: InkColors.foreground),
                      const SizedBox(width: 8),
                      Text('how_it_works'.tr,
                        style: robotoSemiBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground)),
                    ]),
                    const SizedBox(height: 12),

                    _infoRow('auto_assign_info_on'.tr),
                    _infoRow('auto_assign_info_off'.tr),
                    _infoRow('auto_assign_info_timeout'.tr, isLast: true),
                  ]),
                ),
              ),

              const SizedBox(height: 20),
            ]),
          );
        }),
      ),
    );
  }

  /// Toggle ON karne se pehle wait time selection dialog (dono jagah se call hota hai)
  static void showWaitTimeDialog(BuildContext context, UserProfileController controller, int currentWaitTime) {
    int selected = currentWaitTime;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: InkColors.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('select_wait_time_title'.tr,
                style: robotoSemiBold.copyWith(fontSize: 16, color: InkColors.foreground)),
            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('wait_time_dialog_hint'.tr,
                  style: robotoRegular.copyWith(fontSize: 12, height: 1.5, color: InkColors.mutedForeground)),
              const SizedBox(height: 16),
              Center(
                child: Text(_formatWaitTime(selected),
                    style: robotoBold.copyWith(fontSize: 18, color: InkColors.foreground)),
              ),
              Slider(
                min: 30,
                max: 600,
                divisions: 19,
                value: selected.clamp(30, 600).toDouble(),
                activeColor: InkColors.foreground,
                inactiveColor: InkColors.accent,
                thumbColor: InkColors.foreground,
                onChanged: (double value) => setDialogState(() => selected = value.round()),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final int secs in const [30, 60, 120, 300, 600])
                    InkWell(
                      onTap: () => setDialogState(() => selected = secs),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected == secs ? InkColors.foreground : InkColors.secondary,
                          border: Border.all(color: InkColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatWaitTime(secs),
                          style: robotoMedium.copyWith(
                              fontSize: 12,
                              color: selected == secs ? Colors.white : InkColors.foreground),
                        ),
                      ),
                    ),
                ],
              ),
            ]),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('cancel'.tr, style: robotoMedium.copyWith(color: InkColors.mutedForeground)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  controller.enableAutoAssign(selected);
                },
                child: Text('confirm'.tr, style: robotoMedium.copyWith(color: InkColors.foreground)),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _infoRow(String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          height: 6, width: 6,
          decoration:  BoxDecoration(
            shape: BoxShape.circle,
            color: InkColors.foreground,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
            style: robotoRegular.copyWith(
              fontSize: 12,
              color: InkColors.mutedForeground,
              height: 1.5,
            ),
          ),
        ),
      ]),
    );
  }
}
