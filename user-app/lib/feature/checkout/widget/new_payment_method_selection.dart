import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class NewPaymentMethodSelection extends StatelessWidget {
  const NewPaymentMethodSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckOutController>(builder: (checkoutController) {
      return GetBuilder<CartController>(builder: (cartController) {
        double walletBalance = cartController.walletBalance;
        double bookingAmount = cartController.totalPrice;
        bool walletPaymentStatus = cartController.walletPaymentStatus;
        bool isPartialPayment = CheckoutHelper.checkPartialPayment(walletBalance: walletBalance, bookingAmount: bookingAmount);

        return Container(
          margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'payment_method'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Payment Methods
              if (checkoutController.othersPaymentList.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: checkoutController.othersPaymentList.length,
                  itemBuilder: (context, index) {
                    return _buildPaymentMethodCard(
                      checkoutController.othersPaymentList[index],
                      checkoutController,
                      walletBalance,
                      bookingAmount,
                      walletPaymentStatus,
                      isPartialPayment,
                      context,
                    );
                  },
                ),

              // Digital Payment Methods
              if (checkoutController.digitalPaymentList.isNotEmpty) ...[
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text(
                  'digital_payment'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: Dimensions.paddingSizeDefault,
                    crossAxisSpacing: Dimensions.paddingSizeDefault,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: checkoutController.digitalPaymentList.length,
                  itemBuilder: (context, index) {
                    return _buildDigitalPaymentCard(
                      checkoutController.digitalPaymentList[index],
                      checkoutController,
                      context,
                    );
                  },
                ),
              ],
            ],
          ),
        );
      });
    });
  }

  Widget _buildPaymentMethodCard(
    PaymentMethodButton paymentMethod,
    CheckOutController checkoutController,
    double walletBalance,
    double bookingAmount,
    bool walletPaymentStatus,
    bool isPartialPayment,
    BuildContext context,
  ) {
    bool isSelected = checkoutController.selectedPaymentMethod == paymentMethod.paymentMethodName;

    return GestureDetector(
      onTap: () {
        if (paymentMethod.paymentMethodName == PaymentMethodName.walletMoney) {
          if (walletBalance > 0) {
            checkoutController.changePaymentMethod(walletPayment: true);
          }
        } else if (paymentMethod.paymentMethodName == PaymentMethodName.cos) {
          checkoutController.changePaymentMethod(cashAfterService: true);
        } else if (paymentMethod.paymentMethodName == PaymentMethodName.offline) {
          // Handle offline payment
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF57C21).withValues(alpha:0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: isSelected ? const Color(0xFFF57C21) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF57C21) : Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Center(
                child: Image.asset(
                  paymentMethod.assetName,
                  width: 30,
                  height: 30,
                  color: isSelected ? Colors.white : null,
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            // Title and Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paymentMethod.title,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Colors.black,
                    ),
                  ),
                  if (paymentMethod.paymentMethodName == PaymentMethodName.walletMoney) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${PriceConverter.convertPrice(walletBalance)} ${'available'.tr}',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Radio Button
            RadioGroup<PaymentMethodName>(
              groupValue: checkoutController.selectedPaymentMethod,
              onChanged: (value) {
                if (paymentMethod.paymentMethodName == PaymentMethodName.walletMoney) {
                  if (walletBalance > 0) {
                    checkoutController.changePaymentMethod(walletPayment: true);
                  }
                } else if (paymentMethod.paymentMethodName == PaymentMethodName.cos) {
                  checkoutController.changePaymentMethod(cashAfterService: true);
                }
              },
              child: Radio<PaymentMethodName>(
                value: paymentMethod.paymentMethodName,
                activeColor: const Color(0xFFF57C21),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalPaymentCard(
    DigitalPaymentMethod paymentMethod,
    CheckOutController checkoutController,
    BuildContext context,
  ) {
    bool isSelected = checkoutController.selectedPaymentMethod == PaymentMethodName.digitalPayment &&
                       checkoutController.selectedDigitalPaymentMethod?.gateway == paymentMethod.gateway;

    return GestureDetector(
      onTap: () {
        checkoutController.changePaymentMethod(digitalMethod: paymentMethod);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF57C21).withValues(alpha:0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: isSelected ? const Color(0xFFF57C21) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Payment Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF57C21) : Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Center(
                child: Icon(
                  Icons.credit_card,
                  color: isSelected ? Colors.white : Colors.black54,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Payment Name
            Text(
              paymentMethod.label ?? '',
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
