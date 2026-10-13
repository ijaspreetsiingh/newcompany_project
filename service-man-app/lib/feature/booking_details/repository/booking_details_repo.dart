import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';


class BookingDetailsRepo{
  final ApiClient apiClient;

  BookingDetailsRepo({required this.apiClient});

  Future<Response> getBookingDetails({required  String bookingID, required bool isSubBooking}) async {
    return await apiClient.getData("${isSubBooking ? AppConstants.subBookingDetailsUrl : AppConstants.bookingDetailsUrl}$bookingID");
  }

  Future<Response> changeBookingStatus({required String bookingID,required String status, required  String otp, List<MultipartBody>? photoEvidence, required bool isSubBooking, String? startOtp}) async {
    final Map<String, String> fields = {'booking_status': status, '_method': 'put', 'booking_otp': otp};
    if (startOtp != null) {
      fields['start_otp'] = startOtp;
    }
    return await apiClient.postMultipartData("${ isSubBooking ? AppConstants.subBookingStatusUpdateUrl : AppConstants.bookingStatusUpdateUrl}/$bookingID", fields, photoEvidence, null
    );
  }

  /// Serviceman "Reached" — 300m radius me aakar start OTP generate karo
  Future<Response> markReached(String bookingID) async {
    return await apiClient.putData("${AppConstants.reachedBookingUrl}/$bookingID", {});
  }

  /// Extra service add (custom/external work with custom price)
  Future<Response> addExtraService({required String bookingID, required String name, required String price, required String quantity, String type = 'custom'}) async {
    return await apiClient.postData("${AppConstants.extraServiceUrl}/$bookingID", {
      'name': name,
      'price': price,
      'quantity': quantity,
      'type': type,
    });
  }

  /// Extra service remove
  Future<Response> removeExtraService({required String bookingID, required String extraServiceId}) async {
    return await apiClient.deleteData("${AppConstants.extraServiceUrl}/$bookingID/$extraServiceId");
  }

  /// Provider ki subscribed categories ki services (extra work ke liye select)
  Future<Response> getProviderServices() async {
    return await apiClient.getData(AppConstants.providerServicesUrl);
  }

  Future<Response> changePaymentStatus(String bookingID,String paymentStatus) async {
    return await apiClient.putData("${AppConstants.paymentStatusUpdate}/$bookingID",{'payment_status':paymentStatus});
  }

  Future<Response> getServiceListBasedOnSubcategory(String subCategoryId) async {
    return await apiClient.getData("${AppConstants.serviceListBasedOnSubCategory}?limit=200&offset=1&sub_category_id=$subCategoryId");
  }

  Future<Response> sendBookingOTPNotification(String? bookingId) {
    return apiClient.getData("${AppConstants.bookingOTPNotificationUri}?booking_id=$bookingId");
  }


  Future<Response> getBookingPriceList(String zoneId , String serviceInfo){
    return apiClient.getData("${AppConstants.getBookingPriceList}?zone_id=$zoneId&service_info=$serviceInfo");
  }

  Future<Response> removeCartServiceFromServer({CartModel? cart , String? bookingId, String? zoneId}){
    return apiClient.putData(AppConstants.removeCartServiceFromServer, {
      "booking_id" : bookingId,
      "zone_id" : zoneId,
      "variant_key" : cart?.variantKey,
      "service_id" : cart?.serviceId
    });
  }

  Future<Response> updateBooking({ required bool isSubBooking, String? bookingId, String? subBookingId, String? zoneId, String? paymentStatus, String? servicemanId, String? bookingStatus, String? serviceSchedule, String? serviceInfo }){
    return apiClient.putData(isSubBooking ? AppConstants.updateSubBooking : AppConstants.updateRegularBooking, {
      "booking_id" : bookingId,
      "booking_repeat_id": subBookingId,
      "zone_id" : zoneId,
      "payment_status" : paymentStatus,
      "serviceman_id" : servicemanId,
      "booking_status" : bookingStatus,
      "service_schedule" : serviceSchedule,
      "service_info" : serviceInfo
    });
  }

}

