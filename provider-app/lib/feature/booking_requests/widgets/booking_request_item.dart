import 'package:jassdbx_provider/helper/booking_helper.dart';
import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class BookingRequestItem extends StatelessWidget {
  final BookingRequestModel booking;
  const BookingRequestItem({
    super.key, required this.booking,});

  @override
  Widget build(BuildContext context) {

    final String serviceName = booking.subCategory?.name ?? "";
    final String code = "#${booking.readableId ?? ""}";
    final String bookingTypeLabel = booking.isRepeatBooking == 1 ? "repeat_booking".tr : "regular_booking".tr;
    final DateTime? schedule = _scheduleOf(booking);
    final bool isPending = (booking.bookingStatus ?? "") == "pending";

    return InkCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => _openBookingDetails(booking),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkAvatar(name: serviceName.isNotEmpty ? serviceName : "${'booking'.tr} $code", size: 40),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            serviceName.isNotEmpty ? serviceName : "${'booking'.tr} $code",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(fontSize: 14, height: 1.3, color: InkColors.foreground),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          code,
                          maxLines: 1,
                          style: robotoRegular.copyWith(fontSize: 10, height: 1.3, color: InkColors.mutedForeground),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bookingTypeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(fontSize: 12.5, height: 1.3, color: InkColors.mutedForeground),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              InkStatusChip(status: booking.bookingStatus ?? ""),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            decoration:  BoxDecoration(
              border: Border(top: BorderSide(color: InkColors.border)),
            ),
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    schedule != null
                        ? "${DateConverter.dateStringMonthYear(schedule, format: 'd MMM, y')} · ${DateConverter.convertDateTimeToTime(schedule)}"
                        : "-",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: 12, height: 1.3, color: InkColors.mutedForeground),
                  ),
                ),
                InkMoney(
                  booking.totalBookingAmount ?? 0,
                  style:  TextStyle(fontSize: 15, height: 1.2, color: InkColors.foreground),
                ),
              ],
            ),
          ),

          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CardActionButton(
                    label: 'accept'.tr,
                    solid: true,
                    onTap: () => _acceptBooking(booking),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CardActionButton(
                    label: 'Decline',
                    solid: false,
                    onTap: () => _declineBooking(booking),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  DateTime? _scheduleOf(BookingRequestModel booking){
    try{
      final String? currentSchedule = BookingHelper.getRepeatBookingCurrentSchedule(booking);
      final DateTime? parsed = currentSchedule != null ? DateTime.tryParse(currentSchedule) : null;
      if(parsed != null) return parsed;
    }catch(_){}
    try{
      if(booking.createdAt != null) return DateConverter.isoUtcStringToLocalDate(booking.createdAt!);
    }catch(_){}
    return null;
  }

  void _openBookingDetails(BookingRequestModel booking){
    if(booking.isRepeatBooking == 1){
      Get.toNamed(RouteHelper.getRepeatBookingDetailsRoute(bookingId : booking.id!));
    }else{
      Get.toNamed(RouteHelper.getBookingDetailsRoute(bookingId : booking.id!));
    }
  }

  void _acceptBooking(BookingRequestModel booking){
    if(Get.find<UserProfileController>().isSubscriptionRequired && Get.find<UserProfileController>().providerModel?.content?.subscriptionInfo?.subscribedPackageDetails?.isCanceled == 1){
      showCustomSnackBar("your_subscription_plan_has_been_cancelled_you_will_not_able_to_accept_any_booking_request".tr, type : ToasterMessageType.info);
    }else{
      Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial){
        if(isTrial){
          showCustomDialog(child:  ConfirmationDialog(
            noButtonColor: Theme.of(Get.context!).colorScheme.error,
            noTextColor: Colors.white,
            yesButtonColor: Theme.of(Get.context!).primaryColor,
            title: "want_accept_this_booking?".tr,
            icon: Images.servicemanImage,
            description: 'accept_booking_hint_text'.tr,
            onYesPressed: (){
              Get.find<BookingDetailsController>().acceptBookingRequest(booking.id!);
              Get.back();
            },
            onNoPressed: () => Get.back(),
          ));
        }
      });
    }
  }

  void _declineBooking(BookingRequestModel booking){
    showCustomDialog(child:  ConfirmationDialog(
      yesButtonColor: Theme.of(Get.context!).primaryColor,
      title: "are_you_sure_to_ignore_the_booking_request".tr,
      description: "once_you_ignore_the_request",
      noButtonColor: Theme.of(Get.context!).colorScheme.error,
      noTextColor: Colors.white,
      icon: Images.warning,
      noButtonText: "cancel",
      onYesPressed: () {
        Get.find<BookingDetailsController>().ignoreBookingRequest(booking.id!);
        Get.back();
      },
      onNoPressed: () => Get.back(),
    ),);
  }
}

class _CardActionButton extends StatelessWidget {
  final String label;
  final bool solid;
  final VoidCallback onTap;

  const _CardActionButton({required this.label, required this.solid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: solid ? InkColors.foreground : InkColors.card,
          borderRadius: BorderRadius.circular(50),
          border: solid ? null : Border.all(color: InkColors.border),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: robotoSemiBold.copyWith(fontSize: 12, height: 1.2, color: solid ? InkColors.background : InkColors.foreground),
        ),
      ),
    );
  }
}
