import 'package:jassdbx_provider/util/core_export.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';


class PickMapScreen extends StatefulWidget {
  final LatLng ? initialPosition;
  final String ? initialAddress;
  const PickMapScreen({super.key,  this.initialPosition, this.initialAddress});

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _center;
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    final defaultLocation = Get.find<SplashController>().configModel.content?.defaultLocation?.defaultLocation;
    _center = widget.initialPosition ?? LatLng(
      defaultLocation?.lat ?? 23.777176,
      defaultLocation?.lon ?? 90.399452,
    );

    if (kDebugMode) {
      print(_center);
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(
        child: GetBuilder<LocationController>(builder: (locationController) {
          return Stack(children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center!,
                initialZoom: 16,
                minZoom: 3,
                maxZoom: 18,
                onMapReady: () {
                  if (widget.initialPosition == null) {
                    Get.find<LocationController>().getCurrentLocation(false, mapController: _mapController);
                  }
                },
                onPositionChanged: (MapCamera camera, bool hasGesture) {
                  _center = camera.center;
                  if (!hasGesture) {
                    return;
                  }
                  locationController.disableButton();
                  // Google Maps ke onCameraIdle jaisa behaviour: drag rukne
                  // ke 500ms baad hi reverse-geocode call karo.
                  _idleTimer?.cancel();
                  _idleTimer = Timer(const Duration(milliseconds: 500), () {
                    Get.find<LocationController>().updatePosition(camera.center);
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  // Primary tile host rate-limit kare to map grey na ho.
                  fallbackUrl: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.jassdbx.jassods.provider',
                  maxZoom: 19,
                ),
              ],
            ),

            Center(child: !locationController.loading ? Image.asset(Images.marker, height: 50, width: 50)
                : const CircularProgressIndicator()),

            Positioned(
              top: Dimensions.paddingSizeLarge, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
              child: InkWell(
                onTap: () => showCustomDialog(child: LocationSearchDialog(mapController: _mapController), barrierDismissible: true),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                  child: Row(children: [
                    Icon(Icons.location_on, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:.6)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Expanded(
                      child: Text(
                        (locationController.pickAddress.address?.isNotEmpty ?? false)
                            ?  locationController.pickAddress.address!
                            : (widget.initialAddress ?? ''),
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Icon(Icons.search, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color),
                  ]),
                ),
              ),
            ),

            Positioned(
              bottom: 80, right: Dimensions.paddingSizeSmall,
              child: FloatingActionButton(
                hoverColor: Colors.transparent,
                mini: true, backgroundColor:Theme.of(context).colorScheme.primary,
                onPressed: () => _checkPermission(() {
                  Get.find<LocationController>().getCurrentLocation(false, mapController: _mapController);
                }),
                child: Icon(Icons.my_location,
                    color: Theme.of(context).cardColor
                ),
              ),
            ),

            Positioned(
              bottom: 30.0, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
              child: CustomButton(
                fontSize: Dimensions.fontSizeDefault,
                btnTxt:  'pick_address'.tr,
                onPressed: ( locationController.loading) ? null : () {
                  if(locationController.pickPosition.latitude != 0 && locationController.pickAddress.address!.isNotEmpty) {
                    Get.back();
                  }else {
                    showCustomSnackBar('pick_an_address'.tr,type : ToasterMessageType.info);
                  }
                },
              ),
            ),
          ]);
        })),
      ),
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr, type : ToasterMessageType.info);
    }else if(permission == LocationPermission.deniedForever) {
      showCustomDialog(child: const PermissionDialog(), barrierDismissible: true);
    }else {
      onTap();
    }
  }
}
