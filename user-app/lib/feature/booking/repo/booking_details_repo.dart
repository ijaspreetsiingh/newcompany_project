import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';


class BookingDetailsRepo{
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;
  BookingDetailsRepo({required this.sharedPreferences,required this.apiClient});


  Future<Response> getBookingDetails({required String bookingID})async{
    return await apiClient.getData("${AppConstants.bookingDetails}/$bookingID");
  }

  Future<Response> getSubBookingDetails({required String bookingID})async{
    return await apiClient.getData("${AppConstants.subBookingDetails}/$bookingID");
  }

  Future<Response> trackBookingDetails({required String bookingID, required String phoneNUmber})async{
    return await apiClient.postData("${AppConstants.trackBooking}/$bookingID",{
      "phone": phoneNUmber
    });
  }


  Future<Response> bookingCancel({required String bookingID}) async {
    return await apiClient.putData('${AppConstants.bookingCancel}/$bookingID', {
      "booking_status" :"canceled"}, timeout: 30);
  }

  Future<Response> subBookingCancel({required String bookingID}) async {
    return await apiClient.postData(
      '${AppConstants.subBookingCancel}/$bookingID',
      {},
      timeout: 30,
    );
  }

  /// Completed booking ko rechecking me dalna (7 din ka window).
  Future<Response> requestRecheck({required String bookingID, String reason = ''}) async {
    return await apiClient.postData(
      '${AppConstants.recheckRequest}/$bookingID',
      {'reason': reason},
      timeout: 30,
    );
  }

  Future<Response> getRecheckStatus({required String bookingID}) async {
    return await apiClient.getData('${AppConstants.recheckStatus}/$bookingID');
  }

  /// UNSATISFIED: completed booking par free re-service raise
  /// (same serviceman ke paas, admin-set window tak).
  Future<Response> raiseUnsatisfied({required String bookingID, String reason = ''}) async {
    return await apiClient.postData(
      '${AppConstants.unsatisfiedRequest}/$bookingID',
      {'reason': reason},
      timeout: 30,
    );
  }

  Future<Response> getUnsatisfiedStatus({required String bookingID}) async {
    return await apiClient.getData('${AppConstants.unsatisfiedStatus}/$bookingID');
  }

  Future<void>  setLastIncompleteOfflineBookingId(String bookingId) async {
    await sharedPreferences.setString(AppConstants.lastIncompleteOfflineBookingId, bookingId);
  }

  String getLastIncompleteOfflineBookingId() {
    return sharedPreferences.getString(AppConstants.lastIncompleteOfflineBookingId) ?? "";
  }

}

