import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class MyServicesRepo {
  final ApiClient apiClient;

  MyServicesRepo({required this.apiClient});

  Future<Response> getMyServices() async {
    return await apiClient.getData(AppConstants.myServiceManageUrl);
  }

  Future<Response> updateService({
    required String id,
    required Map<String, String> body,
    List<MultipartBody>? files,
  }) async {
    return await apiClient.postMultipartData(
      "${AppConstants.myServiceManageUrl}/$id",
      body,
      files,
      null,
    );
  }

  Future<Response> createService({
    required Map<String, String> body,
    required List<MultipartBody> files,
  }) async {
    return await apiClient.postMultipartData(
      AppConstants.myServiceManageUrl,
      body,
      files,
      null,
    );
  }

  Future<Response> deleteService(String id) async {
    return await apiClient.deleteData("${AppConstants.myServiceManageUrl}/$id");
  }
}
