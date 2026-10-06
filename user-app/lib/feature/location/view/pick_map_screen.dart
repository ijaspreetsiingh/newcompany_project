import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/map_view_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';

class PickMapScreen extends StatefulWidget {
  final bool? fromSignUp;
  final bool? fromAddAddress;
  final bool? canRoute;
  final String? route;
  final bool formCheckout;
  final MapController? mapController;
  final ZoneModel? zone;
  final AddressModel? previousAddress;
  const PickMapScreen({
    super.key,
    required this.fromSignUp,
    required this.fromAddAddress,
    required this.canRoute,
    required this.route,
    this.mapController,
    required this.formCheckout,
    required this.zone,
    this.previousAddress,
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  MapController? _mapController;
  LatLng? _currentLatLng;
  LatLng? _initialPosition;
  LatLng? _centerLatLng;

  List<Polygon> _polygone = [];
  List<LatLng> zoneLatLongList = [];

  String? pageTitle;
  String? pageSubTitle;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    if (widget.fromAddAddress!) {
      Get.find<LocationController>().setPickData();
    }

    if (widget.zone != null) {
      _centerLatLng = Get.find<ServiceAreaController>().computeCentroid(
        coordinates: widget.zone!.formattedCoordinates!,
      );
      _initialPosition = LatLng(
        _centerLatLng!.latitude,
        _centerLatLng!.longitude,
      );

      widget.zone?.formattedCoordinates?.forEach((element) {
        zoneLatLongList.add(LatLng(element.latitude!, element.longitude!));
      });

      _polygone = [
        Polygon(
          points: zoneLatLongList,
          borderStrokeWidth: 2,
          color: Get.theme.colorScheme.primary.withValues(alpha: .12),
          borderColor: Get.theme.colorScheme.primary,
        ),
      ];
    } else {
      final AddressModel? savedAddress =
          widget.previousAddress ??
          Get.find<LocationController>().getUserAddress();
      final double? savedLatitude = double.tryParse(
        savedAddress?.latitude ?? '',
      );
      final double? savedLongitude = double.tryParse(
        savedAddress?.longitude ?? '',
      );
      _initialPosition =
          savedLatitude != null &&
              savedLongitude != null &&
              savedLatitude != 0 &&
              savedLongitude != 0
          ? LatLng(savedLatitude, savedLongitude)
          : LatLng(
              Get.find<SplashController>()
                      .configModel
                      .content
                      ?.defaultLocation
                      ?.latitude ??
                  23.00000,
              Get.find<SplashController>()
                      .configModel
                      .content
                      ?.defaultLocation
                      ?.longitude ??
                  90.00000,
            );
    }

    if (widget.route == "search_service") {
      pageTitle = "search_services_near_you".tr;
      pageSubTitle =
          "${'you_must_select_location_first_to_view'.tr} ${'services'.tr.toLowerCase()}";
    } else if (widget.route == RouteHelper.allServiceScreen) {
      pageTitle = "services_near_you".tr;
      pageSubTitle =
          "${'you_must_select_location_first_to_view'.tr} ${'services'.tr.toLowerCase()}";
    } else if (widget.route == RouteHelper.home) {
      pageTitle = "home".tr;
      pageSubTitle =
          "${'you_must_select_location_first_to_view'.tr} ${'home_content'.tr.toLowerCase()}";
    } else if (widget.route == RouteHelper.categories ||
        widget.route == RouteHelper.cart ||
        widget.route == RouteHelper.offers ||
        widget.route == RouteHelper.notification ||
        widget.route == RouteHelper.voucherScreen) {
      pageTitle = widget.route?.replaceAll("/", "").tr;
      pageSubTitle =
          "${'you_must_select_location_first_to_view'.tr} ${widget.route?.replaceAll("/", "").tr.toLowerCase()}";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      isExit: true,
      child: Scaffold(
        backgroundColor: NestInk.background,
        body: SafeArea(
          child: ResponsiveHelper.isDesktop(context)
              ? CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Center(
                        child: WebShadowWrap(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeader(),
                              SizedBox(
                                height: Dimensions.webMaxWidth * 0.5,
                                child: MapViewWidget(
                                  fromAddAddress: widget.fromAddAddress!,
                                  initialPosition: _initialPosition,
                                  polygons: _polygone,
                                  onMapCreated: _onMapCreated,
                                  onPositionChanged: _onPositionChanged,
                                  onCameraIdle: _onCameraIdle,
                                  onLocationTap: _onLocationTap,
                                  onPickLocationTap: _onPickLocationTap,
                                  getMapController: () => _mapController,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (ResponsiveHelper.isDesktop(context))
                      SliverToBoxAdapter(child: FooterView()),
                  ],
                )
              : Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: MapViewWidget(
                          fromAddAddress: widget.fromAddAddress!,
                          initialPosition: _initialPosition,
                          polygons: _polygone,
                          onMapCreated: _onMapCreated,
                          onPositionChanged: _onPositionChanged,
                          onCameraIdle: _onCameraIdle,
                          onLocationTap: _onLocationTap,
                          onPickLocationTap: _onPickLocationTap,
                          getMapController: () => _mapController,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final primaryColor = NestInk.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: NestInk.card,
              shape: BoxShape.circle,
              border: Border.all(color: NestInk.border),
            ),
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: primaryColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your location',
                  style: GoogleFonts.manrope(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Search an address or move the map pin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: NestInk.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(MapController mapController) {
    _mapController = mapController;
    if (!widget.fromAddAddress!) {
      if (widget.zone != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          mapController.fitCamera(
            CameraFit.bounds(
              bounds: MapHelper.boundsFromLatLngList(zoneLatLongList),
              padding: const EdgeInsets.all(100.5),
            ),
          );
        });
      }

      final LocationController locationController =
          Get.find<LocationController>();
      final AddressModel? savedAddress =
          widget.previousAddress ?? locationController.getUserAddress();
      final double? savedLatitude = double.tryParse(
        savedAddress?.latitude ?? '',
      );
      final double? savedLongitude = double.tryParse(
        savedAddress?.longitude ?? '',
      );
      final bool savedAddressMatchesMap =
          savedAddress != null &&
          savedLatitude != null &&
          savedLongitude != null &&
          (_initialPosition!.latitude - savedLatitude).abs() < 0.00001 &&
          (_initialPosition!.longitude - savedLongitude).abs() < 0.00001;

      if (widget.formCheckout) {
        locationController.getCurrentLocation(
          false,
          defaultLatLng: _initialPosition,
          mapController: mapController,
          isFromCheckout: true,
        );
      } else {
        locationController.initializePickPosition(
          _initialPosition!,
          savedAddress: savedAddressMatchesMap ? savedAddress : null,
        );
      }
    }
  }

  void _onPositionChanged(LatLng target, double zoom) {
    _currentLatLng = target;
  }

  void _onCameraIdle() {
    Get.find<LocationController>().updateCameraMovingStatus(false);
    try {
      if (_currentLatLng != null) {
        Get.find<LocationController>().updatePosition(
          _currentLatLng!,
          false,
          formCheckout: widget.formCheckout,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('');
      }
    }
  }

  void _onLocationTap() {
    _checkPermission(() {
      Get.find<LocationController>().getCurrentLocation(
        false,
        deviceCurrentLocation: true,
        isFromCheckout: widget.formCheckout,
        mapController: _mapController,
      );
    });
  }

  void _onPickLocationTap() {
    final locationController = Get.find<LocationController>();
    final String selectedAddress =
        locationController.pickAddress.address?.trim() ?? '';
    if (locationController.pickPosition.latitude != 0 &&
        locationController.pickPosition.longitude != 0 &&
        selectedAddress.isNotEmpty) {
      if (widget.fromAddAddress!) {
        if (widget.mapController != null) {
          widget.mapController!.move(
            LatLng(
              locationController.pickPosition.latitude,
              locationController.pickPosition.longitude,
            ),
            16,
          );
          locationController.setAddAddressData();
        }
        Get.back();
      } else {
        String? firstName;

        if (Get.find<AuthController>().isLoggedIn() &&
            Get.find<UserController>().userInfoModel?.phone != null &&
            Get.find<UserController>().userInfoModel?.fName != null) {
          firstName = "${Get.find<UserController>().userInfoModel?.fName} ";
        }

        AddressModel address = AddressModel(
          latitude: locationController.pickPosition.latitude.toString(),
          longitude: locationController.pickPosition.longitude.toString(),
          addressType: 'others',
          address: locationController.pickAddress.address ?? "",
          city: locationController.pickAddress.city ?? "",
          country: locationController.pickAddress.country ?? "",
          house: locationController.pickAddress.house ?? "",
          street: locationController.pickAddress.street ?? "",
          zipCode: locationController.pickAddress.zipCode ?? "",
          addressLabel: AddressLabel.home.name,
          zoneId: locationController.pickAddress.zoneId,
          availableServiceCountInZone:
              locationController.pickAddress.availableServiceCountInZone,
          contactPersonNumber: firstName != null
              ? Get.find<UserController>().userInfoModel?.phone ?? ""
              : "",
          contactPersonName: firstName != null
              ? "$firstName${Get.find<UserController>().userInfoModel?.lName ?? ""}"
              : "",
        );

        if (kDebugMode) {
          print("Inside Here ===> Route === > ${widget.route}");
        }
        locationController.saveAddressAndNavigate(
          address,
          widget.fromSignUp!,
          widget.route ?? RouteHelper.getMainRoute('home'),
          widget.canRoute!,
          true,
          zoneAlreadyValidated: true,
        );
      }
    } else {
      customSnackBar('pick_an_address'.tr, type: ToasterMessageType.info);
    }
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
}
