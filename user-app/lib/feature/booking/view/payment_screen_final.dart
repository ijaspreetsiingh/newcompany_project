import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jdds/util/core_export.dart';
import 'package:universal_html/html.dart' as html;

/// New design checkout step 2: Payment method selection + place booking
/// Real data: CheckOutController (payment methods from config + placeBookingRequest API),
/// CartController (prices), ScheduleController (schedule), LocationController (address)
class PaymentScreenFinal extends StatefulWidget {
  const PaymentScreenFinal({super.key});

  @override
  State<PaymentScreenFinal> createState() => _PaymentScreenFinalState();
}

class _PaymentScreenFinalState extends State<PaymentScreenFinal> {
  @override
  void initState() {
    super.initState();

    final CheckOutController checkoutController = Get.find<CheckOutController>();
    final ConfigModel configModel = Get.find<SplashController>().configModel;

    // Real payment methods from server config (cash after service / wallet / digital / offline)
    checkoutController.getPaymentMethodList(
      shouldUpdate: false,
      avoidPartialPayment:
          configModel.content?.partialPayment == 0 || configModel.content?.partialPaymentCombinator == null,
    );

    if (configModel.content?.offlinePayment == 1) {
      checkoutController.getOfflinePaymentMethod(false, shouldUpdate: false);
    }

    // Auto select first available method (same as old flow behaviour)
    checkoutController.changePaymentMethod(shouldUpdate: false);
  }

  AddressModel? _getSelectedAddress() {
    final FriendLocationController friendController =
        Get.find<FriendLocationController>();
    // Friend/relative location booking active ho to wahi address book hoga.
    if (friendController.isBookingForOther) {
      return friendController.selectedFriendAddress;
    }
    final LocationController locationController = Get.find<LocationController>();
    return CheckoutHelper.selectedAddressModel(
      selectedAddress: locationController.selectedAddress,
      pickedAddress: locationController.getUserAddress(),
      selectedLocationType: locationController.selectedServiceLocationType,
    );
  }

  void _onPlaceBooking() {
    final CheckOutController checkoutController = Get.find<CheckOutController>();
    final CartController cartController = Get.find<CartController>();
    final ScheduleController scheduleController = Get.find<ScheduleController>();
    final ConfigModel configModel = Get.find<SplashController>().configModel;

    final AddressModel? addressModel = _getSelectedAddress();

    if (cartController.cartList.isEmpty) {
      customSnackBar('your_cart_is_empty'.tr, type: ToasterMessageType.info);
      return;
    }

    if (scheduleController.selectedServiceType == ServiceType.repeat &&
        scheduleController.scheduleTime == null &&
        scheduleController.pickedDailyRepeatBookingDateRange == null &&
        scheduleController.pickedWeeklyRepeatBookingDateRange == null &&
        scheduleController.pickedCustomRepeatBookingDateTimeList.isEmpty) {
      customSnackBar('select_your_preferable_booking_time'.tr, type: ToasterMessageType.info);
      return;
    }

    if (addressModel == null) {
      customSnackBar('add_address_first'.tr, type: ToasterMessageType.info);
      return;
    }

    if ((addressModel.contactPersonName == null ||
            addressModel.contactPersonName!.isEmpty ||
            addressModel.contactPersonName == 'null') ||
        (addressModel.contactPersonNumber == null ||
            addressModel.contactPersonNumber!.isEmpty ||
            addressModel.contactPersonNumber == 'null')) {
      customSnackBar('please_input_contact_person_name_and_phone_number'.tr, type: ToasterMessageType.info);
      return;
    }

    String? schedule = scheduleController.scheduleTime;
    bool isPartialPayment = CheckoutHelper.checkPartialPayment(
      walletBalance: cartController.walletBalance,
      bookingAmount: cartController.totalPrice,
    );

    if (scheduleController.selectedServiceType == ServiceType.repeat) {
      // Repeat booking me bhi user ka selected payment method respect karo —
      // pehle cash_after_service hardcoded tha
      if (checkoutController.selectedPaymentMethod == PaymentMethodName.none) {
        customSnackBar('select_payment_method'.tr, type: ToasterMessageType.info);
        return;
      }
      if (checkoutController.selectedPaymentMethod == PaymentMethodName.cos) {
        checkoutController.placeBookingRequest(
          paymentMethod: "cash_after_service",
          schedule: schedule,
          isPartial: isPartialPayment && cartController.walletPaymentStatus ? 1 : 0,
          address: addressModel,
          fromNewFlow: true,
        );
      } else if (checkoutController.selectedPaymentMethod == PaymentMethodName.walletMoney) {
        final bool walletHasEnoughBalance =
            cartController.walletBalance >= (cartController.totalPrice * (scheduleController.scheduleDaysCount > 0 ? scheduleController.scheduleDaysCount : 1));
        if (!walletHasEnoughBalance) {
          customSnackBar('insufficient_wallet_balance'.tr, type: ToasterMessageType.info);
          return;
        }
        checkoutController.placeBookingRequest(
          paymentMethod: "wallet_payment",
          schedule: schedule,
          isPartial: 0,
          address: addressModel,
          fromNewFlow: true,
        );
      } else {
        customSnackBar('repeat_booking_cash_or_wallet_only'.tr, type: ToasterMessageType.info);
      }
      return;
    }

    if (checkoutController.selectedPaymentMethod == PaymentMethodName.none) {
      customSnackBar('select_payment_method'.tr, type: ToasterMessageType.info);
      return;
    }

    if (checkoutController.selectedPaymentMethod == PaymentMethodName.cos) {
      checkoutController.placeBookingRequest(
        paymentMethod: "cash_after_service",
        schedule: schedule ?? '',
        isPartial: isPartialPayment && cartController.walletPaymentStatus ? 1 : 0,
        address: addressModel,
        fromNewFlow: true,
      );
    } else if (checkoutController.selectedPaymentMethod == PaymentMethodName.walletMoney) {
      checkoutController.placeBookingRequest(
        paymentMethod: "wallet_payment",
        schedule: schedule ?? '',
        isPartial: isPartialPayment && cartController.walletPaymentStatus ? 1 : 0,
        address: addressModel,
        fromNewFlow: true,
      );
    } else if (checkoutController.selectedPaymentMethod == PaymentMethodName.offline) {
      if (checkoutController.selectedOfflineMethod == null) {
        customSnackBar('provide_offline_payment_info'.tr, type: ToasterMessageType.info);
        return;
      }
      double bookingAmount =
          isPartialPayment ? (cartController.totalPrice - cartController.walletBalance) : cartController.totalPrice;
      int selectedIndex = checkoutController.offlinePaymentModelList
          .indexOf(checkoutController.selectedOfflineMethod!);
      checkoutController.placeBookingRequest(
        paymentMethod: "offline_payment",
        schedule: schedule ?? '',
        isPartial: isPartialPayment && cartController.walletPaymentStatus ? 1 : 0,
        address: addressModel,
        offlinePaymentId: checkoutController.selectedOfflineMethod?.id,
        selectedOfflinePaymentIndex: selectedIndex != -1 ? selectedIndex : 0,
        bookingAmount: bookingAmount,
        fromNewFlow: true,
      );
    } else if (checkoutController.selectedPaymentMethod == PaymentMethodName.digitalPayment) {
      if (checkoutController.selectedDigitalPaymentMethod != null &&
          checkoutController.selectedDigitalPaymentMethod?.gateway != "offline") {
        _makeDigitalPayment(addressModel, checkoutController.selectedDigitalPaymentMethod, isPartialPayment,
            checkoutController, configModel);
      } else {
        customSnackBar('select_any_payment_method'.tr, type: ToasterMessageType.info);
      }
    }
  }

  /// Same digital payment redtrect as old flow (proceed_to_checkout_button_widget)
  void _makeDigitalPayment(AddressModel? address, DigitalPaymentMethod? paymentMethod, bool isPartialPayment,
      CheckOutController checkoutController, ConfigModel configModel) {
    String url = '';
    SignUpBody? newUserInfo = CheckoutHelper.getNewUserInfo(
      address: address,
      password: checkoutController.passwordController.text,
      isCheckedCreateAccount: checkoutController.isCheckedCreateAccount,
    );

    String? schedule = Get.find<ScheduleController>().scheduleTime;
    String userId = Get.find<UserController>().userInfoModel?.id ?? Get.find<SplashController>().getGuestId();
    String encodedAddress = base64Encode(utf8.encode(jsonEncode(address?.toJson())));
    String encodedNewUserInfo = base64Encode(utf8.encode(jsonEncode(newUserInfo?.toJson())));

    String addressId = (address?.id == "null" || address?.id == null) ? "" : address?.id ?? "";
    // Zone: booking (friend/dusra) address ka zone — payment gateway wahi
    // zone ka service price calculate kare.
    final String addressZone = (address?.zoneId != null &&
            address!.zoneId!.isNotEmpty &&
            address.zoneId != 'null')
        ? address.zoneId!
        : "";
    String zoneId = addressZone.isNotEmpty
        ? addressZone
        : (Get.find<LocationController>().getUserAddress()?.zoneId ?? "");
    // Friend booking hamesha customer location par hoti hai.
    String serviceLocation = Get.find<FriendLocationController>().isBookingForOther
        ? ServiceLocationType.customer.name
        : Get.find<LocationController>().selectedServiceLocationType.name;
    String callbackUrl = ResponsiveHelper.isWeb() ? '' : AppConstants.baseUrl;
    int isPartial = Get.find<CartController>().walletPaymentStatus && isPartialPayment ? 1 : 0;
    String platform = ResponsiveHelper.isWeb() ? "web" : "app";

    url = '${AppConstants.baseUrl}/payment?payment_method=${paymentMethod?.gateway}&access_token=${base64Url.encode(utf8.encode(userId))}&zone_id=$zoneId'
        '&service_schedule=$schedule&service_address_id=$addressId&callback=$callbackUrl'
        '&service_address=$encodedAddress&new_user_info=$encodedNewUserInfo&is_partial=$isPartial'
        '&payment_platform=$platform&service_location=$serviceLocation';

    if (GetPlatform.isWeb) {
      html.window.open(url, "_self");
    } else {
      Get.to(() => PaymentScreen(url: url, fromPage: "checkout"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge!.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'payment'.tr,
          style: robotoBold.copyWith(fontSize: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<CheckOutController>(builder: (checkoutController) {
        return GetBuilder<ScheduleController>(builder: (scheduleController) {
          return GetBuilder<CartController>(builder: (cartController) {
            final AddressModel? addressModel = _getSelectedAddress();

            final int daysCount = scheduleController.scheduleDaysCount;
            final double subTotal = CheckoutHelper.calculateSubTotal(
              cartList: cartController.cartList,
              daysCount: daysCount,
            );
            final double vat = CheckoutHelper.calculateVat(
              cartList: cartController.cartList,
              daysCount: daysCount,
            );
            final double couponDiscount = CheckoutHelper.calculateDiscount(
              cartList: cartController.cartList,
              discountType: DiscountType.coupon,
              daysCount: daysCount,
            );
            final double amountToPay = cartController.totalPrice;
            final FriendLocationController friendController =
                Get.find<FriendLocationController>();
            // Friend zone ka server total (provider sync hone tak estimate).
            final double displayAmountToPay = friendController.displayTotal(
              cartList: cartController.cartList,
              serverTotal: amountToPay,
              daysCount: daysCount,
            );
            final bool zoneEstimateMode = friendController.showZoneEstimate;
            final double displaySubTotal =
                zoneEstimateMode && friendController.isBookingForOther
                    ? (friendController.zoneSubtotalFor(
                          cartList: cartController.cartList,
                          daysCount: daysCount,
                        ) ??
                        subTotal)
                    : subTotal;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Indicator - STEP 2/3
                  _buildProgressIndicator(2),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // Booking Mint Card (real schedule + address)
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary, size: 24),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'service_appointment'.tr.toUpperCase(),
                                style: robotoSmall.copyWith(fontSize: 10, color: Colors.black54),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _scheduleText(scheduleController),
                                style: robotoBold.copyWith(
                                    fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color),
                              ),
                              Text(
                                addressModel?.address ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoSmall.copyWith(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // Payment Methods (from server config)
                  Text(
                    'select_payment_method'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Cash after service
                  if (checkoutController.othersPaymentList
                      .any((method) => method.paymentMethodName == PaymentMethodName.cos)) ...[
                    _buildPaymentOption(
                      context,
                      PaymentMethodName.cos,
                      Icons.wallet,
                      'cash_after_service'.tr,
                      'pay_after_service'.tr,
                      checkoutController,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Wallet
                  if (checkoutController.othersPaymentList
                      .any((method) => method.paymentMethodName == PaymentMethodName.walletMoney)) ...[
                    _buildPaymentOption(
                      context,
                      PaymentMethodName.walletMoney,
                      Icons.account_balance_wallet,
                      'pay_via_wallet'.tr,
                      '${'available_balance'.tr}: ${PriceConverter.convertPrice(cartController.walletBalance)}',
                      checkoutController,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Digital payment gateways (from config)
                  for (DigitalPaymentMethod digitalMethod in checkoutController.digitalPaymentList
                      .where((method) => method.gateway != "offline")) ...[
                    _buildDigitalPaymentOption(context, digitalMethod, checkoutController),
                    const SizedBox(height: 8),
                  ],

                  // Offline payment
                  if (checkoutController.digitalPaymentList.any((method) => method.gateway == "offline") &&
                      checkoutController.offlinePaymentModelList.isNotEmpty) ...[
                    _buildPaymentOption(
                      context,
                      PaymentMethodName.offline,
                      Icons.receipt_long,
                      'offline_payment'.tr,
                      'pay_via_offline_methods'.tr,
                      checkoutController,
                    ),
                    const SizedBox(height: 8),
                  ],

                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // Price Summary (real cart data)
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Theme.of(context).cardColor : Colors.grey[50],
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Column(
                      children: [
                        if (friendController.isBookingForOther) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              color: primaryAccent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.groups_2_outlined, size: 16, color: primaryAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    zoneEstimateMode ? 'zone_price_note'.tr : 'friend_location'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: primaryAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('item_total'.tr,
                                style: robotoRegular.copyWith(fontSize: 14, color: Colors.black54)),
                            Text(PriceConverter.convertPrice(displaySubTotal),
                                style: robotoMedium.copyWith(
                                    fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('vat'.tr, style: robotoRegular.copyWith(fontSize: 14, color: Colors.black54)),
                            Text(PriceConverter.convertPrice(vat),
                                style: robotoMedium.copyWith(
                                    fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color)),
                          ],
                        ),
                        if (couponDiscount > 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('coupon_discount'.tr,
                                  style: robotoRegular.copyWith(
                                      fontSize: 14, color: Theme.of(context).colorScheme.primary)),
                              Text('-${PriceConverter.convertPrice(couponDiscount)}',
                                  style: robotoMedium.copyWith(
                                      fontSize: 14, color: Theme.of(context).colorScheme.primary)),
                            ],
                          ),
                        ],
                        if (CheckoutHelper.shouldShowAdditionalCharge()) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  CheckoutHelper.getAdditionalChargeLabel(),
                                  style: robotoRegular.copyWith(fontSize: 14, color: Colors.black54)),
                              Text(PriceConverter.convertPrice(CheckoutHelper.getAdditionalCharge()),
                                  style: robotoMedium.copyWith(
                                      fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color)),
                            ],
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('amount_to_pay'.tr,
                                style: robotoBold.copyWith(
                                    fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color)),
                            Text(PriceConverter.convertPrice(displayAmountToPay),
                                style: robotoBold.copyWith(fontSize: 16, color: primaryAccent)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // Place Booking Button (real API: placeBookingRequest)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: checkoutController.isLoading ? null : _onPlaceBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                      child: checkoutController.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              'place_booking'.tr,
                              style: robotoBold.copyWith(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            );
          });
        });
      }),
    );
  }

  String _scheduleText(ScheduleController scheduleController) {
    if (scheduleController.selectedServiceType == ServiceType.repeat) {
      return 'repeat_booking'.tr;
    }
    if (scheduleController.selectedScheduleType == ScheduleType.asap) {
      return 'as_soon_as_possible'.tr;
    }
    final String? scheduleTime = scheduleController.scheduleTime;
    if (scheduleTime == null || scheduleTime.isEmpty) {
      return 'as_soon_as_possible'.tr;
    }
    try {
      final DateTime schedule = DateFormat('yyyy-MM-dd HH:mm:ss').parse(scheduleTime);
      return '${DateFormat('d MMM, yyyy').format(schedule)}, ${DateFormat('h:mm a').format(schedule)}';
    } catch (_) {
      return scheduleTime;
    }
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildProgressStep(1, 'schedule'.tr, currentStep >= 1),
          Container(width: 30, height: 2, color: Colors.grey[300]),
          _buildProgressStep(2, 'payment'.tr, currentStep >= 2),
          Container(width: 30, height: 2, color: Colors.grey[300]),
          _buildProgressStep(3, 'confirmed'.tr, currentStep >= 3),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label, bool active) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? primaryAccent : Colors.grey[300],
            ),
            child: Center(
              child: active
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      step.toString(),
                      style: robotoBold.copyWith(color: Colors.grey[600]),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: robotoSmall.copyWith(
              fontSize: 10,
              color: active ? primaryAccent : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    PaymentMethodName value,
    IconData icon,
    String title,
    String subtitle,
    CheckOutController checkoutController,
  ) {
    bool isSelected = checkoutController.selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () => checkoutController.changePaymentMethod(
        cashAfterService: value == PaymentMethodName.cos,
        walletPayment: value == PaymentMethodName.walletMoney,
        offlinePaymentModel: value == PaymentMethodName.offline
            ? (checkoutController.selectedOfflineMethod ??
                (checkoutController.offlinePaymentModelList.isNotEmpty
                    ? checkoutController.offlinePaymentModelList.first
                    : null))
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: isSelected ? primaryAccent : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryAccent : Colors.grey[600], size: 24),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: robotoBold.copyWith(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: robotoSmall.copyWith(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            _radioIndicator(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalPaymentOption(
    BuildContext context,
    DigitalPaymentMethod digitalMethod,
    CheckOutController checkoutController,
  ) {
    bool isSelected = checkoutController.selectedPaymentMethod == PaymentMethodName.digitalPayment &&
        checkoutController.selectedDigitalPaymentMethod?.gateway == digitalMethod.gateway;

    return GestureDetector(
      onTap: () => checkoutController.changePaymentMethod(digitalMethod: digitalMethod),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: isSelected ? primaryAccent : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (digitalMethod.gatewayImageFullPath != null &&
                digitalMethod.gatewayImageFullPath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  digitalMethod.gatewayImageFullPath!,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.credit_card, color: isSelected ? primaryAccent : Colors.grey[600]),
                ),
              )
            else
              Icon(Icons.credit_card, color: isSelected ? primaryAccent : Colors.grey[600], size: 24),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Text(
                digitalMethod.label ?? digitalMethod.gateway ?? 'digital_payment'.tr,
                style: robotoBold.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
            _radioIndicator(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _radioIndicator(bool isSelected) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? primaryAccent : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: isSelected
          ? Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryAccent,
              ),
            )
          : null,
    );
  }
}


