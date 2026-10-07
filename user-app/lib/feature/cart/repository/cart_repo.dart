import 'package:jdds/common/models/api_response_model.dart';
import 'package:jdds/common/repo/data_sync_repo.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class CartRepo extends DataSyncRepo{
  CartRepo({required super.apiClient, required SharedPreferences super.sharedPreferences});

  Future<Response> addToCartListToServer(CartModelBody cartModel) async {
    return await apiClient.postData(AppConstants.addToCart, cartModel.toJson());
  }

  Future<AptresponseModel<T>> getCartListFromServer<T>({required DataSourceEnum source}) async {
    return await fetchData<T>("${AppConstants.getCartList}&&guest_id=${Get.find<SplashController>().getGuestId()}", source);
  }

  Future<Response> removeCartFromServer(String cartID) async {
    return await apiClient.deleteData("${AppConstants.removeCartItem}$cartID?guest_id=${Get.find<SplashController>().getGuestId()}");
  }

  Future<Response> removeAllCartFromServer() async {
    return await apiClient.deleteData("${AppConstants.removeAllCartItem}?guest_id=${Get.find<SplashController>().getGuestId()}");
  }

  Future<Response> updateCartQuantity(String cartID, int quantity)async{
    return await apiClient.putData("${AppConstants.updateCartQuantity}$cartID?guest_id=${Get.find<SplashController>().getGuestId()}",
        {
          'quantity': quantity,
        }
    );
  }

  Future<Response> updateProvider(String providerId)async {
    return await apiClient.putData(AppConstants.updateCartProvider,
      { 'provider_id': providerId,
        "guest_id": Get.find<SplashController>().getGuestId()
      });
  }

  /// [latitude]/[longitude] diye ho to un par provider search (friend/other
  /// location booking), warna user ke saved address coordinates.
  Future<Response> getProviderBasedOnSubcategory(
    String subcategoryId, {
    double? latitude,
    double? longitude,
  }) async {
    double? lat = latitude;
    double? lng = longitude;
    if (lat == null || lng == null) {
      final userAddress = Get.find<LocationController>().getUserAddress();
      lat = double.tryParse(userAddress?.latitude ?? "");
      lng = double.tryParse(userAddress?.longitude ?? "");
    }
    String geoQuery = "";
    if (lat != null && lng != null) {
      geoQuery = "&latitude=$lat&longitude=$lng";
    }
    return await apiClient.getData("${AppConstants.getProviderBasedOnSubcategory}?sub_category_id=$subcategoryId$geoQuery");
  }

  Future<Response> addRebookToServer(String bookingId) async {
    return await apiClient.postData(AppConstants.rebookApi, {'booking_id' : bookingId, 'guest_id' : Get.find<SplashController>().getGuestId()} );
  }


}

