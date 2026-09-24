import 'package:jdds/common/models/api_response_model.dart';
import 'package:jdds/common/repo/data_sync_repo.dart';
import 'package:jdds/util/core_export.dart';

class WebLandingRepo extends DataSyncRepo {
  WebLandingRepo({required super.apiClient, required SharedPreferences super.sharedPreferences});


  Future<ApiResponseModel<T>> getWebLandingContents<T>({required DataSourceEnum source}) async {
    return await fetchData<T>( AppConstants.webLandingContents, source);
  }

}