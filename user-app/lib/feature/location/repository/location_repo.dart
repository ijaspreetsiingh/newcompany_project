import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class LocationRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  LocationRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> getAllAddress() async {
    return await apiClient.getData(
      "${AppConstants.addressUri}?limit=100&offset=1&guest_id=${Get.find<SplashController>().getGuestId()}",
    );
  }

  Future<Response> getZone(String lat, String lng) async {
    return await apiClient.getData(
      '${AppConstants.zoneUri}?lat=$lat&lng=$lng',
      headers: AppConstants.configHeader,
    );
  }

  /// Zone ka initial + maximum search radius (progressive radius popup flow).
  Future<Response> getSearchRadius() async {
    return await apiClient.getData(AppConstants.searchRadiusUri);
  }

  Future<Response> removeAddressByID(String id) async {
    return await apiClient.deleteData("${AppConstants.addressUri}/$id?guest_id=${Get.find<SplashController>().getGuestId()}");
  }

  Future<Response> addAddress(AddressModel addressModel) async {
    return await apiClient.postData(
      "${AppConstants.addressUri}?guest_id=${Get.find<SplashController>().getGuestId()}",
      addressModel.toJson(),
    );
  }

  Future<Response> updateAddress(
    AddressModel addressModel,
    String addressId,
  ) async {
    return await apiClient.putData(
      '${AppConstants.addressUri}/$addressId?guest_id=${Get.find<SplashController>().getGuestId()}',
      addressModel.toJson(),
    );
  }

  Future<bool> saveUserAddress(String address, String? zoneIDs) async {
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token),
      zoneIDs,
      sharedPreferences.getString(AppConstants.languageCode),
      sharedPreferences.getString(AppConstants.guestId),
    );
    return await sharedPreferences.setString(AppConstants.userAddress, address);
  }

  Future<Response> getAddressFromGeocode(LatLng? latLng) async {
    return await apiClient.getData(
      '${AppConstants.geocodeUri}?lat=${latLng!.latitude}&lng=${latLng.longitude}',
      headers: AppConstants.configHeader,
    );
  }

  String? getUserAddress() {
    return sharedPreferences.getString(AppConstants.userAddress);
  }

  Future<Response> searchLocation(String text) async {
    final String uri = Uri.parse(
      AppConstants.searchLocationUri,
    ).replace(queryParameters: {'search_text': text}).toString();
    return await apiClient.getData(uri);
  }

  Future<Response> getPlaceDetails(String placeID) async {
    return await apiClient.getData(
      '${AppConstants.placeDetailsUri}?placeid=$placeID',
    );
  }

  Future<Response> changePostServiceAddress(
    String postId,
    String addressId,
  ) async {
    return await apiClient.putData(AppConstants.updatePostInfo, {
      "post_id": postId,
      "service_address_id": addressId,
    });
  }

  Future<void> setZoneContinue(String isContinue) async {
    await sharedPreferences.setString(AppConstants.isContinueZone, isContinue);
  }

  String getZoneContinue() {
    return sharedPreferences.getString(AppConstants.isContinueZone) ?? "";
  }
}
