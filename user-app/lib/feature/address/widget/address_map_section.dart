import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class AddressMapSection extends StatefulWidget {
  final LatLng initialPosition;
  final MapController? Function() getMapController;
  final Function(LatLng target, double zoom) onPositionChanged;
  final Function() onCameraIdle;
  final Function(MapController) onMapCreated;
  final bool fromCheckout;
  final bool isDesktop;
  final bool isUpdate;
  final TextEditingController serviceAddressController;

  const AddressMapSection({
    super.key,
    required this.initialPosition,
    required this.getMapController,
    required this.onPositionChanged,
    required this.onCameraIdle,
    required this.onMapCreated,
    required this.fromCheckout,
    this.isDesktop = false,
    this.isUpdate = false,
    required this.serviceAddressController,
  });

  @override
  State<AddressMapSection> createState() => _AddressMapSectionState();
}

class _AddressMapSectionState extends State<AddressMapSection> {
  late MapController _mapController;
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      customSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    } else {
      onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(
      builder: (locationController) {
        return GestureDetector(
          onHorizontalDragStart: (_){},
          onVerticalDragStart: (_){},
          child: Container(
            height: widget.isDesktop
                ? (ResponsiveHelper.isDesktop(context) ? 570 : 150)
                : 150,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
            ),
            padding: const EdgeInsets.all(1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: widget.initialPosition,
                      initialZoom: widget.isDesktop ? 14.4746 : 16,
                      minZoom: 0,
                      maxZoom: 16,
                    onPositionChanged: (camera, hasGesture) {
                      if (hasGesture) {
                        _idleTimer?.cancel();
                        Get.find<LocationController>().updateCameraMovingStatus(true);
                        widget.onPositionChanged(camera.center, camera.zoom);
                        _idleTimer = Timer(const Duration(milliseconds: 500), () {
                          Get.find<LocationController>().updateCameraMovingStatus(false);
                          widget.onCameraIdle();
                        });
                      }
                    },
                      onMapReady: () {
                        widget.onMapCreated(_mapController);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.sixamtech.demandium.user',
                      ),
                    ],
                  ),
                  if(ResponsiveHelper.isDesktop(context))
                    Positioned(
                      top: Dimensions.paddingSizeLarge,
                      left: Dimensions.paddingSizeSmall,
                      right: Dimensions.paddingSizeSmall,
                      child: LocationSearchDialog(
                        getMapController: widget.getMapController,
                        pickedLocation: widget.serviceAddressController.text.isEmpty ? 'search_location'.tr : widget.serviceAddressController.text,
                        child: Container(
                          height: 35,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Theme.of(context).disabledColor),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Expanded(
                                child: Text(
                                  widget.serviceAddressController.text.isEmpty ? 'search_location'.tr : widget.serviceAddressController.text, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).disabledColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Icon(
                                Icons.search,
                                size: 16,
                                color: Theme.of(context).disabledColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (locationController.loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Center(
                      child: Image.asset(Images.marker, height: 40, width: 40),
                    ),

                  Positioned(
                    bottom: 115,
                    left: Get.find<LocalizationController>().isLtr
                        ? null
                        : Dimensions.paddingSizeSmall,
                    right: Get.find<LocalizationController>().isLtr
                        ? -8
                        : null,
                    child: InkWell(
                      onTap: () => _checkPermission(() {
                        locationController.getCurrentLocation(
                          true,
                          deviceCurrentLocation: true,
                          isFromCheckout: widget.fromCheckout,
                          mapController: _mapController,
                        );
                      }),
                      child: Container(
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.only(
                          right: Dimensions.paddingSizeLarge,
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 5.0, offset: Offset(5.0, 5.0), spreadRadius: 2.0,),],
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          color: Theme.of(context)
                              .cardColor,
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
