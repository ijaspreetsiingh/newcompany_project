import 'package:jassdbx_serviceman/feature/booking_details/view/location_tracking_screen.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class BookingServiceLocation extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool isSubBooking;
  const BookingServiceLocation({super.key, required this.bookingDetails, required this.isSubBooking});

  /// Shows the map chooser popup first (Google Maps vs in-app navigation),
  /// then runs the flow the serviceman picked.
  static Future<void> openDirections(BookingDetailsContent bookingDetails) async {
    if (bookingDetails.serviceAddress == null && bookingDetails.provider == null) {
      showCustomSnackBar("service_address_not_found".tr, type: ToasterMessageType.info);
      return;
    }

    final double lat = bookingDetails.serviceLocation == "customer"
        ? double.tryParse(bookingDetails.serviceAddress?.lat ?? "0") ?? 23.8103
        : bookingDetails.provider?.coordinates?.lat ?? 23.00;

    final double lon = bookingDetails.serviceLocation == "customer"
        ? double.tryParse(bookingDetails.serviceAddress?.lon ?? "0") ?? 90.4125
        : bookingDetails.provider?.coordinates?.lng ?? 90.4125;

    final String destinationTitle = bookingDetails.serviceLocation == "customer"
        ? (bookingDetails.serviceAddress?.address ??
            bookingDetails.subBooking?.serviceAddress?.address ??
            'customer_location'.tr)
        : (bookingDetails.provider?.companyAddress ??
            bookingDetails.subBooking?.provider?.companyAddress ??
            'provider_location'.tr);

    showMapOptionSheet(
      lat: lat,
      lon: lon,
      destinationTitle: destinationTitle,
    );
  }

  static void showMapOptionSheet({
    required double lat,
    required double lon,
    required String destinationTitle,
  }) {
    Get.bottomSheet(
      Builder(
        builder: (context) {
          return SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: context.kCard,
                border: Border(
                  top: BorderSide(color: context.kBorder, width: 1),
                  left: BorderSide(color: context.kBorder, width: 1),
                  right: BorderSide(color: context.kBorder, width: 1),
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.kBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'choose_map_app'.tr,
                    style: robotoBold.copyWith(
                      fontSize: 18,
                      color: context.kForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destinationTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: 13,
                      color: context.kMutedForeground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MapOptionTile(
                    icon: Icons.map_outlined,
                    iconColor: const Color(0xFF4285F4),
                    title: 'google_maps'.tr,
                    subtitle: 'open_external_map_desc'.tr,
                    onTap: () {
                      Get.back();
                      _openExternalGoogleMap(lat, lon);
                    },
                  ),
                  const SizedBox(height: 12),
                  _MapOptionTile(
                    icon: Icons.navigation_rounded,
                    iconColor: context.kPrimary,
                    title: 'in_app_navigation'.tr,
                    subtitle: 'track_inside_app_desc'.tr,
                    onTap: () {
                      Get.back();
                      Get.to(
                        () => LocationTrackingScreen(
                          destinationLat: lat,
                          destinationLng: lon,
                          destinationTitle: destinationTitle,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  static void _openExternalGoogleMap(double lat, double lon) {
    _checkPermission(() async {
      Get.dialog(const CustomLoader(), barrierDismissible: false);
      try {
        final Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            timeLimit: Duration(seconds: 15),
          ),
        );
        await MapUtils.openMap(
          lat,
          lon,
          position.latitude,
          position.longitude,
        );
      } catch (_) {
        showCustomSnackBar(
          'failed_to_open_map'.tr,
          type: ToasterMessageType.info,
        );
      } finally {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<BookingDetailsController>(builder: (bookingDetailsController){
      return KCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(
            text: TextSpan(
              text:  "you_need_to_go_to_the".tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,  color: context.kMutedForeground),
              children: <TextSpan>[
                TextSpan(
                  text: " ${ (bookingDetails.serviceLocation == "provider" || bookingDetails.subBooking?.serviceLocation == "provider") ? "provider_location".tr : 'customer_location'.tr} ",
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault,  color: context.kForeground),
                ),
                TextSpan(
                  text: " ${'to_provide_the_service'.tr} ",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,  color: context.kMutedForeground),
                ),
              ],
            ),
          ),
        ]),
      );
    });
  }

  static void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr, type : ToasterMessageType.info);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog( const PermissionDialog(), barrierDismissible: true);
    }else {
      onTap();
    }
  }

}

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double destinationLatitude, double destinationLongitude, double userLatitude, double userLongitude) async {
    String googleUrl = 'https://www.google.com/maps/dir/?api=1&origin=$userLatitude,$userLongitude'
        '&destination=$destinationLatitude,$destinationLongitude&mode=d';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }
}

class _MapOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MapOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.kBackground,
      borderRadius: BorderRadius.circular(kRadiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadiusMd),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: Border.all(color: context.kBorder, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(kRadiusSm),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: robotoMedium.copyWith(
                        fontSize: 15,
                        color: context.kForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: context.kMutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: context.kMutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
