import 'package:get/get.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/feature/location/controller/location_change_radius_controller.dart';
import 'package:jdds/util/core_export.dart';

/// Location change screen for booking checkout.
/// User apna location manually set kar sakte hain ya existing se select kar sakte hain.
/// Same zone check + progressive radius search karta hai.
///
/// Flow:
///  1. Existing addresses list dikhta hai OR map se location pick kar sakte hain
///  2. Location confirm karte hi → radius search
///  3. Service available → location set ho gaya, booking continue
///  4. Service nahi mila → popup + expand radius option
///  5. Max radius tak nahi mila → final popup with "Change Location" button
class LocationChangeScreen extends StatefulWidget {
  const LocationChangeScreen({super.key});

  @override
  State<LocationChangeScreen> createState() => _LocationChangeScreenState();
}

class _LocationChangeScreenState extends State<LocationChangeScreen> {
  late LocationController locationController;
  late LocationChangeRadiusController radiusController;

  AddressModel? _selectedAddress;
  bool _isLoading = false;
  bool _showMapPicker = false;

  @override
  void initState() {
    super.initState();
    locationController = Get.find<LocationController>();
    if (!Get.isRegistered<LocationChangeRadiusController>()) {
      Get.put(LocationChangeRadiusController(
        locationRepo: Get.find<LocationRepo>(),
      ));
    }
    radiusController = Get.find<LocationChangeRadiusController>();
    _selectedAddress = locationController.getUserAddress();
  }

  Future<void> _onLocationSelected(AddressModel address) async {
    setState(() {
      _isLoading = true;
      _selectedAddress = address;
    });

    // Notify radius controller about location change
    await radiusController.onLocationChanged(address);

    // Check availability with progressive radius search
    final bool available =
        await radiusController.checkAvailabilityAndPrompt(address);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (available) {
      // Service available → save and close
      await locationController.saveUserAddress(address);
      Get.back(result: true);
    }
    // If not available → popup already shown by controller
  }

  Future<void> _onMapLocationPicked() async {
    // User ne map se naya location pick kiya
    // Ye typically map screen se callback ata hai
    // For now, placeholder.
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = NestInk.primary;

    return Scaffold(
      backgroundColor: NestInk.background,
      appBar: AppBar(
        backgroundColor: NestInk.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: NestInk.primary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'change_location'.tr,
          style: robotoBold.copyWith(
            fontSize: 18,
            color: NestInk.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map picker card
                  GestureDetector(
                    onTap: () {
                      // Open map picker here
                      _showMapPicker = true;
                      setState(() {});
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: primary, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            'pick_location_on_map'.tr,
                            style: robotoBold.copyWith(
                              fontSize: 16,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'tap_to_open_map'.tr,
                            style: robotoSmall.copyWith(
                              fontSize: 12,
                              color: NestInk.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: NestInk.border,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault),
                        child: Text(
                          'or_select_saved_address'.tr,
                          style: robotoSmall.copyWith(
                            fontSize: 12,
                            color: NestInk.mutedText,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: NestInk.border,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Saved addresses list
                  GetBuilder<LocationController>(
                    builder: (controller) {
                      final List<AddressModel> addresses =
                          controller.addressList ?? [];

                      if (addresses.isEmpty) {
                        return Center(
                          child: Text(
                            'no_saved_addresses'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: 14,
                              color: NestInk.mutedText,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: addresses.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final address = addresses[index];
                          final bool isSelected =
                              _selectedAddress?.id == address.id;

                          return GestureDetector(
                            onTap: () =>
                                _onLocationSelected(address),
                            child: Container(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primary.withValues(alpha: 0.08)
                                    : NestInk.card,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                border: Border.all(
                                  color: isSelected
                                      ? primary
                                      : NestInk.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    (address.addressType ?? 'office') == 'home'
                                        ? Icons.home_rounded
                                        : Icons.business_rounded,
                                    color: isSelected
                                        ? primary
                                        : NestInk.mutedText,
                                    size: 24,
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeDefault),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (address.addressType ?? 'office') == 'home'
                                              ? 'home'.tr
                                              : 'work'.tr,
                                          style: robotoBold.copyWith(
                                            fontSize: 14,
                                            color: NestInk.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          address.address ?? 'No address',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: robotoSmall.copyWith(
                                            fontSize: 12,
                                            color: NestInk.mutedText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded,
                                        color: primary, size: 24),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
