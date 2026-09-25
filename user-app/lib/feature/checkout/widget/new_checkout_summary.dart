import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class NewCheckoutSummary extends StatelessWidget {
  const NewCheckoutSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckOutController>(builder: (checkoutController) {
      return GetBuilder<ScheduleController>(builder: (scheduleController) {
        return GetBuilder<CartController>(builder: (cartController) {
          int scheduleDaysCount = scheduleController.scheduleDaysCount > 0 ? scheduleController.scheduleDaysCount : 1;
          ConfigModel configModel = Get.find<SplashController>().configModel;
          List<CartModel> cartList = cartController.cartList;
          bool walletPaymentStatus = cartController.walletPaymentStatus;
          int applicableCouponCount = CheckoutHelper.getNumberOfDaysForApplicableCoupon(pickedScheduleDays: scheduleDaysCount) ?? 1;
          double additionalCharge = CheckoutHelper.getAdditionalCharge();
          bool isPartialPayment = CheckoutHelper.checkPartialPayment(walletBalance: cartController.walletBalance, bookingAmount: cartController.totalPrice);
          double paidAmount = CheckoutHelper.calculatePaidAmount(walletBalance: cartController.walletBalance, bookingAmount: cartController.totalPrice);
          double subTotalPrice = CheckoutHelper.calculateSubTotal(cartList: cartList, daysCount: scheduleDaysCount);
          double disCount = CheckoutHelper.calculateDiscount(cartList: cartList, discountType: DiscountType.general, daysCount: scheduleDaysCount);
          double campaignDisCount = CheckoutHelper.calculateDiscount(cartList: cartList, discountType: DiscountType.campaign, daysCount: scheduleDaysCount);
          double couponDisCount = CheckoutHelper.calculateDiscount(cartList: cartList, discountType: DiscountType.coupon, daysCount: applicableCouponCount);
          double referDisCount = cartController.referralAmount;
          double vat = CheckoutHelper.calculateVat(cartList: cartList, daysCount: scheduleDaysCount);
          double grandTotal = CheckoutHelper.calculateGrandTotal(cartList: cartList, referralDiscount: referDisCount, daysCount: scheduleDaysCount);
          double dueAmount = CheckoutHelper.calculateDueAmount(cartList: cartList, walletPaymentStatus: walletPaymentStatus, walletBalance: cartController.walletBalance, bookingAmount: cartController.totalPrice, referralDiscount: referDisCount, daysCount: scheduleDaysCount);

          cartController.updateTotalPrice = grandTotal;

          return Container(
            margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                  'order_summary'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Service Items
                ListView.builder(
                  itemCount: cartList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    double totalCost = (cartList.elementAt(index).serviceCost.toDouble() * cartList.elementAt(index).quantity) * scheduleDaysCount;
                    return _buildServiceItem(
                      cartList.elementAt(index),
                      totalCost,
                      scheduleDaysCount,
                      context,
                    );
                  },
                ),

                const Divider(height: 32),

                // Price Breakdown
                _buildPriceRow('sub_total'.tr, subTotalPrice, context),
                if (disCount > 0) _buildPriceRow('discount'.tr, disCount, context, isDiscount: true),
                if (campaignDisCount > 0) _buildPriceRow('campaign_discount'.tr, campaignDisCount, context, isDiscount: true),
                if (couponDisCount > 0) _buildPriceRow('coupon_discount'.tr, couponDisCount, context, isDiscount: true),
                if (referDisCount > 0) _buildPriceRow('referral_discount'.tr, referDisCount, context, isDiscount: true),
                _buildPriceRow('vat'.tr, vat, context),
                if (configModel.content?.additionalCharge == 1 && configModel.content?.additionalChargeLabelName != "")
                  _buildPriceRow(configModel.content?.additionalChargeLabelName ?? '', additionalCharge, context),

                const Divider(height: 24),

                // Grand Total
                _buildPriceRow('grand_total'.tr, grandTotal, context, isBold: true, isTotal: true),

                if (walletPaymentStatus) ...[
                  const SizedBox(height: 8),
                  _buildPriceRow('paid_by_wallet'.tr, paidAmount, context, isDiscount: true),
                ],
                if (walletPaymentStatus && isPartialPayment) ...[
                  const SizedBox(height: 8),
                  _buildPriceRow('due_amount'.tr, dueAmount, context, isBold: true),
                ],

                const SizedBox(height: Dimensions.paddingSizeDefault),

                ConditionCheckBox(
                  checkBoxValue: checkoutController.acceptTerms,
                  onTap: (bool? value) {
                    checkoutController.toggleTerms();
                  },
                ),
              ],
            ),
          );
        });
      });
    });
  }

  Widget _buildServiceItem(CartModel cart, double totalCost, int daysCount, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: CustomImage(
              height: 60,
              width: 60,
              image: cart.service?.thumbnailFullPath ?? '',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          // Service Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cart.service?.name ?? '',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  cart.variantKey,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${cart.quantity} x ${PriceConverter.convertPrice(cart.serviceCost.toDouble())}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Total Price
          Text(
            PriceConverter.convertPrice(totalCost),
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: const Color(0xFFF57C21),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String title, double price, BuildContext context, {bool isBold = false, bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: (isBold || isTotal)
                ? robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.black,
                  )
                : robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.black54,
                  ),
          ),
          Text(
            isDiscount ? '-${PriceConverter.convertPrice(price)}' : PriceConverter.convertPrice(price),
            style: (isBold || isTotal)
                ? robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: isTotal ? const Color(0xFFF57C21) : Colors.black,
                  )
                : robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: isDiscount ? const Color(0xFF4CAF50) : Colors.black,
                  ),
          ),
        ],
      ),
    );
  }
}
