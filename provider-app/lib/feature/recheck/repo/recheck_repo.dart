import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class RecheckRepo {
  final ApiClient apiClient;
  RecheckRepo({required this.apiClient});

  Future<Response> getRecheckSummary(int offset, {String status = 'all'}) async {
    return await apiClient.getData(
      '${AppConstants.recheckSummaryUri}?limit=20&offset=$offset&status=$status',
    );
  }
}
