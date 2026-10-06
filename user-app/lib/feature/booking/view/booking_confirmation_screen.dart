import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Mark
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryAccent.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    size: 48,
                    color: primaryAccent,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // Title
              Text(
                'booking_confirmed'.tr.toUpperCase(),
                style: robotoSmall.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'home_good_hands'.tr,
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(
                  fontSize: 24,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text(
                'professional_assigned_soon'.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // Booking Ticket
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'booking_id'.tr.toUpperCase(),
                          style: robotoSmall.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          '#NE384921',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildTicketRow(Icons.calendar_today, 'Tomorrow, 30 Sep'),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    _buildTicketRow(Icons.access_time, '10:00 AM'),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    _buildTicketRow(Icons.location_on, 'Home Â· Indtranagar'),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // Track Booking Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(RouteHelper.getBookingDetailsScreen(bookingID: 'NE384921'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                  child: Text(
                    'track_booking'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Back to Home Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(RouteHelper.getMainRoute('home'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                  child: Text(
                    'back_to_home'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Get.theme.colorScheme.primary, size: 18),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Text(
          text,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Get.theme.textTheme.bodyLarge!.color,
          ),
        ),
      ],
    );
  }
}

