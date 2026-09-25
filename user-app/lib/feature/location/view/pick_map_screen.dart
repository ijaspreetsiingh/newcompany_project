import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/map_view_widget.dart';

class PickMapScreen extends StatefulWidget {
  final bool? fromSignUp;
  final bool? fromAddAddress;
  final bool? canRoute;
  final String? route;
  final bool formCheckout;
  final MapController? mapController;
  final ZoneModel? zone;
  final AddressModel? previousAddress;
  const PickMapScreen({super.key,
    required this.fromSignUp, required this.fromAddAddress, required this.canRoute,
    required this.route, this.mapController,
    required this.formCheckout, required this.zone,
    this.previousAddress
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> with TickerProviderStateMixin {
  MapController? _mapController;
  LatLng? _currentLatLng;
  LatLng? _initialPosition;
  LatLng? _centerLatLng;
  late AnimationController _blobController;

  List<Polygon> _polygone = [];
  List<LatLng> zoneLatLongList = [];

  String? pageTitle;
  String? pageSubTitle;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
    _mapController = MapController();

    if(widget.fromAddAddress!) {
      Get.find<LocationController>().setPickData();
    }

    if(widget.zone !=null){
      _centerLatLng = Get.find<ServiceAreaController>().computeCentroid(coordinates: widget.zone!.formattedCoordinates!);
      _initialPosition = LatLng(_centerLatLng!.latitude , _centerLatLng!.longitude);

      widget.zone?.formattedCoordinates?.forEach((element) {
        zoneLatLongList.add(LatLng(element.latitude!, element.longitude!));
      });

      _polygone = [
        Polygon(
          points: zoneLatLongList,
          borderStrokeWidth: 2,
          color: const Color(0xffFF6B2C).withValues(alpha: .2),
          borderColor: const Color(0xffFF6B2C),
        ),
      ];

    }else{
      _initialPosition = LatLng(
        Get.find<SplashController>().configModel.content?.defaultLocation?.latitude ?? 23.00000,
        Get.find<SplashController>().configModel.content?.defaultLocation?.longitude ?? 90.00000,
      );
    }

    if(widget.route == "search_service"){
      pageTitle = "search_services_near_you".tr;
      pageSubTitle = "${'you_must_select_location_first_to_view'.tr} ${'services'.tr.toLowerCase()}";
    } else if(widget.route == RouteHelper.allServiceScreen){
      pageTitle = "services_near_you".tr;
      pageSubTitle = "${'you_must_select_location_first_to_view'.tr} ${'services'.tr.toLowerCase()}";
    }
    else if(widget.route == RouteHelper.home){
      pageTitle = "home".tr;
      pageSubTitle = "${'you_must_select_location_first_to_view'.tr} ${'home_content'.tr.toLowerCase()}";
    }else if(widget.route == RouteHelper.categories || widget.route ==  RouteHelper.cart || widget.route ==  RouteHelper.offers || widget.route == RouteHelper.notification || widget.route == RouteHelper.voucherScreen){
      pageTitle = widget.route?.replaceAll("/", "").tr;
      pageSubTitle = "${'you_must_select_location_first_to_view'.tr} ${widget.route?.replaceAll("/", "").tr.toLowerCase()}";
    }
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      isExit: true,
      child: Scaffold(
        backgroundColor: const Color(0xffFFF5EE),
        body: SafeArea(
          child: ResponsiveHelper.isDesktop(context) ? CustomScrollView(
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
              if(ResponsiveHelper.isDesktop(context)) SliverToBoxAdapter(child: FooterView()),
            ],
          ) : Column(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff101828), size: 20),
          ),
          const Spacer(),
          Text(
            'Set Location',
            style: robotoBold.copyWith(fontSize: 17, color: const Color(0xff101828)),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  void _onMapCreated(MapController mapController) {
    _mapController = mapController;
    if (!widget.fromAddAddress!) {
      if (widget.zone != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          mapController.fitCamera(CameraFit.bounds(
            bounds: MapHelper.boundsFromLatLngList(zoneLatLongList),
            padding: const EdgeInsets.all(100.5),
          ));
        });
        Get.find<LocationController>().getCurrentLocation(
          false,
          mapController: mapController,
          defaultLatLng: _centerLatLng,
          isFromCheckout: widget.formCheckout,
        );
      } else {
        Get.find<LocationController>().getCurrentLocation(
          false,
          mapController: mapController,
          isFromCheckout: widget.formCheckout,
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
    if (locationController.pickPosition.latitude != 0 &&
        locationController.pickAddress.address!.isNotEmpty) {
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
        );
      }
    } else {
      customSnackBar('pick_an_address'.tr, type: ToasterMessageType.info);
    }
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      customSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    }else {
      onTap();
    }
  }
}

