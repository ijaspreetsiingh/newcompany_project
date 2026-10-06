import 'dart:convert';

import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

enum Address { service, billing }

enum AddressLabel { home, office, others }

class LocationController extends GetxController implements GetxService {
  final LocationRepo locationRepo;
  LocationController({required this.locationRepo});

  Position _position = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 1,
    heading: 1,
    speed: 1,
    speedAccuracy: 1,
    altitudeAccuracy: 1,
    headingAccuracy: 1,
  );
  Position _pickPosition = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 1,
    heading: 1,
    speed: 1,
    speedAccuracy: 1,
    altitudeAccuracy: 1,
    headingAccuracy: 1,
  );
  bool _loading = false;
  AddressModel _address = AddressModel();
  AddressModel _pickAddress = AddressModel();
  final List<Marker> _markers = <Marker>[];
  List<AddressModel>? _addressList;
  final int _addressLabelIndex = 0;
  AddressModel? _selectedAddress;
  bool _isLoading = false;
  bool _inZone = false;
  String _zoneID = '';
  bool _buttonDisabled = true;
  bool _changeAddress = true;
  bool _isCameraMoving = false;
  MapController? _mapController;
  List<PredictionModel> _predictionList = [];
  PredictionModel? _firstPredictionModel;
  bool _updateAddAddressData = true;
  Address _selectedAddressType = Address.service;
  AddressLabel _selectedAddressLabel = AddressLabel.home;
  TextEditingController searchController = TextEditingController();
  String countryDialCode = CountryCode.fromCountryCode(
    Get.find<SplashController>().configModel.content?.countryCode ?? "BD",
  ).dialCode!;

  ServiceLocationType _selectedServiceLocationType =
      ServiceLocationType.customer;
  ServiceLocationType get selectedServiceLocationType =>
      _selectedServiceLocationType;

  String? _newlyAddedAddressId;
  String? get newlyAddedAddressId => _newlyAddedAddressId;

  List<PredictionModel> get predictionList => _predictionList;
  PredictionModel? get firstPredictionModel => _firstPredictionModel;
  bool get isLoading => _isLoading;
  bool get loading => _loading;
  Position get position => _position;
  Position get pickPosition => _pickPosition;
  AddressModel get address => _address;
  AddressModel get pickAddress => _pickAddress;
  List<Marker> get markers => _markers;
  List<AddressModel>? get addressList => _addressList;
  int get addressLabelIndex => _addressLabelIndex;
  bool get inZone => _inZone;
  String get zoneID => _zoneID;
  bool get buttonDisabled => _buttonDisabled;
  bool get isCameraMoving => _isCameraMoving;
  MapController get mapController => _mapController!;

  ///address type like home , office , others
  Address get selectedAddressType => _selectedAddressType;
  AddressLabel get selectedAddressLabel => _selectedAddressLabel;
  AddressModel? get selectedAddress => _selectedAddress;
  double get minBottomSheetExtent => _minBottomSheetExtent;
  double get maxBottomSheetExtent => _maxBottomSheetExtent;

  set buttonDisabledOption(bool value) => _buttonDisabled = value;

  // Bottom Sheet State
  double _minBottomSheetExtent = 0.25;
  double _maxBottomSheetExtent = 0.85;

  void updateBottomSheetExtent(double min, double max) {
    _minBottomSheetExtent = min;
    _maxBottomSheetExtent = max;
    update();
  }

  Future<AddressModel> getCurrentLocation(
    bool fromAddress, {
    bool deviceCurrentLocation = false,
    MapController? mapController,
    LatLng? defaultLatLng,
    bool notify = true,
    bool isFromCheckout = false,
  }) async {
    _loading = true;
    if (notify) {
      update();
    }
    AddressModel addressModel;
    Position myPosition;
    try {
      final AddressModel? savedAddress = getUserAddress();
      final double? savedLatitude = double.tryParse(
        savedAddress?.latitude ?? '',
      );
      final double? savedLongitude = double.tryParse(
        savedAddress?.longitude ?? '',
      );

      if (!deviceCurrentLocation &&
          savedLatitude != null &&
          savedLongitude != null &&
          savedLatitude != 0 &&
          savedLongitude != 0) {
        myPosition = Position(
          latitude: savedLatitude,
          longitude: savedLongitude,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 1,
          heading: 1,
          speed: 1,
          speedAccuracy: 1,
          altitudeAccuracy: 1,
          headingAccuracy: 1,
        );
      } else if (defaultLatLng != null) {
        myPosition = Position(
          latitude: defaultLatLng.latitude,
          longitude: defaultLatLng.longitude,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 1,
          heading: 1,
          speed: 1,
          speedAccuracy: 1,
          altitudeAccuracy: 1,
          headingAccuracy: 1,
        );
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw StateError('Location permission was not granted');
        }

        Position? recentPosition;
        try {
          recentPosition = await Geolocator.getLastKnownPosition();
        } catch (_) {
          // A cached fix is optional; fall back to a fresh fix below.
        }
        final Duration? positionAge = recentPosition == null
            ? null
            : DateTime.now().difference(recentPosition.timestamp);
        if (recentPosition != null &&
            positionAge != null &&
            positionAge >= Duration.zero &&
            positionAge <= const Duration(minutes: 2) &&
            recentPosition.accuracy <= 100 &&
            (recentPosition.latitude != 0 || recentPosition.longitude != 0)) {
          myPosition = recentPosition;
        } else {
          myPosition = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 12),
            ),
          );
        }
      }
    } catch (e) {
      if (deviceCurrentLocation) {
        _loading = false;
        update();
        rethrow;
      }
      if (defaultLatLng != null) {
        myPosition = Position(
          latitude: defaultLatLng.latitude,
          longitude: defaultLatLng.longitude,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 1,
          heading: 1,
          speed: 1,
          speedAccuracy: 1,
          altitudeAccuracy: 1,
          headingAccuracy: 1,
        );
      } else {
        myPosition = Position(
          latitude:
              Get.find<SplashController>()
                  .configModel
                  .content
                  ?.defaultLocation
                  ?.latitude ??
              23.0000,
          longitude:
              Get.find<SplashController>()
                  .configModel
                  .content
                  ?.defaultLocation
                  ?.longitude ??
              90.0000,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 1,
          heading: 1,
          speed: 1,
          speedAccuracy: 1,
          altitudeAccuracy: 1,
          headingAccuracy: 1,
        );
      }
    }
    if (fromAddress) {
      _position = myPosition;
    } else {
      _pickPosition = myPosition;
    }
    if (mapController != null) {
      mapController.move(LatLng(myPosition.latitude, myPosition.longitude), 16);
    }
    final List<dynamic> locationResults = await Future.wait([
      getAddressFromGeocode(LatLng(myPosition.latitude, myPosition.longitude)),
      getZone(
        myPosition.latitude.toString(),
        myPosition.longitude.toString(),
        true,
        isLoading: fromAddress,
      ),
    ]);
    final AddressModel address = locationResults[0] as AddressModel;
    final ZoneResponseModel responseModel =
        locationResults[1] as ZoneResponseModel;

    if (isFromCheckout) {
      if (responseModel.zoneIds == getUserAddress()?.zoneId) {
        _buttonDisabled = false;
      } else {
        _buttonDisabled = true;
      }
    } else {
      _buttonDisabled = !responseModel.isSuccess;
    }

    String? firstName;

    if (Get.find<AuthController>().isLoggedIn() &&
        Get.find<UserController>().userInfoModel?.phone != null &&
        Get.find<UserController>().userInfoModel?.fName != null) {
      firstName = "${Get.find<UserController>().userInfoModel?.fName} ";
    }
    addressModel = AddressModel(
      latitude: myPosition.latitude.toString(),
      longitude: myPosition.longitude.toString(),
      addressType: 'others',
      zoneId: responseModel.isSuccess ? responseModel.zoneIds : '',
      address: address.address ?? "",
      country: address.country ?? "",
      house: address.house ?? "",
      street: address.street ?? "",
      city: address.city ?? "",
      zipCode: address.zipCode ?? "",
      addressLabel: AddressLabel.home.name,
      availableServiceCountInZone: responseModel.totalServiceCount,
      contactPersonNumber: firstName != null
          ? Get.find<UserController>().userInfoModel?.phone ?? ""
          : "",
      contactPersonName: firstName != null
          ? "$firstName${Get.find<UserController>().userInfoModel?.lName ?? ""}"
          : "",
    );

    fromAddress ? _address = addressModel : _pickAddress = addressModel;
    _loading = false;
    update();
    return addressModel;
  }

  Future<ZoneResponseModel> getZone(
    String lat,
    String long,
    bool markerLoad, {
    bool isLoading = false,
  }) async {
    if (!isLoading) {
      _isLoading = true;
    }
    update();
    try {
      final Response response = await locationRepo.getZone(lat, long);
      final dynamic body = response.body;
      final dynamic content = body is Map ? body['content'] : null;
      final dynamic zone = content is Map ? content['zone'] : null;
      final String zoneId = zone is Map ? zone['id']?.toString() ?? '' : '';
      final int totalServiceCount = content is Map
          ? int.tryParse(
                  content['available_services_count']?.toString() ?? '',
                ) ??
                0
          : 0;

      if (response.statusCode == 200 && zoneId.isNotEmpty) {
        _inZone = true;
        _zoneID = zoneId;
        return ZoneResponseModel(true, '', zoneId, totalServiceCount);
      }

      _inZone = false;
      _zoneID = '';
      final String message = body is Map
          ? body['message']?.toString() ?? 'Zone not found'
          : 'Zone not found';
      return ZoneResponseModel(false, message, '', totalServiceCount);
    } catch (_) {
      _inZone = false;
      _zoneID = '';
      return ZoneResponseModel(false, 'Zone check failed', '', 0);
    } finally {
      if (!isLoading) {
        _isLoading = false;
      }
      update();
    }
  }

  void updatePosition(
    LatLng target,
    bool fromAddress, {
    bool formCheckout = false,
  }) async {
    if (_updateAddAddressData) {
      _loading = true;
      update();
    }
    try {
      if (fromAddress) {
        _position = Position(
          latitude: target.latitude,
          longitude: target.longitude,
          timestamp: DateTime.now(),
          heading: 1,
          accuracy: 1,
          altitude: 1,
          speedAccuracy: 1,
          speed: 1,
          altitudeAccuracy: 1,
          headingAccuracy: 1,
        );
      } else {
        _pickPosition = Position(
          latitude: target.latitude,
          longitude: target.longitude,
          timestamp: DateTime.now(),
          heading: 1,
          accuracy: 1,
          altitude: 1,
          speedAccuracy: 1,
          speed: 1,
          altitudeAccuracy: 1,
          headingAccuracy: 1,
        );
      }
      final List<dynamic> locationResults = await Future.wait([
        getZone(
          target.latitude.toString(),
          target.longitude.toString(),
          true,
          isLoading: formCheckout,
        ),
        if (_changeAddress)
          getAddressFromGeocode(LatLng(target.latitude, target.longitude))
        else
          Future<AddressModel>.value(AddressModel()),
      ]);
      final ZoneResponseModel responseModel =
          locationResults[0] as ZoneResponseModel;
      if (formCheckout &&
          !responseModel.zoneIds.contains(getUserAddress()?.zoneId ?? '')) {
        Get.dialog(
          ConfirmationDialog(
            description: null,
            icon: null,
            onYesPressed: null,
            widget: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('this_service_not_available'.tr),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                CustomButton(buttonText: 'ok'.tr, onPressed: () => Get.back()),
              ],
            ),
          ),
        );
      } else {
        _buttonDisabled = !responseModel.isSuccess;
      }
      if (_changeAddress) {
        final AddressModel address = locationResults[1] as AddressModel;
        address.latitude = target.latitude.toString();
        address.longitude = target.longitude.toString();
        address.zoneId = responseModel.isSuccess ? responseModel.zoneIds : '';
        address.availableServiceCountInZone = responseModel.totalServiceCount;
        fromAddress ? _address = address : _pickAddress = address;
      } else {
        _changeAddress = true;
      }
    } catch (e) {
      // silent
    }
    if (_updateAddAddressData) {
      _loading = false;
    } else {
      _updateAddAddressData = true;
    }
    update();
  }

  Future<ResponseModel> deleteUserAddressByID(AddressModel address) async {
    ResponseModel responseModel;
    Response response = await locationRepo.removeAddressByID(address.id!);
    if (response.statusCode == 200 &&
        response.body['response_code'] == "default_delete_200") {
      await getAddressList();

      if (address.id == _selectedAddress?.id) {
        _selectedAddress = null;
      }
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(
        false,
        response.body['message'] ?? response.statusText,
      );
    }
    update();
    return responseModel;
  }

  Future<void> getAddressList({
    bool fromCheckout = false,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _addressList != null && _addressList!.isNotEmpty) {
      update();
      return;
    }
    Response response = await locationRepo.getAllAddress();
    if (response.statusCode == 200) {
      _addressList = <AddressModel>[];
      response.body['content']['data'].forEach((address) {
        _addressList!.add(AddressModel.fromJson(address));
      });
    } else {
      ApiChecker.checkApi(response);
    }
    if (_addressList != null && _addressList!.isNotEmpty) {
      for (var element in _addressList!) {
        if (element.id == getUserAddress()?.id) {
          _addressList?.remove(element);
          _addressList?.insert(0, element);
        }
      }
    }
    // _isLoading = false;

    update();
  }

  Future<void> addAddress(
    AddressModel addressModel,
    bool fromAddAddressScreen,
  ) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.addAddress(addressModel);
    if (response.body["response_code"] == "default_store_200") {
      // Store the newly added address ID for animation
      _newlyAddedAddressId = response.body["content"]["id"]?.toString();

      await getAddressList();

      // Clear the newly added address ID after animation duration (3 seconds)
      Future.delayed(const Duration(seconds: 3), () {
        _newlyAddedAddressId = null;
        update();
      });

      if (fromAddAddressScreen) {
        Get.back();
        if (addressModel.zoneId == getUserAddress()?.zoneId) {
          _selectedAddress = addressModel;
          customSnackBar(
            'new_address_added_successfully'.tr,
            type: ToasterMessageType.success,
          );
        } else {
          customSnackBar(
            'you_added_address_from_different_zone'.tr,
            type: ToasterMessageType.info,
          );
        }
      } else {
        await saveUserAddress(AddressModel.fromJson(response.body["content"]));
      }
    } else {
      customSnackBar(
        response.statusText == 'out_of_coverage'.tr
            ? 'service_not_available_in_this_area'.tr
            : response.statusText.toString().tr,
        type: ToasterMessageType.success,
      );
    }
    _isLoading = false;
    update();
  }

  Future<ResponseModel> updateAddress(
    AddressModel addressModel,
    String addressId,
  ) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.updateAddress(
      addressModel,
      addressId,
    );
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      await getAddressList();
      responseModel = ResponseModel(true, response.body["response_code"]);
    } else {
      responseModel = ResponseModel(false, response.statusText.toString().tr);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<bool> saveUserAddress(AddressModel address) async {
    String userAddress = jsonEncode(address.toJson());
    final bool saved = await locationRepo.saveUserAddress(
      userAddress,
      address.zoneId,
    );
    /// Single reset choke point: location/zone change hote hi radius state
    /// reset + Home/Services refresh (key-compare andar RadiusSearch me hai).
    if (saved && Get.isRegistered<RadiusSearchController>()) {
      unawaited(
        Get.find<RadiusSearchController>().onAddressSaved(address),
      );
    }
    return saved;
  }

  AddressModel? getUserAddress() {
    AddressModel? addressModelUser;
    try {
      addressModelUser = AddressModel.fromJson(
        jsonDecode(locationRepo.getUserAddress()!),
      );
      //_selectedAddress = addressModelUser;
    } catch (e) {
      return addressModelUser;
    }
    return addressModelUser;
  }

  ///
  Future<void> saveAddressAndNavigate(
    AddressModel address,
    bool fromSignUp,
    String? route,
    bool canRoute,
    bool isServiceAvailable, {
    bool fromAddressDialog = false,
    String? showDialog,
    bool zoneAlreadyValidated = false,
  }) async {
    final bool hasValidatedZone =
        zoneAlreadyValidated && (address.zoneId?.isNotEmpty ?? false);
    final ZoneResponseModel responseModel = hasValidatedZone
        ? ZoneResponseModel(
            true,
            '',
            address.zoneId!,
            address.availableServiceCountInZone ?? 0,
          )
        : await getZone(
            address.latitude.toString(),
            address.longitude.toString(),
            true,
          );
    AddressModel? previousAddress = getUserAddress();
    if (previousAddress != null) {
      setZoneContinue('true');
    }

    address.availableServiceCountInZone = responseModel.totalServiceCount;

    final bool userHasSavedAddress = getUserAddress() != null;

    if (!fromAddressDialog) {
      if (userHasSavedAddress) {
        // Existing user changing location - show confirmation
        Get.dialog(
          ConfirmationDialog(
            icon: Images.warning,
            title: 'are_you_sure_to_reset'.tr,
            description: 'if_you_change_location'.tr,
            onYesPressed: () {
              Get.back();
              _setZoneData(
                address,
                fromSignUp,
                route,
                canRoute,
                true,
                responseModel.zoneIds,
                previousAddress,
                isServiceAvailable,
                showDialog: showDialog,
              );
            },
            onNoPressed: () {
              Get.back();
              Get.back();
            },
          ),
        );
      } else {
        // New user - must set location first
        Get.dialog(
          ConfirmationDialog(
            icon: Images.warning,
            title: 'set_location_first'.tr,
            description: 'you_have_not_set_location'.tr,
            onYesPressed: () {
              Get.back();
              _setZoneData(
                address,
                fromSignUp,
                route,
                canRoute,
                true,
                responseModel.zoneIds,
                previousAddress,
                isServiceAvailable,
                showDialog: showDialog,
              );
            },
            onNoPressed: () {
              Get.back();
              Get.back();
            },
          ),
        );
      }
    } else {
      _setZoneData(
        address,
        fromSignUp,
        route,
        canRoute,
        false,
        responseModel.zoneIds,
        previousAddress,
        isServiceAvailable,
        showDialog: showDialog,
      );
    }
  }

  void _setZoneData(
    AddressModel address,
    bool fromSignUp,
    String? route,
    bool canRoute,
    bool shouldCartDelete,
    String? zoneIds,
    AddressModel? previousAddress,
    bool? isServiceAvailable, {
    String? showDialog,
  }) {
    if (zoneIds != null) {
      address.zoneId = zoneIds;
      autoNavigate(
        address,
        fromSignUp,
        route,
        canRoute,
        previousAddress,
        isServiceAvailable,
        shouldCartDelete: shouldCartDelete,
        showDialog: showDialog,
      );
    }
  }

  void autoNavigate(
    AddressModel address,
    bool fromSignUp,
    String? route,
    bool canRoute,
    AddressModel? previousAddress,
    bool? isServiceAvailable, {
    bool shouldCartDelete = false,
    String? showDialog,
  }) async {
    if (GetPlatform.isAndroid && !GetPlatform.isWeb) {
      if (getUserAddress() != null) {
        if (getUserAddress()!.zoneId != address.zoneId) {
          FirebaseMessaging.instance.unsubscribeFromTopic(
            'zone_${getUserAddress()!.zoneId}_customer',
          );
          FirebaseMessaging.instance.subscribeToTopic(
            'zone_${address.zoneId}_customer',
          );
        }
      } else {
        FirebaseMessaging.instance.subscribeToTopic(
          'zone_${address.zoneId}_customer',
        );
      }
    }
    await saveUserAddress(address);
    HomeScreen.loadData(true);
    if (canRoute && route != null && route != "" && route != "home") {
      Get.offAllNamed(route);
    } else {
      Get.offAllNamed(
        RouteHelper.getMainRoute(
          'home',
          previousAddress: previousAddress,
          showServiceNotAvailableDialog: showDialog,
        ),
      );
    }

    if (shouldCartDelete) {
      await Get.find<CartController>().removeAllCartItem();
    }
  }

  Future<AddressModel> setLocation(
    String placeID,
    String address,
    MapController? mapController,
  ) async {
    _loading = true;
    update();

    LatLng latLng = const LatLng(0, 0);

    AddressModel addressModel = AddressModel();
    addressModel.address = address;

    Response response;
    try {
      response = await locationRepo
          .getPlaceDetails(placeID)
          .timeout(const Duration(seconds: 12));
    } catch (_) {
      _loading = false;
      _buttonDisabled = true;
      update();
      customSnackBar('failed_to_get_location'.tr);
      return addressModel;
    }

    if (response.statusCode == 200) {
      PlaceDetailsModel placeDetails = PlaceDetailsModel.fromJson(
        response.body,
      );
      latLng = LatLng(
        placeDetails.content?.location?.latitude ?? 0,
        placeDetails.content?.location?.longitude ?? 0,
      );

      addressModel.latitude = latLng.latitude.toString();
      addressModel.longitude = latLng.longitude.toString();

      placeDetails.content?.addressComponents?.forEach((element) {
        if (element.types != null) {
          if (element.types!.contains("country")) {
            addressModel.country = element.longName ?? "";
          }
          if (element.types!.contains("locality") &&
              element.types!.contains("political")) {
            addressModel.city = element.longName ?? "";
          }
          if (element.types!.contains("street_number")) {
            addressModel.house = element.longName ?? "";
          }
          if (element.types!.contains("route")) {
            addressModel.street = element.longName ?? "";
          }
          if (element.types!.contains("postal_code")) {
            addressModel.zipCode = element.longName ?? "";
          }
        }
      });
    }

    _pickPosition = Position(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1,
    );

    _pickAddress = addressModel;
    _changeAddress = false;
    if (mapController != null) {
      mapController.move(latLng, 17);
    }

    if (latLng.latitude != 0 && latLng.longitude != 0) {
      ZoneResponseModel zoneResponse = await getZone(
        latLng.latitude.toString(),
        latLng.longitude.toString(),
        true,
      );
      _buttonDisabled = !zoneResponse.isSuccess;
      addressModel.zoneId = zoneResponse.isSuccess ? zoneResponse.zoneIds : '';
      addressModel.availableServiceCountInZone = zoneResponse.totalServiceCount;
    } else {
      _buttonDisabled = true;
    }

    _loading = false;
    update();

    return addressModel;
  }

  void disableButton() {
    _buttonDisabled = true;
    _inZone = true;
    update();
  }

  void setAddAddressData() {
    _position = _pickPosition;
    _address = _pickAddress;
    _updateAddAddressData = false;
    update();
  }

  void setUpdateAddress(AddressModel address) {
    _position = Position(
      latitude: double.parse(address.latitude!),
      longitude: double.parse(address.longitude!),
      timestamp: DateTime.now(),
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      floor: 1,
      accuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1,
    );
    _address.address = address.address!;
  }

  void updateAddressType(Address address) {
    _selectedAddressType = address;
    update();
  }

  void updateAddressLabel({
    AddressLabel? addressLabel,
    String addressLabelString = '',
  }) {
    if (addressLabel == null) {
      _selectedAddressLabel = _getAddressLabel(addressLabelString);
    } else {
      _selectedAddressLabel = addressLabel;
      update();
    }
  }

  AddressLabel _getAddressLabel(String addressLabel) {
    late AddressLabel label;
    if (AddressLabel.home.name.contains(addressLabel)) {
      label = AddressLabel.home;
    } else if (AddressLabel.office.name.contains(addressLabel)) {
      label = AddressLabel.office;
    } else {
      label = AddressLabel.others;
    }

    return label;
  }

  ///set address index to select address from address list
  Future<bool> setAddressIndex(
    AddressModel address, {
    bool fromAddressScreen = true,
  }) async {
    bool isSuccess = false;
    if (fromAddressScreen) {
      ZoneResponseModel selectedZone = await getZone(
        '${address.latitude}',
        '${address.longitude}',
        false,
      );
      if (selectedZone.zoneIds.contains(getUserAddress()?.zoneId ?? "")) {
        _selectedAddress = address;

        update();
        isSuccess = true;
      } else {
        isSuccess = false;
      }
    } else {
      _selectedAddress = address;
      update();
      isSuccess = true;
    }
    return isSuccess;
  }

  void resetAddress() {
    _address.address = '';
  }

  void setPickData() {
    _pickPosition = _position;
    _pickAddress = _address;
  }

  /// Initialize a manual map picker without starting GPS or network requests.
  /// The user can confirm a saved address immediately, or select a new point
  /// by searching/panning and let that selection be validated asynchronously.
  void initializePickPosition(LatLng position, {AddressModel? savedAddress}) {
    _pickPosition = Position(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1,
    );

    final String? zoneId = savedAddress?.zoneId;
    if (savedAddress != null && (zoneId?.isNotEmpty ?? false)) {
      _pickAddress = savedAddress;
      _buttonDisabled = false;
      _inZone = true;
      _zoneID = zoneId!;
    } else {
      _pickAddress = AddressModel(
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
        address: '',
      );
      _buttonDisabled = true;
      _inZone = false;
      _zoneID = '';
    }
    update();
  }

  void setMapController(MapController mapController) {
    _mapController = mapController;
  }

  Future<AddressModel> getAddressFromGeocode(LatLng latLng) async {
    final AddressModel address = AddressModel(
      address: 'Unknown Location Found',
    );
    try {
      final Response response = await locationRepo.getAddressFromGeocode(
        latLng,
      );
      final dynamic body = response.body;
      final dynamic content = body is Map ? body['content'] : null;
      final dynamic results = content is Map ? content['results'] : null;
      if (response.statusCode != 200 ||
          content is! Map ||
          content['status'] != 'OK' ||
          results is! List ||
          results.isEmpty) {
        return address;
      }

      final AddressFormat addressFormat = AddressFormat.fromJson(results[0]);

      addressFormat.addressComponents?.forEach((element) {
        if (element.types != null) {
          if (element.types!.contains("country")) {
            address.country = element.longName ?? "";
          }
          if (element.types!.contains("locality") &&
              element.types!.contains("political")) {
            address.city = element.longName ?? "";
          }
          if (element.types!.contains("street_number")) {
            address.house = element.longName ?? "";
          }
          if (element.types!.contains("route")) {
            address.street = element.longName ?? "";
          }

          if (element.types!.contains("postal_code")) {
            address.zipCode = element.longName ?? "";
          }
        }
      });
      address.address = addressFormat.formattedAddress ?? address.address;
    } catch (_) {
      return address;
    }
    return address;
  }

  Future<List<PredictionModel>> searchLocation(
    BuildContext context,
    String text,
  ) async {
    _firstPredictionModel = null;

    if (text.isNotEmpty) {
      Response response = await locationRepo.searchLocation(text);
      if (response.body['response_code'] == "default_200") {
        _predictionList = [];

        try {
          response.body['content']['suggestions'].forEach(
            (prediction) =>
                _predictionList.add(PredictionModel.fromJson(prediction)),
          );
        } catch (e) {
          _predictionList = [];
        }

        if (_predictionList.isNotEmpty) {
          _firstPredictionModel = _predictionList.first;
        }
      }
    }
    return _predictionList;
  }

  void setPlaceMark({
    AddressModel? addressModel,
    String? address,
    String? house,
    String? floor,
    String? city,
    String? country,
    String? zipCode,
    String? street,
  }) {
    if (addressModel != null) {
      _address = addressModel;
    }

    if (address != null) {
      _address.address = address;
    } else if (house != null) {
      _address.house = house;
    } else if (floor != null) {
      _address.floor = floor;
    } else if (city != null) {
      _address.city = city;
    } else if (country != null) {
      _address.country = country;
    } else if (zipCode != null) {
      _address.zipCode = zipCode;
    } else if (street != null) {
      _address.street = street;
    }
  }

  void updateSelectedAddress(
    AddressModel? addressModel, {
    bool shouldUpdate = true,
  }) {
    _selectedAddress = addressModel;

    if (shouldUpdate) {
      update();
    }
  }

  Future<void> updatePostInformation(String postId, String addressId) async {
    Response response = await locationRepo.changePostServiceAddress(
      postId,
      addressId,
    );

    if (response.statusCode == 200 &&
        response.body['response_code'] == "default_update_200") {
      customSnackBar(
        "service_schedule_updated_successfully".tr,
        type: ToasterMessageType.success,
      );
    }
  }

  Future<void> setZoneContinue(String isContinue) async {
    await locationRepo.setZoneContinue(isContinue);
  }

  String getZoneContinue() {
    return locationRepo.getZoneContinue();
  }

  void mapBound(
    MapController controller,
    List<Coordinates>? coordinates,
  ) async {
    List<LatLng> latLongList = [];

    if (coordinates != null) {
      for (int subIndex = 0; subIndex < coordinates.length; subIndex++) {
        latLongList.add(
          LatLng(
            coordinates[subIndex].latitude!,
            coordinates[subIndex].longitude!,
          ),
        );
      }
    }

    if (latLongList.isNotEmpty) {
      controller.fitCamera(
        CameraFit.bounds(
          bounds: MapHelper.boundsFromLatLngList(latLongList),
          padding: const EdgeInsets.all(100.5),
        ),
      );
    }

    update();
  }

  void updateCameraMovingStatus(bool status) {
    _isCameraMoving = status;
    update();
  }

  void updateSelectedServiceLocationType({
    ServiceLocationType? type,
    bool shouldUpdate = true,
  }) {
    if (type != null) {
      _selectedServiceLocationType = type;
      if (shouldUpdate) {
        update();
      }
    } else {
      _selectedServiceLocationType = ServiceLocationType.customer;
    }
  }
}
