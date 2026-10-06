import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/feature/booking/controller/new_booking_controller.dart';

class BookingLocationScreen extends StatefulWidget {
  const BookingLocationScreen({super.key});

  @override
  State<BookingLocationScreen> createState() => _BookingLocationScreenState();
}

class _BookingLocationScreenState extends State<BookingLocationScreen> {
  final TextEditingController _addressController = TextEditingController();
  final NewBookingController _bookingController = Get.find<NewBookingController>();

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing address if available
    if (Get.find<LocationController>().getUserAddress() != null) {
      _addressController.text = Get.find<LocationController>().getUserAddress()!.address ?? '';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'your_location'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Map View
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[200],
              child: Stack(
                children: [
                  // Placeholder for map - in real app use Google Maps or similar
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 50,
                          color: primaryAccent.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'map_view_placeholder'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Pin marker
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Icon(
                        Icons.location_on,
                        size: 40,
                        color: primaryAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Location Details Section
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  Text(
                    'location_details'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  
                  // Address Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'enter_address'.tr,
                        hintStyle: robotoRegular.copyWith(
                          color: Colors.black54,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      ),
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  
                  // Use Current Location Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _getCurrentLocation();
                      },
                      icon: Icon(Icons.my_location, color: primaryAccent),
                      label: Text(
                        'use_current_location'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: primaryAccent,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_addressController.text.isNotEmpty) {
                          _bookingController.setAddress(_addressController.text);
                          // New design flow: address -> checkout final (address & schedule) -> payment -> confirmation
                          Get.toNamed(RouteHelper.getCheckoutFinalRoute());
                        } else {
                          customSnackBar('please_enter_address'.tr);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                      child: Text(
                        'confirm_location'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _getCurrentLocation() {
    // In real app, use geolocator to get current location
    // For now, just show a placeholder
    customSnackBar('location_fetching'.tr);
  }
}


