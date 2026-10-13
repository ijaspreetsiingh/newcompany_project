import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

/// Completed booking me "Not satisfied with service" card.
///
/// Customer admin-set window (default 7 din) tak ye raise kar sakta hai.
/// Raise hote hi backend SAME serviceman ke paas FREE (amount 0) re-service
/// booking bana deta hai — ye card negative/service-recovery tone ka hai,
/// regular "Repeat" (paid re-booking) se ALAG.
class UnsatisfiedSectionWidget extends StatelessWidget {
  const UnsatisfiedSectionWidget({super.key});

  static const Color _tone = Color(0xFFB45309); // amber-700 — service recovery

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
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: _tone.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: _tone, size: 26),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text('request_unsatisfied'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'unsatisfied_dialog_message'.tr,
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
              hintText: 'what_went_wrong'.tr,
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
                  isLoading: controller.isRequestingUnsatisfied,
                  backgroundColor: _tone,
                  buttonText: 'submit'.tr,
                  onPressed: () async {
                    Get.back();
                    await controller.raiseUnsatisfied(
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
        final String status = controller.unsatisfiedStatus;
        final bool hasOpenRequest = status == 'requested';
        final bool canRaise = controller.canRaiseUnsatisfied && !hasOpenRequest;
        final Map<String, dynamic>? info = controller.unsatisfiedInfo;

        if (!hasOpenRequest && !canRaise) {
          return const SizedBox.shrink();
        }

        if (hasOpenRequest) {
          final String? dueAt = info?['due_at'] is String ? info!['due_at'] as String? : null;
          final String? reserviceId = info?['reservice_booking_id'] is String
              ? info!['reservice_booking_id'] as String?
              : null;

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: _tone.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: _tone.withValues(alpha: 0.4)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.engineering_outlined, size: 18, color: _tone),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Expanded(
                  child: Text(
                    're_service_requested'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: _tone),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                'unsatisfied_requested_message'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              if (dueAt != null) ...[
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  '${'re_service_due_by'.tr}: ${DateConverter.dateMonthYearTimeTwentyFourFormat(DateConverter.isoUtcStringToLocalDate(dueAt))}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
              if (reserviceId != null && reserviceId.isNotEmpty) ...[
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                CustomButton(
                  buttonText: 'view_re_service_booking'.tr,
                  height: 36,
                  fontSize: Dimensions.fontSizeExtraSmall,
                  onPressed: () => Get.toNamed(
                    RouteHelper.getBookingDetailsScreen(
                      bookingID: reserviceId,
                      fromPage: 'unsatisfied',
                    ),
                  ),
                ),
              ],
            ]),
          );
        }

        if (canRaise) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: _tone.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: _tone.withValues(alpha: 0.35)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.sentiment_dissatisfied_outlined, size: 20, color: _tone),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Expanded(
                  child: Text(
                    'not_satisfied_with_service'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: _tone),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                '${'unsatisfied_window_message'.tr} (${controller.unsatisfiedDaysLeft} ${'days_left'.tr})',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                'unsatisfied_free_note'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: _tone,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              OutlinedButton(
                onPressed: controller.isRequestingUnsatisfied
                    ? null
                    : () => _showRequestDialog(context, controller, controller.bookingDetailsContent?.id ?? ''),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  foregroundColor: _tone,
                  side: BorderSide(color: _tone.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                ),
                child: Text(
                  'request_free_re_service'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: _tone),
                ),
              ),
            ]),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
