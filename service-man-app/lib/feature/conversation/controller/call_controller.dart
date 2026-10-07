import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../model/call_model.dart';
import '../repo/call_repo.dart';
import '../view/incoming_call_screen.dart';
import '../view/voice_call_screen.dart';

class CallController extends GetxController {
  final CallRepo callRepo;
  CallController({required this.callRepo});

  bool loading = false;
  List<CallItem> historyList = [];
  bool hasMoreHistory = true;
  int historyOffset = 1;
  bool historyLoading = false;

  void resetHistory() {
    historyList = [];
    historyOffset = 1;
    hasMoreHistory = true;
  }

  Future<void> startCall({required String calleeId, String callType = 'voice', String? bookingId, String? name, String? image, String? phone}) async {
    loading = true;
    update();
    final response = await callRepo.initiateCall(calleeId, callType, bookingId: bookingId);
    loading = false;
    update();

    if (response.statusCode == 200 && response.body['response_code'] == 'DEFAULT_200') {
      final data = response.body['content'];
      Get.to(() => VoiceCallScreen(
            callId: data['id'],
            callType: data['call_type'] ?? callType,
            isOutgoing: true,
            userName: data['other_user']?['name'] ?? name ?? '',
            userImage: data['other_user']?['image'] ?? image ?? '',
            userPhone: data['other_user']?['phone'] ?? phone ?? '',
          ));
    } else {
      final msg = response.body?['message']?.toString() ?? 'failed'.tr;
      if (response.statusCode == 403 && phone != null && phone.isNotEmpty) {
        try {
          final bool dialled = await launchUrl(Uri(scheme: 'tel', path: phone));
          if (dialled) return;
        } catch (_) {}
        showCustomSnackBar('$msg ($phone)');
      } else if (phone != null && phone.isNotEmpty) {
        showCustomSnackBar('$msg ($phone)');
      } else {
        showCustomSnackBar(msg);
      }
    }
  }

  Future<CallStatusData?> acceptCall(String callId) async {
    final response = await callRepo.respondCall(callId, 'accept');
    if (response.statusCode == 200 && response.body['response_code'] == 'DEFAULT_200') {
      return CallStatusData.fromJson(response.body['content']);
    }
    showCustomSnackBar(response.body?['message']?.toString() ?? 'failed'.tr);
    return null;
  }

  Future<void> rejectCall(String callId) async {
    try {
      await callRepo.respondCall(callId, 'reject');
    } catch (_) {}
  }

  Future<void> endCall(String callId) async {
    try {
      await callRepo.endCall(callId);
    } catch (_) {}
  }

  Future<CallStatusData?> getStatus(String callId) async {
    try {
      final response = await callRepo.callStatus(callId);
      if (response.statusCode == 200 && response.body['response_code'] == 'DEFAULT_200') {
        return CallStatusData.fromJson(response.body['content']);
      }
    } catch (_) {}
    return null;
  }

  Future<CallStatusData?> getActiveCall() async {
    try {
      final response = await callRepo.activeCall();
      if (response.statusCode == 200 && response.body['response_code'] == 'DEFAULT_200') {
        final data = response.body['content'];
        if (data != null && data['id'] != null) {
          return CallStatusData.fromJson(data);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> recoverActiveCall() async {
    final call = await getActiveCall();
    if (call == null) return;
    if (Get.currentRoute.contains('voice-call') || Get.currentRoute.contains('incoming-call')) return;
    if (call.status == 'ringing' && call.direction == 'in') {
      Get.to(() => IncomingCallScreen(
            callId: call.id ?? '',
            callType: call.callType ?? 'voice',
            userName: call.otherUser?['name'] ?? '',
            userImage: call.otherUser?['image'] ?? '',
            bookingId: call.bookingId,
          ));
    } else {
      Get.to(() => VoiceCallScreen(
            callId: call.id ?? '',
            callType: call.callType ?? 'voice',
            isOutgoing: call.direction == 'out',
            userName: call.otherUser?['name'] ?? '',
            userImage: call.otherUser?['image'] ?? '',
            userPhone: call.otherUser?['phone'] ?? '',
          ));
    }
  }

  void handleCallPush(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? '';
    final callId = data['call_id']?.toString() ?? '';
    if (callId.isEmpty) return;

    if (type == 'call_invite') {
      if (Get.currentRoute.contains('incoming-call')) return;
      Get.to(() => IncomingCallScreen(
            callId: callId,
            callType: data['call_type']?.toString() ?? 'voice',
            userName: data['user_name']?.toString() ?? '',
            userImage: data['user_image']?.toString() ?? '',
            bookingId: data['booking_id']?.toString(),
          ));
    }
  }

  Future<void> loadHistory({bool reload = false, String? callStatus}) async {
    if (historyLoading) return;
    if (reload) resetHistory();
    if (!reload && !hasMoreHistory) return;
    historyLoading = true;
    update();

    final response = await callRepo.callHistory(20, historyOffset, callStatus: callStatus);
    if (response.statusCode == 200 && response.body['response_code'] == 'DEFAULT_200') {
      final content = response.body['content'];
      final items = content?['callHistory']?['data'];
      if (items != null) {
        final newItems = List<CallItem>.from(items.map((e) => CallItem.fromJson(e)));
        if (reload) {
          historyList = newItems;
        } else {
          historyList.addAll(newItems);
        }
        historyOffset += newItems.length;
        hasMoreHistory = newItems.length >= 20;
      }
    }
    historyLoading = false;
    update();
  }

  String formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  String callStatusText(String? status) {
    switch (status) {
      case 'answered':
      case 'ended':
        return 'completed'.tr;
      case 'missed':
        return 'missed'.tr;
      case 'rejected':
        return 'declined'.tr;
      case 'cancelled':
        return 'cancelled'.tr;
      case 'ringing':
        return 'ringing'.tr;
      default:
        return status ?? '';
    }
  }
}
