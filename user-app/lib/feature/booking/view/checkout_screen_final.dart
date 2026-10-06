import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jdds/util/core_export.dart';

/// New design checkout step 1: Address + Schedule + Price summary
/// Real data: LocationController (addresses), ScheduleController (schedule),
/// CartController + CheckoutHelper (prices)
class CheckoutScreenFinal extends StatefulWidget {
  const CheckoutScreenFinal({super.key});

  @override
  State<CheckoutScreenFinal> createState() => _CheckoutScreenFinalState();
}

class _CheckoutScreenFinalState extends State<CheckoutScreenFinal> {
  int selectedDay = 0;
  String selectedTime = '10:00 AM';

  /// ASAP mode — jaldi possible service (config.instantBooking on hone par).
  bool _asapMode = false;

  /// Sirf ek baar screen entry par house-details popup.
  bool _housePopupShown = false;

  final List<String> timeSlots = [
    '8:00 AM', '10:00 AM', '12:00 PM', '2:00 PM', '4:00 PM', '6:00 PM',
  ];

  @override
  void initState() {
    super.initState();

    final locationController = Get.find<LocationController>();
    final cartController = Get.find<CartController>();
    final scheduleController = Get.find<ScheduleController>();

    // Real address list from server
    locationController.getAddressList(fromCheckout: true).then((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeShowHouseDetailsPopup();
      });
    });

    // Friend/relative (book for other location) history
    Get.find<FriendLocationController>().loadHistory();

    // Cart must be loaded for price summary
    if (cartController.cartList.isEmpty) {
      cartController.getCartListFromServer();
    }

    // Per-provider payment config prefetch (allowed gateways + booking fee)
    Get.find<CheckOutController>().fetchProviderPaymentConfig(
      cartController.cartList.isNotEmpty ? cartController.cartList.first.provider?.id : null,
    );

    // Pre-select saved schedule (if any) on day/time pickers
    _syncSelectionFromSchedule();

    // ASAP default sirf tab jab admin ne instant booking on rakhi ho.
    final bool instantBookingEnabled =
        Get.find<SplashController>().configModel.content?.instantBooking == 1;
    _asapMode = instantBookingEnabled &&
        scheduleController.selectedScheduleType == ScheduleType.asap;
  }

  /// Screen par aate hi: house details set nahi hai to popup, warna nahi.
  void _maybeShowHouseDetailsPopup() {
    if (_housePopupShown || !mounted) return;
    final LocationController locationController = Get.find<LocationController>();
    final AddressModel? addressModel = _currentAddress(locationController);
    if (!_houseDetailsMissing(addressModel)) return;

    _housePopupShown = true;
    _runHouseDetailsFlow(addressModel!).then((AddressModel? result) {
      if (result != null && mounted) {
        setState(() {});
      }
    });
  }

  bool _houseDetailsMissing(AddressModel? address) {
    if (address == null) return false;
    final String house = (address.house ?? '').trim();
    return house.isEmpty || house == 'null';
  }

  /// House details popup (tab jab missing ho). Confirm → in-memory selected
  /// address update + saved address server par persist. Cancel → null.
  Future<AddressModel?> _runHouseDetailsFlow(AddressModel addressModel) async {
    if (Get.find<LocationController>().selectedServiceLocationType !=
        ServiceLocationType.customer) {
      return addressModel;
    }
    if (!_houseDetailsMissing(addressModel)) return addressModel;
    if (!mounted) return addressModel;

    final AddressModel? confirmedAddress = await HomeDetailsPopup.show(
      context,
      address: addressModel,
    );
    if (confirmedAddress == null) return null;
    if (!mounted) return null;

    final LocationController locationController = Get.find<LocationController>();
    final FriendLocationController friendController =
        Get.find<FriendLocationController>();

    if (friendController.isBookingForOther) {
      // Friend address = user ka apna saved address nahi — sirf history update.
      friendController.updateHistoryEntry(confirmedAddress);
      return confirmedAddress;
    }

    locationController.updateSelectedAddress(confirmedAddress);

    final String addressId = confirmedAddress.id ?? '';
    if (addressId.isNotEmpty && addressId != 'null') {
      final ResponseModel saveResult = await locationController.updateAddress(
        confirmedAddress,
        addressId,
      );
      if (saveResult.isSuccess != true) {
        customSnackBar(
          'failed_to_save_address'.tr,
          type: ToasterMessageType.error,
        );
        return null;
      }
      await locationController.getAddressList(forceRefresh: true);
    }
    return confirmedAddress;
  }

  /// Friend booking active ho to friend address, warna normal saved address.
  AddressModel? _currentAddress(LocationController locationController) {
    final FriendLocationController friendController =
        Get.find<FriendLocationController>();
    if (friendController.isBookingForOther) {
      return friendController.selectedFriendAddress;
    }
    return CheckoutHelper.selectedAddressModel(
      selectedAddress: locationController.selectedAddress,
      pickedAddress: locationController.getUserAddress(),
      selectedLocationType: locationController.selectedServiceLocationType,
    );
  }

  void _syncSelectionFromSchedule() {
    final scheduleController = Get.find<ScheduleController>();
    final scheduleTime = scheduleController.scheduleTime;

    if (scheduleTime != null && scheduleTime.isNotEmpty) {
      try {
        final DateTime picked = DateFormat('yyyy-MM-dd HH:mm:ss').parse(scheduleTime);
        final int dayDiff = picked.difference(DateTime.now()).inDays;
        if (dayDiff >= 0 && dayDiff < 4) {
          selectedDay = dayDiff;
        }
        // normalise like slot values ("10:00 AM")
        String formatted = DateFormat('h:mm a').format(picked).toUpperCase();
        if (timeSlots.contains(formatted)) {
          selectedTime = formatted;
        }
      } catch (_) {}
    }
  }

  String _slotToTime(String slot) {
    final DateTime parsed = DateFormat('h:mm a').parse(slot);
    return DateFormat('HH:mm:ss').format(parsed);
  }

  void _applySchedule() {
    final scheduleController = Get.find<ScheduleController>();

    if (_asapMode) {
      // As soon as possible — earliest slot (now + 2 min) backend ko bheja jata hai.
      scheduleController.updateScheduleType(
        shouldUpdate: false,
        scheduleType: ScheduleType.asap,
      );
      scheduleController.buildSchedule(
        shouldUpdate: false,
        scheduleType: ScheduleType.asap,
      );
      return;
    }

    final DateTime date = DateTime.now().add(Duration(days: selectedDay));

    scheduleController.updateScheduleType(
      shouldUpdate: false,
      scheduleType: ScheduleType.schedule,
    );
    scheduleController.selectedDate = DateFormat('yyyy-MM-dd').format(date);
    scheduleController.selectedTime = _slotToTime(selectedTime);
    scheduleController.buildSchedule(scheduleType: ScheduleType.schedule);
  }

  void _onContinue() async {
    final locationController = Get.find<LocationController>();
    final scheduleController = Get.find<ScheduleController>();
    final cartController = Get.find<CartController>();

    if (cartController.cartList.isEmpty) {
      customSnackBar('your_cart_is_empty'.tr, type: ToasterMessageType.info);
      return;
    }

    AddressModel? addressModel = _currentAddress(locationController);

    if (addressModel == null) {
      customSnackBar('add_address_first'.tr, type: ToasterMessageType.info);
      return;
    }

    // House details set nahi hai to confirm karwao (ek hi jagah logic).
    final AddressModel? confirmedAddress = await _runHouseDetailsFlow(addressModel);
    if (!mounted) return;
    if (confirmedAddress == null) return;
    addressModel = confirmedAddress;

    if ((addressModel.contactPersonName == null ||
            addressModel.contactPersonName!.isEmpty ||
            addressModel.contactPersonName == 'null') ||
        (addressModel.contactPersonNumber == null ||
            addressModel.contactPersonNumber!.isEmpty ||
            addressModel.contactPersonNumber == 'null')) {
      customSnackBar(
        'please_input_contact_person_name_and_phone_number'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    _applySchedule();

    if (scheduleController.scheduleTime == null &&
        scheduleController.selectedScheduleType != ScheduleType.asap) {
      customSnackBar('select_your_preferable_booking_time'.tr, type: ToasterMessageType.info);
      return;
    }

    final configModel = Get.find<SplashController>().configModel;
    if (scheduleController.selectedScheduleType == ScheduleType.schedule &&
        configModel.content?.scheduleBookingTimeRestriction == 1 &&
        scheduleController.checkValidityOfTimeRestriction(configModel.content!.advanceBooking!) != null) {
      customSnackBar(scheduleController.checkValidityOfTimeRestriction(configModel.content!.advanceBooking!));
      return;
    }

    // Per-provider payment config (gateways + fee) payment step se pehle ready
    await Get.find<CheckOutController>().fetchProviderPaymentConfig(
      cartController.cartList.isNotEmpty ? cartController.cartList.first.provider?.id : null,
    );

    Get.toNamed(RouteHelper.getPaymentFinalRoute());
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
          'address_and_schedule'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<ScheduleController>(builder: (scheduleController) {
        return GetBuilder<LocationController>(builder: (locationController) {
          return GetBuilder<CartController>(builder: (cartController) {
            final FriendLocationController friendController =
                Get.find<FriendLocationController>();
            final AddressModel? selectedAddressModel =
                _currentAddress(locationController);

            final int daysCount = scheduleController.scheduleDaysCount;
            final double subTotal = CheckoutHelper.calculateSubTotal(
              cartList: cartController.cartList,
              daysCount: daysCount,
            );
            final double vat = CheckoutHelper.calculateVat(
              cartList: cartController.cartList,
              daysCount: daysCount,
            );
            final double discount = CheckoutHelper.calculateDiscount(
              cartList: cartController.cartList,
              discountType: DiscountType.general,
              daysCount: daysCount,
            );
            final double campaignDiscount = CheckoutHelper.calculateDiscount(
              cartList: cartController.cartList,
              discountType: DiscountType.campaign,
              daysCount: daysCount,
            );
            // Server side grand total (same as old checkout flow)
            final double amountToPay = cartController.totalPrice;

            // Friend ke zone ka price (provider sync se pehle estimate,
            // sync hone ke baad server ka re-priced total).
            final bool zoneEstimateMode = friendController.showZoneEstimate;
            final double displaySubTotal =
                zoneEstimateMode && friendController.isBookingForOther
                    ? (friendController.zoneSubtotalFor(
                          cartList: cartController.cartList,
                          daysCount: daysCount,
                        ) ??
                        subTotal)
                    : subTotal;
            final double displayAmountToPay = friendController.displayTotal(
              cartList: cartController.cartList,
              serverTotal: amountToPay,
              daysCount: daysCount,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Indicator - STEP 1/3
                  _buildProgressIndicator(1),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // ADDRESS SECTION
                  Text(
                    'service_address'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  ..._buildAddressList(context, locationController, selectedAddressModel),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // WHEN DO YOU NEED THE SERVICE (ASAP / Schedule toggle)
                  ..._buildWhenToServe(context),

                  if (!_asapMode) ...[
                  // CHOOSE DAY SECTION
                  Text(
                    'choose_a_day'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        DateTime date = DateTime.now().add(Duration(days: index));
                        String dayName = DateFormat('E').format(date);
                        String dayNumber = DateFormat('d').format(date);
                        bool isSelected = selectedDay == index;

                        return GestureDetector(
                          onTap: () => setState(() => selectedDay = index),
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryAccent : Colors.white,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              border: Border.all(
                                color: isSelected ? primaryAccent : Colors.grey[300]!,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayName,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: isSelected ? Colors.white : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dayNumber,
                                  style: robotoBold.copyWith(
                                    fontSize: 18,
                                    color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // PICK TIME SECTION
                  Text(
                    'pick_a_time'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedTime == timeSlots[index];
                      return GestureDetector(
                        onTap: () => setState(() => selectedTime = timeSlots[index]),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? primaryAccent : Colors.white,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(
                              color: isSelected ? primaryAccent : Colors.grey[300]!,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              timeSlots[index],
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  ],

                  // PRICE SUMMARY (real cart data)
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
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeSmall,
                            ),
                            margin: const EdgeInsets.only(
                              bottom: Dimensions.paddingSizeDefault,
                            ),
                            decoration: BoxDecoration(
                              color: primaryAccent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusSmall,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.groups_2_outlined,
                                    size: 16, color: primaryAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    zoneEstimateMode
                                        ? 'zone_price_note'.tr
                                        : 'friends_location_select'.tr,
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
                        _priceRow(context, 'subtotal'.tr, PriceConverter.convertPrice(displaySubTotal)),
                        const SizedBox(height: 12),
                        _priceRow(context, 'vat'.tr, PriceConverter.convertPrice(vat)),
                        if (discount > 0) ...[
                          const SizedBox(height: 12),
                          _priceRow(context, 'discount'.tr, '-${PriceConverter.convertPrice(discount)}',
                              valueColor: Colors.green),
                        ],
                        if (campaignDiscount > 0) ...[
                          const SizedBox(height: 12),
                          _priceRow(context, 'campaign_discount'.tr, '-${PriceConverter.convertPrice(campaignDiscount)}',
                              valueColor: Colors.green),
                        ],
                        GetBuilder<CheckOutController>(
                          builder: (_) => CheckoutHelper.shouldShowAdditionalCharge()
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: _priceRow(
                                    context,
                                    Get.find<SplashController>()
                                            .configModel
                                            .content
                                            ?.additionalChargeLabelName ??
                                        '',
                                    PriceConverter.convertPrice(
                                        CheckoutHelper.getAdditionalCharge()),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
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

                  // CONTINUE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                      child: Text(
                        'continue_to_payment'.tr,
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

  Widget _priceRow(BuildContext context, String title, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: robotoRegular.copyWith(fontSize: 14, color: Colors.black54)),
        Text(value,
            style: robotoMedium.copyWith(
                fontSize: 14, color: valueColor ?? Theme.of(context).textTheme.bodyLarge!.color)),
      ],
    );
  }

  /// ASAP (jaldi possible) vs Schedule (date/time) selector + hint.
  List<Widget> _buildWhenToServe(BuildContext context) {
    final bool instantBookingEnabled =
        Get.find<SplashController>().configModel.content?.instantBooking == 1;

    return [
      Text(
        'choose_booking_time'.tr,
        style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).textTheme.bodyLarge!.color,
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),
      Row(
        children: [
          if (instantBookingEnabled) ...[
            Expanded(
              child: _whenChip(
                context,
                asap: true,
                selected: _asapMode,
                icon: Icons.bolt,
                label: 'as_soon_as_possible'.tr,
                onTap: () {
                  if (_asapMode) return;
                  setState(() => _asapMode = true);
                  final ScheduleController scheduleController =
                      Get.find<ScheduleController>();
                  scheduleController.updateScheduleType(
                    shouldUpdate: false,
                    scheduleType: ScheduleType.asap,
                  );
                  scheduleController.buildSchedule(
                    shouldUpdate: false,
                    scheduleType: ScheduleType.asap,
                  );
                },
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
          ],
          Expanded(
            child: _whenChip(
              context,
              asap: false,
              selected: !_asapMode,
              icon: Icons.calendar_month_outlined,
              label: 'schedule'.tr,
              onTap: () {
                if (!_asapMode) return;
                setState(() => _asapMode = false);
                Get.find<ScheduleController>().updateScheduleType(
                  shouldUpdate: false,
                  scheduleType: ScheduleType.schedule,
                );
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Row(
          children: [
            Icon(
              _asapMode ? Icons.bolt : Icons.schedule,
              size: 18,
              color: primaryAccent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _asapMode ? 'asap_arrival_hint'.tr : 'schedule_later_hint'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),
    ];
  }

  Widget _whenChip(
    BuildContext context, {
    required bool asap,
    required bool selected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected ? primaryAccent : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: selected ? primaryAccent : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: selected ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  IconData _addressIcon(AddressModel address) {
    switch ((address.addressType ?? address.addressLabel ?? '').toLowerCase()) {
      case 'office':
      case 'business':
        return Icons.business;
      case 'home':
        return Icons.home;
      default:
        return Icons.location_on;
    }
  }

  List<Widget> _buildAddressList(
    BuildContext context,
    LocationController locationController,
    AddressModel? selectedAddressModel,
  ) {
    List<Widget> widgets = [];
    final List<AddressModel> addressList = locationController.addressList ?? [];

    if (selectedAddressModel != null) {
      widgets.add(
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: primaryAccent, width: 2),
          ),
          child: Row(
            children: [
              Icon(_addressIcon(selectedAddressModel), color: primaryAccent, size: 24),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (selectedAddressModel.addressLabel ??
                              selectedAddressModel.addressType ??
                              'address')
                          .tr,
                      style:
                          robotoBold.copyWith(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedAddressModel.address ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: robotoSmall.copyWith(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Other saved addresses (tap to switch)
    for (AddressModel address in addressList) {
      if (selectedAddressModel != null && address.id == selectedAddressModel.id) continue;
      widgets.add(const SizedBox(height: Dimensions.paddingSizeSmall));
      widgets.add(
        GestureDetector(
          onTap: () async {
            final FriendLocationController friendController =
                Get.find<FriendLocationController>();
            if (friendController.isBookingForOther) {
              await friendController.clearFriendSelection();
            }
            bool isSuccess = await locationController.setAddressIndex(address, fromAddressScreen: false);
            if (isSuccess && mounted) {
              setState(() {});
            }
          },
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(_addressIcon(address), color: Colors.grey[600], size: 24),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (address.addressLabel ?? address.addressType ?? 'address').tr,
                        style: robotoMedium.copyWith(
                            fontSize: 14, color: Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.address ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: robotoSmall.copyWith(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final FriendLocationController friendController =
        Get.find<FriendLocationController>();
    if (friendController.isBookingForOther) {
      widgets.add(const SizedBox(height: Dimensions.paddingSizeSmall));
      widgets.add(
        GestureDetector(
          onTap: () => friendController.clearFriendSelection().then(
                (_) => mounted ? setState(() {}) : null,
              ),
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: primaryAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: primaryAccent, width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.groups_2_outlined, color: primaryAccent, size: 24),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'friend_location'.tr,
                        style: robotoBold.copyWith(fontSize: 14, color: primaryAccent),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        friendController.selectedFriendAddress?.address ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: robotoSmall.copyWith(
                            fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  'use_my_address'.tr,
                  style: robotoMedium.copyWith(
                      fontSize: 12, color: primaryAccent),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Saved friend/relative locations (history) — one tap par reuse.
    final List<AddressModel> friendHistory = friendController.history;
    if (friendHistory.isNotEmpty && !friendController.isBookingForOther) {
      widgets.add(const SizedBox(height: Dimensions.paddingSizeSmall));
      widgets.add(
        Text(
          'saved_friend_locations'.tr,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Colors.black54,
          ),
        ),
      );
      widgets.add(const SizedBox(height: Dimensions.paddingSizeSmall));
      widgets.add(
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: friendHistory.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: Dimensions.paddingSizeSmall),
            itemBuilder: (BuildContext listContext, int index) {
              final AddressModel item = friendHistory[index];
              return GestureDetector(
                onTap: () async {
                  final FriendZoneCheckResult result =
                      await friendController.selectFromHistory(item);
                  if (!mounted) return;
                  if (!result.isAvailable) {
                    RadiusSearchDialog.showFinal(
                      radius: SearchRadiusState.activeRadius ??
                          SearchRadiusState.initialRadius ??
                          5,
                      maxRadius: SearchRadiusState.maxRadius ?? 50,
                      onDismiss: () {},
                      onChangeAddress: () {},
                    );
                    return;
                  }
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    item.address ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Colors.black54,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    widgets.add(const SizedBox(height: Dimensions.paddingSizeDefault));

    // Book for other location (naya redesigned tabbed screen)
    widgets.add(
      GestureDetector(
        onTap: () {
          Get.to(() => const BookOtherLocationScreen())?.then((_) {
            if (mounted) setState(() {});
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeLarge,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt_1_outlined, color: primaryAccent),
              const SizedBox(width: 8),
              Text(
                'book_for_other_location'.tr,
                style: robotoMedium.copyWith(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );

    return widgets;
  }
}


