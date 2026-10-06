import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class CategoryAssignmentRepo {
  final ApiClient apiClient;

  CategoryAssignmentRepo({required this.apiClient});

  Future<Response> getAssignment() async {
    return await apiClient.getData(AppConstants.categoryAssignmentUrl);
  }

  Future<Response> submitRequest({
    required String requestType,
    List<String> subCategoryIds = const [],
    String note = "",
  }) async {
    return await apiClient.postData(AppConstants.categoryAssignmentRequestUrl, {
      'request_type': requestType,
      'sub_category_ids': subCategoryIds,
      'note': note,
    });
  }
}
