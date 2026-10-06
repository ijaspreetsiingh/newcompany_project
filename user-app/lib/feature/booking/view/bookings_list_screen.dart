import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  String selectedTab = 'ongoing';

  // TODO: API: GET /bookings?status=ongoing|completed|canceled
  final List<Map<String, dynamic>> _bookings = [
    {
      'id': '#NE384921',
      'status': 'ongoing',
      'statusDisplay': 'professional_assigned',
      'serviceImage': Icons.cleaning_services,
      'serviceName': 'Full home deep cleaning',
      'date': 'Tomorrow Â· 10:00 AM',
      'location': 'Home Â· Indtranagar',
      'price': 'â‚¹2,548',
      'progress': 2,
      'professionalName': 'Rahul Kumar',
      'progressText': 'Rahul is preparing for your service',
    },
    {
      'id': '#NE371024',
      'status': 'completed',
      'statusDisplay': 'completed',
      'serviceImage': Icons.ac_unit,
      'serviceName': 'AC service & repatr',
      'date': '16 Sep Â· 2:00 PM',
      'location': 'Home Â· Indtranagar',
      'price': 'â‚¹699',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _bookings.where((b) => b['status'] == selectedTab).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'bookings'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Theme.of(context).textTheme.bodyLarge!.color),
            onPressed: () {
              // TODO: Navigate to support
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                _buildTabButton(context, 'ongoing', 'Ongoing'),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                _buildTabButton(context, 'completed', 'Completed'),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                _buildTabButton(context, 'canceled', 'Canceled'),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Content
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(context, selectedTab)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      if (selectedTab == 'ongoing') {
                        return _buildOngoingBookingCard(context, filtered[index]);
                      } else if (selectedTab == 'completed') {
                        return _buildCompletedBookingCard(context, filtered[index]);
                      } else {
                        return _buildCanceledBookingCard(context, filtered[index]);
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String value, String label) {
    final bool isActive = selectedTab == value;

    return GestureDetector(
      onTap: () => setState(() => selectedTab = value),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: isActive
                  ? primaryAccent
                  : Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          if (isActive)
            Container(
              height: 3,
              width: 20,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: primaryAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOngoingBookingCard(BuildContext context, Map<String, dynamic> booking) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to booking tracking screen
        Get.toNamed(RouteHelper.getTrackingFinalRoute(bookingId: booking['id']));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['statusDisplay'].toString().toUpperCase(),
                      style: robotoSmall.copyWith(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['id'],
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Service Info
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: primaryAccent.withOpacity(0.1),
                  ),
                  child: Icon(booking['serviceImage'], color: primaryAccent, size: 30),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['serviceName'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking['date'],
                        style: robotoSmall.copyWith(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking['price'],
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Progress Dots
            Row(
              children: [
                ...List.generate(
                  4,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < booking['progress']
                          ? primaryAccent
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Progress Text
            Text(
              booking['progressText'],
              style: robotoSmall.copyWith(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedBookingCard(BuildContext context, Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COMPLETED',
                    style: robotoSmall.copyWith(
                      fontSize: 10,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking['id'],
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Service Info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: primaryAccent.withOpacity(0.1),
                ),
                child: Icon(booking['serviceImage'], color: primaryAccent, size: 30),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['serviceName'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['date'],
                      style: robotoSmall.copyWith(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['price'],
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Book Again Button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Book same service again
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
              child: Text(
                'book_again'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanceledBookingCard(BuildContext context, Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Colors.red.withOpacity(0.1),
            ),
            child: Icon(booking['serviceImage'], color: Colors.red, size: 30),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['serviceName'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking['date'],
                  style: robotoSmall.copyWith(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String tab) {
    String title = '';
    String message = '';

    if (tab == 'ongoing') {
      title = 'no_ongoing_bookings'.tr;
      message = 'start_booking_to_see_here'.tr;
    } else if (tab == 'completed') {
      title = 'no_completed_bookings'.tr;
      message = 'completed_services_will_appear_here'.tr;
    } else {
      title = 'no_canceled_bookings'.tr;
      message = 'canceled_bookings_will_show_here'.tr;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            title,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            message,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}


