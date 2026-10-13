import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:jassdbx_serviceman/feature/booking_details/widget/start_otp_sheet.dart';

/// SPEC (redesigned): serviceman ke paas free status dropdown NAHI hoga.
///
/// - accepted (abhi pahuncha nahi): [I Have Reached Customer Location]
///     → backend 300m check karta hai → start OTP generate
///     → TURANT OTP popup khulta hai → OTP verify hote hi status
///       auto 'ongoing' ho jaata hai.
/// - accepted (start OTP aa chuka hai): [Start Service OTP] → popup dobara.
/// - ongoing: sirf [Complete Service] + [Cancel] — baaki status
///   serviceman apne aap nahi badal sakta.
class StatusChangeDropdownButton extends StatelessWidget {
  final String bookingId;
  final BookingDetailsContent bookingDetails;
  final bool isSubBooking;
  const StatusChangeDropdownButton({
    super.key,
    required this.bookingId,
    required this.bookingDetails,
    required this.isSubBooking,
  });

  void _openStartOtpSheet() {
    Get.bottomSheet(
      StartOtpVerificationSheet(
        bookingId: bookingDetails.id.toString(),
        isSubBooking: isSubBooking,
      ),
    );
  }

  Future<void> _markReached(BookingDetailsController controller) async {
    final bool ok = await controller.markReached(
      bookingDetails.id.toString(),
      isSubBooking: isSubBooking,
    );
    // Reached (300m) → start OTP generated → seedha OTP popup.
    // Submit hote hi backend status 'ongoing' set karega.
    if (ok) {
      _openStartOtpSheet();
    }
  }

  /// Complete flow (pehle dropdown ke "completed" branch me tha) — config ke
  /// hisaab se: payment dialog / photo evidence / OTP sheet.
  void _startCompletionFlow(BookingDetailsController controller) {
    final content = Get.find<SplashController>().configModel?.content;
    final bool imageVerify = content?.bookingImageVerification == 1;
    final bool otpVerify = content?.bookingOtpVerification == 1;
    final bool hasPhotos = controller.pickedPhotoEvidence.isNotEmpty;

    // UI gate: "Request for OTP" button tabhi dikhe jab pending state ho.
    controller.setSelectedValue('completed');

    if (imageVerify && hasPhotos && otpVerify) {
      controller.changePhotoEvidenceStatus(status: true);
    } else if (imageVerify && hasPhotos && !otpVerify) {
      // Photo ready (image-only config) → seedha submit.
      controller.changeBookingStatus(
        bookingId: bookingDetails.id.toString(),
        bookingStatus: 'completed',
        isSubBooking: isSubBooking,
      );
    } else if (imageVerify) {
      controller.changePhotoEvidenceStatus(status: true);
      showCustomBottomSheet(
        child: CameraButtonSheet(bookingId: bookingId, isSubBooking: isSubBooking),
      );
    } else if (otpVerify) {
      controller.changePhotoEvidenceStatus(status: true);
    } else {
      controller.changePhotoEvidenceStatus(status: false);
      Get.bottomSheet(
        PaymentReceiveDialog(
          bookingDetails.id!,
          bookingDetails.totalBookingAmount.toString(),
          isSubBooking: isSubBooking,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        final String status = bookingDetails.bookingStatus ?? '';
        final bool canCancel =
            bookingDetailsController.statusTypeList.contains('canceled');
        final bool otpVerify = Get.find<SplashController>()
                .configModel
                ?.content
                ?.bookingOtpVerification ==
            1;

        // Pending completion (OTP wala rasta chal raha hai).
        final bool pendingOtpSubmission =
            bookingDetailsController.dropDownValue == 'completed' &&
                bookingDetailsController.showPhotoEvidenceField &&
                otpVerify;

        final bool isUpdating = bookingDetailsController.isUpdate;

        if (status == 'accepted') {
          final bool notReached = bookingDetails.startOtp == null ||
              bookingDetails.startOtp!.isEmpty;
          return _ActionBar(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isUpdating
                    ? const _InlineLoader()
                    : SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          btnTxt: notReached
                              ? 'i_have_reached'.tr
                              : 'start_otp_verification'.tr,
                          onPressed: notReached
                              ? () => _markReached(bookingDetailsController)
                              : _openStartOtpSheet,
                        ),
                      ),
                if (canCancel) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: KButton(
                      label: 'cancel'.tr,
                      outline: true,
                      destructive: true,
                      onTap: isUpdating
                          ? null
                          : () => bookingDetailsController.changeBookingStatus(
                                bookingId: bookingDetails.id.toString(),
                                bookingStatus: 'canceled',
                                isSubBooking: isSubBooking,
                              ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        if (status == 'ongoing') {
          return _ActionBar(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (pendingOtpSubmission)
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      btnTxt: 'request_for_otp'.tr,
                      onPressed: () {
                        bookingDetailsController.sendBookingOTPNotification(
                          bookingId,
                          shouldUpdate: false,
                        );
                        Get.bottomSheet(
                          OtpVerificationBottomSheet(
                            bookingId: bookingId,
                            isSubBooking: isSubBooking,
                          ),
                        );
                      },
                    ),
                  )
                else if (isUpdating)
                  const _InlineLoader()
                else
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      btnTxt: 'complete_service'.tr,
                      onPressed: () =>
                          _startCompletionFlow(bookingDetailsController),
                    ),
                  ),
                if (canCancel) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: KButton(
                      label: 'cancel'.tr,
                      outline: true,
                      destructive: true,
                      onTap: (isUpdating || pendingOtpSubmission)
                          ? null
                          : () => bookingDetailsController.changeBookingStatus(
                                bookingId: bookingDetails.id.toString(),
                                bookingStatus: 'canceled',
                                isSubBooking: isSubBooking,
                              ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _ActionBar extends StatelessWidget {
  final Widget child;
  const _ActionBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: context.kBackground,
        border: Border(top: BorderSide(color: context.kBorder, width: 1)),
      ),
      child: child,
    );
  }
}

class _InlineLoader extends StatelessWidget {
  const _InlineLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Center(
        child: CircularProgressIndicator(
          color: context.kMutedForeground,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
