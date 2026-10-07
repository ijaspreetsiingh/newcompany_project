import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class BusinessSettingRepo {
  final ApiClient apiClient;
  BusinessSettingRepo({required this.apiClient});

  Future<Response> updateBookingSettingIntoServer(String data) async {
    return await apiClient.putData(AppConstants.updateBusinessBookingSettings, {
      "data" : data
    });
  }

  Future<Response> getBookingSettingsFromServer(List<String> data) async {
    return await apiClient.getData(AppConstants.getBusinessBookingSettings);
  }


  Future<Response> updateServiceAvailabilitySettingIntoServer(Map<String, dynamic> body)  async {
    return await apiClient.putData(AppConstants.updateServiceAvailabilitySettings, body);
  }


  Future<Response> getServiceAvailabilitySettingsFromServer() async {
    return await apiClient.getData(AppConstants.getServiceAvailabilitySettings);
  }

}