import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/feature/booking/controller/booking_details_controller.dart';

class BookingTrackingScreen extends StatelessWidget {
  const BookingTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
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
            actions: [
              IconButton(
                icon: Icon(Icons.help_outline, color: Theme.of(context).textTheme.bodyLarge!.color),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Hero
                _buildStatusHero(context),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Timeline
                _buildTimeline(context),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Professional Card
                _buildProfessionalCard(context),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Info Group
                _buildInfoGroup(context),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Price Summary
                _buildPriceSummary(context),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'professional_assigned'.tr.toUpperCase(),
            style: robotoSmall.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            'everythings_on_track'.tr,
            style: robotoBold.copyWith(
              fontSize: 20,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            'professional_arrive_soon'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final steps = [
      {'title': 'booking_confirmed'.tr, 'time': 'Today, 11:42 AM', 'done': true},
      {'title': 'professional_assigned'.tr, 'time': 'Today, 12:10 PM', 'done': true},
      {'title': 'service_in_progress'.tr, 'time': 'Pending', 'done': false},
      {'title': 'completed'.tr, 'time': 'Pending', 'done': false},
    ];

    return Column(
      children: [
        Text(
          'progress'.tr.toUpperCase(),
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        ...List.generate(
          steps.length,
          (index) => Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: steps[index]['done'] == true ? primaryAccent : Colors.grey[300],
                        ),
                        child: steps[index]['done'] == true
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                      if (index < steps.length - 1)
                        Container(
                          width: 2,
                          height: 50,
                          color: steps[index]['done'] == true ? primaryAccent : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[index]['title'] as String,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[index]['time'] as String,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (index < steps.length - 1) const SizedBox(height: Dimensions.paddingSizeDefault),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryAccent.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                'RK',
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryAccent),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'your_professional'.tr.toUpperCase(),
                  style: robotoSmall.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'Rahul Kumar',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '4.92 Â· 1,248 jobs',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.call, color: Theme.of(context).colorScheme.primary, size: 20),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.message, color: Theme.of(context).colorScheme.primary, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGroup(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.calendar_today, 'schedule'.tr.toUpperCase(), 'Tomorrow, 10:00 AM', context),
          const Divider(height: 24),
          _buildInfoRow(Icons.location_on, 'address'.tr.toUpperCase(), '12, 3rd Cross Road, Indtranagar', context),
          const Divider(height: 24),
          _buildInfoRow(Icons.credit_card, 'payment'.tr.toUpperCase(), 'cash_after_service'.tr, context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: robotoSmall.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(BuildContext context) {
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
                'item_total'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.black54,
                ),
              ),
              Text(
                'â‚¹2,499',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'taxes_and_fee'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.black54,
                ),
              ),
              Text(
                'â‚¹249',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ],
          ),
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
                'â‚¹2,748',
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'cancel_booking'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'repeat'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


