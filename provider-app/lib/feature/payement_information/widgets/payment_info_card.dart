import 'package:jassdbx_provider/feature/payement_information/controller/payment_info_controller.dart';
import 'package:jassdbx_provider/feature/payement_information/model/payment_method_list_model.dart';
import 'package:jassdbx_provider/feature/payement_information/widgets/method_popup_button_widget.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class PaymentInfoCard extends StatelessWidget {
  final PaymentMethodItem? paymentMethod;
  final int? index;
  const PaymentInfoCard({super.key, this.index, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    return InkCard(
      padding: const EdgeInsets.all(16),
      child: GetBuilder<PaymentInfoController>(
          builder: (paymentInfoController) {

            return Column(mainAxisSize: MainAxisSize.min, children: [

              Row(children: [

                Text(paymentMethod?.methodName ?? '', style: robotoSemiBold.copyWith(
                  fontSize: 14, height: 1.3, color: InkColors.foreground,
                )),
                const SizedBox(width: 8),

                if((paymentMethod?.isDefault ?? false) && index != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: InkColors.foreground,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text('default'.tr, style: robotoMedium.copyWith(
                      fontSize: 10,
                      height: 1.2,
                      letterSpacing: 0.6,
                      color: InkColors.background,
                    )),
                  ),

                const Spacer(),

               if(index != null) MethodPopupButtonWidget(paymentMethod: paymentMethod, index: index),

              ]),

              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: InkColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    String inputFieldKey = paymentMethod?.methodFieldData?.keys.elementAt(index) ?? '';
                    String inputFieldValue = paymentMethod?.methodFieldData?.values.elementAt(index) ?? 'N/A';
                    return _InfoItemWidget(
                      label: inputFieldKey.tr,
                      info: inputFieldValue.tr,
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemCount: paymentMethod?.methodFieldData?.length ?? 0,
                ),
              ),
            ]);
          }
      ),
    );
  }
}


class _InfoItemWidget extends StatelessWidget {
  final String? label;
  final String? info;
  const _InfoItemWidget({this.label, this.info});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
      Text(label ?? '', style: robotoRegular.copyWith(
        fontSize: Dimensions.fontSizeSmall,
        color: InkColors.mutedForeground,
      )),

      Text(' : ', style: robotoRegular.copyWith(
        fontSize: Dimensions.fontSizeSmall,
        color: InkColors.mutedForeground,
      )),

      Flexible(
        child: Text(info ?? '', style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: InkColors.foreground,
        )),
      ),
    ]);
  }
}
