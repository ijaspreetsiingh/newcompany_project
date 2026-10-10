import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class PaymentStatusButton extends StatelessWidget {
  const PaymentStatusButton({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingEditController>(builder: (bookingEditController){

      final BookingDetailsContent? bookingDetails = Get.find<BookingDetailsController>().bookingDetails?.bookingContent?.bookingDetailsContent;
      final String method = bookingDetails?.paymentMethod?.tr ?? '';
      final String state = bookingEditController.paymentStatusPaid ? 'paid'.tr : 'unpaid'.tr;
      final String subtitle = method.isNotEmpty ? '$method · $state' : state;

      return KCard(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("payment_status".tr.trimRight(),
                style: robotoMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: context.kForeground),
              ),
              const SizedBox(height: 2),
              Text(subtitle,
                style: robotoRegular.copyWith(fontSize: 12, color: context.kMutedForeground),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          KButton(
            label: bookingEditController.paymentStatusPaid ? 'paid'.tr : 'mark_paid'.tr,
            outline: true,
            height: 32,
            expanded: false,
            onTap: () => bookingEditController.togglePaymentStatus(),
          ),
        ]),
      );
    });
  }
}
