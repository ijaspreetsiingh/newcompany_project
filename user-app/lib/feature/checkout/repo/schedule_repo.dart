import 'package:jdds/api/remote/client_api.dart';
import 'package:get/get.dart';
import 'package:jdds/util/app_constants.dart';

class ScheduleRepo extends GetxService {
  final ApiClient apiClient;
  ScheduleRepo({required this.apiClient});

  Future<Response> changePostScheduleTime(String postId, String scheduleTime) async {
    return await apiClient.putData(AppConstants.updatePostInfo,{
      "post_id":postId,
      "booking_schedule":scheduleTime
    });
  }
}

