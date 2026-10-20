import 'package:jdds/api/remote/client_api.dart';
import 'package:get/get.dart';
import 'package:jdds/util/app_constants.dart';

class ServiceDetailsRepo {
  final ApiClient apiClient;
  ServiceDetailsRepo({required this.apiClient});

  Future<Response> getServiceDetails(String slug, String fromPage) async {
    if (fromPage == "search_page") {
      return await apiClient.getData('${AppConstants.serviceDetailsUri}/$slug?attribute=service');
    } else {
      return await apiClient.getData('${AppConstants.serviceDetailsUri}/$slug');
    }
  }

  /// Fetch paginated reviews for [slug] (service id/slug).
  /// [zoneId] — user's current zone; when non-empty the backend filters reviews
  /// to only those whose booking was placed in that zone, and the rating
  /// summary (avg + star bars) is also zone-scoped.
  Future<Response> getServiceReviewList(String slug, int offset, {String? zoneId}) async {
    String url = '${AppConstants.getServiceReviewList}$slug?offset=$offset&limit=10';
    if (zoneId != null && zoneId.isNotEmpty) {
      url += '&zone_id=$zoneId';
    }
    return await apiClient.getData(url);
  }
}
