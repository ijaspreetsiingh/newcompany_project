import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

/// Completed booking history me "Recheck" card.
///
/// Customer yahan se 15 din tak recheck raise kar sakta hai;
/// uske baad serviceman wapas jakar dobara check karega.
class RecheckSectionWidget extends StatelessWidget {
  const RecheckSectionWidget({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'expired':
        return Get.theme.colorScheme.error;
      case 'in_progress':
        return Colors.orange;
      default:
        return Get.theme.colorScheme.primary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'recheck_completed'.tr;
      case 'expired':
        return 'recheck_expired'.tr;
      case 'in_progress':
        return 'recheck_in_progress'.tr;
      default:
        return 'recheck_requested'.tr;
    }
  }

  void _showRequestDialog(BuildContext context, BookingDetailsController controller, String bookingId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault)),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('request_recheck'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'recheck_dialog_message'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            CustomTextField(
              controller: reasonController,
              maxLines: 3,
              capitalization: TextCapitalization.sentences,
              hintText: 'describe_your_problem'.tr,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Row(children: [
              Expanded(
                child: CustomButton(
                  buttonText: 'cancel'.tr,
                  backgroundColor: Theme.of(context).hintColor.withValues(alpha: 0.15),
                  textColor: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: CustomButton(
                  isLoading: controller.isRequestingRecheck,
                  buttonText: 'submit'.tr,
                  onPressed: () async {
                    Get.back();
                    await controller.requestRecheck(
                      bookingId: bookingId,
                      reason: reasonController.text.trim(),
                    );
                  },
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (controller) {
        final String status = controller.recheckStatus;
        final bool hasActiveRecheck = status == 'requested' || status == 'in_progress';
        final bool canRequest = controller.canRequestRecheck && !hasActiveRecheck;
        final Map<String, dynamic>? info = controller.recheckInfo;

        if (!hasActiveRecheck && !canRequest && status.isEmpty) {
          return const SizedBox.shrink();
        }

        if (hasActiveRecheck || status == 'completed' || status == 'expired') {
          final String? dueAt = info?['due_at'] is String ? info!['due_at'] as String? : null;
          final String? note = info?['serviceman_note'] is String ? info!['serviceman_note'] as String? : null;

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: _statusColor(status).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: _statusColor(status).withValues(alpha: 0.35)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.replay_rounded, size: 18, color: _statusColor(status)),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Expanded(
                  child: Text(
                    _statusLabel(status),
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: _statusColor(status),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                status == 'in_progress'
                    ? 'recheck_in_progress_message'.tr
                    : status == 'requested'
                        ? 'recheck_requested_message'.tr
                        : status == 'completed'
                            ? 'recheck_completed_message'.tr
                            : 'recheck_expired_message'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              if (dueAt != null && (status == 'requested' || status == 'in_progress')) ...[
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  '${'recheck_due_by'.tr}: ${DateConverter.dateMonthYearTimeTwentyFourFormat(DateConverter.isoUtcStringToLocalDate(dueAt))}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
              if (note != null && note.isNotEmpty) ...[
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  '${'serviceman_note'.tr}: $note',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ],
            ]),
          );
        }

        if (canRequest) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'facing_problem_after_service'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                '${'recheck_window_message'.tr} (${controller.recheckDaysLeft} ${'days_left'.tr})',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomButton(
                buttonText: 'request_recheck'.tr,
                height: 40,
                fontSize: Dimensions.fontSizeDefault,
                onPressed: controller.isRequestingRecheck
                    ? null
                    : () => _showRequestDialog(context, controller, controller.bookingDetailsContent?.id ?? ''),
              ),
            ]),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
