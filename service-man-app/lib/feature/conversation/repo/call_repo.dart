import 'package:get/get.dart';
import '../../../api/api_client.dart';
import '../../../utils/app_constants.dart';

class CallRepo {
  final ApiClient apiClient;
  CallRepo({required this.apiClient});

  Future<Response> initiateCall(String calleeId, String callType, {String? bookingId}) async {
    return await apiClient.postData(AppConstants.callInitiateUrl, {
      'callee_id': calleeId,
      'call_type': callType,
      if (bookingId != null && bookingId.isNotEmpty) 'booking_id': bookingId,
    });
  }

  Future<Response> respondCall(String callId, String action) async {
    return await apiClient.postData(AppConstants.callRespondUrl, {
      'call_id': callId,
      'action': action,
    });
  }

  Future<Response> endCall(String callId) async {
    return await apiClient.postData(AppConstants.callEndUrl, {'call_id': callId});
  }

  Future<Response> activeCall() async {
    return await apiClient.getData(AppConstants.callActiveUrl);
  }

  Future<Response> callStatus(String callId) async {
    return await apiClient.getData('${AppConstants.callStatusUrl}?call_id=$callId');
  }

  Future<Response> callToken(String callId) async {
    return await apiClient.getData('${AppConstants.callTokenUrl}?call_id=$callId');
  }

  Future<Response> callHistory(int limit, int offset, {String? search, String? callStatus}) async {
    String url = '${AppConstants.callHistoryUrl}?limit=$limit&offset=$offset';
    if (search != null && search.isNotEmpty) url += '&search=$search';
    if (callStatus != null && callStatus.isNotEmpty) url += '&call_status=$callStatus';
    return await apiClient.getData(url);
  }
}
