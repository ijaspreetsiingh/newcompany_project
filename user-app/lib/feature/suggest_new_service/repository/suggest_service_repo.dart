import 'package:jdds/api/remote/client_api.dart';
import 'package:jdds/util/app_constants.dart';
import 'package:get/get.dart';


class SuggestServiceRepo{
  final ApiClient apiClient;
  SuggestServiceRepo({required this.apiClient});

  Future<Response> getCategoryList() async {
    // categoryUrl already carries a limit; avoid conflicting duplicate query params.
    return await apiClient.getData('/api/v1/client/group?limit=100&offset=1');
  }

  Future<Response> getSuggestedServiceList(int offset) async {
    return await apiClient.getData('${AppConstants.getSuggestedServiceList}?limit=30&offset=$offset');
  }

  Future<Response> submitNewServiceRequest(Map<String,String> body) async {
    return await apiClient.postData(AppConstants.submitNewServiceRequest,body);
  }
}

