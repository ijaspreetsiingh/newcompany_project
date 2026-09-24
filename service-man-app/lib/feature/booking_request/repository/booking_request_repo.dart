import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class BookingRequestRepo{
  final ApiClient apiClient;
  BookingRequestRepo({required this.apiClient});

  Future<Response> getBookingList(String requestType, int offset) async {
    return await apiClient.getData("${AppConstants.bookingRequestUrl}?limit=7&offset=$offset&booking_status=$requestType&service_type=all");
  }
  Future<Response> getBookingHistoryList(String requestType,int offset) async {
    return await apiClient.getData("${AppConstants.bookingRequestUrl}?limit=10&offset=$offset&booking_status=$requestType&service_type=all");
  }

  // ----- SERVICEMAN ACCEPT / REJECT (auto-assign flow) -----
  Future<Response> acceptBooking(String bookingId) async {
    return await apiClient.putData('${AppConstants.acceptBookingUrl}/$bookingId', {'_method': 'put'});
  }

  Future<Response> rejectBooking(String bookingId) async {
    return await apiClient.putData('${AppConstants.rejectBookingUrl}/$bookingId', {'_method': 'put'});
  }
}
