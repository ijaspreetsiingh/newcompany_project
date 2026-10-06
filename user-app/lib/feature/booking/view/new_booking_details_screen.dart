import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/feature/booking/controller/new_booking_controller.dart';

class NewBookingDetailsScreen extends StatefulWidget {
  const NewBookingDetailsScreen({super.key});

  @override
  State<NewBookingDetailsScreen> createState() => _NewBookingDetailsScreenState();
}

class _NewBookingDetailsScreenState extends State<NewBookingDetailsScreen> {
  final NewBookingController _bookingController = Get.find<NewBookingController>();
  
  final List<String> timeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  ];

  double get basePrice => Get.find<CartController>().totalPrice;
  double get finalPrice => basePrice - _bookingController.discountAmount;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewBookingController>(
      builder: (controller) {
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
              'booking_details'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selection
                _buildDateSelector(),
                
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                
                // Working Hours
                _buildWorkingHoursSelector(),
                
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                
                // Time Slots
                _buildTimeSlotSelector(),
                
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                
                // Promo Code
                _buildPromoCodeSection(),
                
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                
                // Price Summary
                _buildPriceSummary(),
                
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                
                // Continue Button
                _buildContinueButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'select_date'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              DateTime date = DateTime.now().add(Duration(days: index));
              bool isSelected = DateFormat('yyyy-MM-dd').format(date) == 
                               DateFormat('yyyy-MM-dd').format(_bookingController.selectedDate);
              
              return GestureDetector(
                onTap: () {
                  _bookingController.selectDate(date);
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
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
                        DateFormat('E').format(date),
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d').format(date),
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
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
      ],
    );
  }

  Widget _buildWorkingHoursSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'working_hours'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _bookingController.workingHours > 1
                    ? () {
                        _bookingController.updateWorkingHours(_bookingController.workingHours - 1);
                      }
                    : null,
                color: primaryAccent,
              ),
              Text(
                '${_bookingController.workingHours} ${'hours'.tr}',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  _bookingController.updateWorkingHours(_bookingController.workingHours + 1);
                },
                color: primaryAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'choose_start_time'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              bool isSelected = timeSlots[index] == _bookingController.selectedTime;
              
              return GestureDetector(
                onTap: () {
                  _bookingController.selectTime(timeSlots[index]);
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
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
                        fontSize: Dimensions.fontSizeDefault,
                        color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'promo_code'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        if (_bookingController.selectedPromoCode != null)
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(Get.context!).colorScheme.primary),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      _bookingController.selectedPromoCode!,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(Get.context!).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    _bookingController.removePromoCode();
                  },
                  child: Icon(Icons.close, color: Get.isDarkMode ? Colors.black : Colors.white),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: () {
              _showPromoCodeBottomSheet();
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
                children: [
                  Icon(Icons.local_offer_outlined, color: primaryAccent),
                  const SizedBox(width: 12),
                  Text(
                    'add_promo_code'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'subtotal'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.black54,
                ),
              ),
              Text(
                PriceConverter.convertPrice(basePrice),
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ],
          ),
          if (_bookingController.discountAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'discount'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(Get.context!).colorScheme.primary,
                  ),
                ),
                Text(
                  '-${PriceConverter.convertPrice(_bookingController.discountAmount)}',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(Get.context!).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              Text(
                PriceConverter.convertPrice(finalPrice),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: primaryAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return GetBuilder<NewBookingController>(
      builder: (controller) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(RouteHelper.getNewBookingLocationRoute());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
            child: Text(
              'continue'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPromoCodeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddPromoScreen(),
    );
  }
}

class AddPromoScreen extends StatelessWidget {
  const AddPromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'available_promo_codes'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GetBuilder<CouponController>(
              builder: (couponController) {
                if (couponController.activeCouponList == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (couponController.activeCouponList!.isEmpty) {
                  return Center(
                    child: Text(
                      'no_promo_available'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  itemCount: couponController.activeCouponList!.length,
                  itemBuilder: (context, index) {
                    final coupon = couponController.activeCouponList![index];
                    return _buildPromoCard(coupon, context);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                ),
                child: Text(
                  'apply_promo'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(CouponModel coupon, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Center(
              child: Text(
                coupon.discount?.discountAmountType == 'percent' ? '${coupon.discount?.discountAmount}%' : PriceConverter.convertPrice(coupon.discount?.discountAmount ?? 0),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: primaryAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.couponCode ?? '',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  coupon.discount?.discountTitle ?? '',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          RadioGroup<String>(
            groupValue: Get.find<NewBookingController>().selectedPromoCode,
            onChanged: (value) {
              Get.find<NewBookingController>().selectPromoCode(coupon.couponCode ?? '');
            },
            child: Radio(
              value: coupon.couponCode ?? '',
              activeColor: primaryAccent,
            ),
          ),
        ],
      ),
    );
  }
}

