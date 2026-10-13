import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class UnsatisfiedRepo {
  final ApiClient apiClient;
  UnsatisfiedRepo({required this.apiClient});

  Future<Response> getUnsatisfiedSummary(int offset, {String status = 'all'}) async {
    return await apiClient.getData(
      '${AppConstants.unsatisfiedSummaryUri}?limit=20&offset=$offset&status=$status',
    );
  }
}
