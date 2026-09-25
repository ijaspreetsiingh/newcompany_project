import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:lottie/lottie.dart';

class MapViewWidget extends StatefulWidget {
  final bool fromAddAddress;
  final LatLng? initialPosition;
  final List<Polygon> polygons;
  final Function(MapController) onMapCreated;
  final Function(LatLng target, double zoom) onPositionChanged;
  final Function() onCameraIdle;
  final Function() onLocationTap;
  final Function() onPickLocationTap;
  final MapController? Function() getMapController;

  const MapViewWidget({
    super.key,
    required this.fromAddAddress,
    required this.initialPosition,
    required this.polygons,
    required this.onMapCreated,
    required this.onPositionChanged,
    required this.onCameraIdle,
    required this.onLocationTap,
    required this.onPickLocationTap,
    required this.getMapController,
  });

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(
      builder: (locationController) {
        return Stack(
          children: [
            AbsorbPointer(
              absorbing: false,
              child: GestureDetector(
                onVerticalDragStart: (_) {},
                onHorizontalDragStart: (_) {},
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: widget.fromAddAddress
                        ? LatLng(
                            locationController.position.latitude,
                            locationController.position.longitude,
                          )
                        : widget.initialPosition!,
                    initialZoom: 16,
                    minZoom: 0,
                    maxZoom: 16,
                    onPositionChanged: (camera, hasGesture) {
                      if (hasGesture) {
                        _idleTimer?.cancel();
                        Get.find<LocationController>().updateCameraMovingStatus(true);
                        Get.find<LocationController>().disableButton();
                        widget.onPositionChanged(camera.center, camera.zoom);
                        _idleTimer = Timer(const Duration(milliseconds: 500), () {
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
                    PolygonLayer(polygons: widget.polygons),
                  ],
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: Dimensions.pickMapIconSize * 0.65,
                ),
                child: locationController.isCameraMoving
                    ? const AnimatedMapIconExtended()
                    : const AnimatedMapIconMinimised(),
              ),
            ),

            Positioned(
              top: Dimensions.paddingSizeLarge,
              left: Dimensions.paddingSizeSmall,
              right: Dimensions.paddingSizeSmall,
              child: LocationSearchDialog(
                getMapController: widget.getMapController,
                pickedLocation: locationController.pickAddress.address ?? 'search_location'.tr,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 22,
                        color: Color(0xffFF6B2C),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Expanded(
                        child: Text(
                          locationController.pickAddress.address ?? 'search_location'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      const Icon(
                        Icons.search,
                        size: 22,
                        color: Color(0xff98A2B3),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 80,
              right: Dimensions.paddingSizeSmall,
              child: FloatingActionButton(
                hoverColor: Colors.transparent,
                mini: true,
                backgroundColor: const Color(0xffFF6B2C),
                onPressed: widget.onLocationTap,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
              ),
            ),

            Positioned(
              bottom: 30.0,
              left: Dimensions.paddingSizeSmall,
              right: Dimensions.paddingSizeSmall,
              child: CustomButton(
                backgroundColor: const Color(0xffFF6B2C),
                textColor: Colors.white,
                fontSize: Dimensions.fontSizeDefault,
                buttonText: locationController.inZone
                    ? widget.fromAddAddress
                        ? 'pick_address'.tr
                        : 'pick_location'.tr
                    : 'service_not_available_in_this_area'.tr,
                onPressed: (locationController.buttonDisabled ||
                    locationController.loading)
                    ? null
                    : widget.onPickLocationTap,
              ),
            ),
          ],
        );
      },
    );
  }
}

class AnimatedMapIconExtended extends StatefulWidget {
  const AnimatedMapIconExtended({super.key});

  @override
  State<AnimatedMapIconExtended> createState() => _AnimatedMapIconExtendedState();
}

class _AnimatedMapIconExtendedState extends State<AnimatedMapIconExtended> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(builder: (locationController) {
      return Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Lottie.asset(
              Images.mapIconExtended,
              repeat: false,
              height: Dimensions.pickMapIconSize,
              delegates: LottieDelegates(
                values: [
                  ValueDelegate.color(
                    const ['Red circle Outlines', '**'],
                    value: Theme.of(context).colorScheme.primary,
                  ),
                  ValueDelegate.color(
                    const ['Shape Layer 1', '**'],
                    value: Theme.of(context).colorScheme.primary,
                  ),
                  ValueDelegate.color(
                    const ['Layer 4', 'Group 1', 'Stroke 1', '**'],
                    value: Theme.of(context).colorScheme.primary,
                  ),
                  ValueDelegate.color(
                    const ['Layer 4', 'Group 2', 'Stroke 1', '**'],
                    value: Theme.of(context).colorScheme.primary,
                  ),
                  ValueDelegate.color(
                    const ['Layer 4', 'Group 3', 'Stroke 1', '**'],
                    value: Theme.of(context).colorScheme.primary,
                  ),
                  ValueDelegate.color(
                    const ['shadow Outlines', '**'],
                    value: Theme.of(context).colorScheme.primary,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.pickMapIconSize * 0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(9, (index) {
                  return Icon(
                    Icons.circle,
                    size: index == 8
                        ? Dimensions.pickMapIconSize * 0.06
                        : Dimensions.pickMapIconSize * 0.03,
                    color: Theme.of(context).colorScheme.primary,
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class AnimatedMapIconMinimised extends StatefulWidget {
  const AnimatedMapIconMinimised({super.key});

  @override
  State<AnimatedMapIconMinimised> createState() => _AnimatedMapIconMinimisedState();
}

class _AnimatedMapIconMinimisedState extends State<AnimatedMapIconMinimised> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(builder: (locationController) {
      return Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Lottie.asset(
              Images.mapIconMinimised,
              repeat: false,
              height: Dimensions.pickMapIconSize,
              delegates: LottieDelegates(
                values: [
                  ValueDelegate.color(
                    const ['Red circle Outlines', '**'],
                    value: Theme.of(context).colorScheme.primary,
                  ),
                  ValueDelegate.color(
                    const ['Shape Layer 1', '**'],
                    value: Theme.of(context).colorScheme.primary,
                  ),
                  ValueDelegate.color(
                    const ['shadow Outlines', '**'],
                    value: Theme.of(context).colorScheme.primary,
                  )
                ],
              ),
            ),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.8, end: 0.1),
              duration: const Duration(milliseconds: 400),
              builder: (BuildContext context, double value, Widget? child) {
                return Padding(
                  padding: const EdgeInsets.only(top: Dimensions.pickMapIconSize * 0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(9, (index) {
                      return Icon(
                        Icons.circle,
                        size: index == 8
                            ? Dimensions.pickMapIconSize * 0.06
                            : Dimensions.pickMapIconSize * 0.03,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: value),
                      );
                    }),
                  ),
                );
              },
            )
          ],
        ),
      );
    });
  }
}
