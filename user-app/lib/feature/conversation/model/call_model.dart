class CallItem {
  String? id;
  String? callType;
  String? status;
  String? direction;
  int? duration;
  String? createdAt;
  String? answeredAt;
  String? endedAt;
  String? bookingId;
  String? channelId;
  Map<String, dynamic>? otherUser;

  CallItem({this.id, this.callType, this.status, this.direction, this.duration, this.createdAt, this.answeredAt, this.endedAt, this.bookingId, this.channelId, this.otherUser});

  CallItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    callType = json['call_type'];
    status = json['status'];
    direction = json['direction'];
    duration = json['duration'] ?? 0;
    createdAt = json['created_at'];
    answeredAt = json['answered_at'];
    endedAt = json['ended_at'];
    bookingId = json['booking_id'];
    channelId = json['channel_id'];
    otherUser = json['other_user'] != null ? Map<String, dynamic>.from(json['other_user']) : null;
  }
}

class CallStatusData {
  String? id;
  String? callType;
  String? status;
  String? direction;
  int? duration;
  String? bookingId;
  String? channelId;
  Map<String, dynamic>? otherUser;
  String? agoraAppId;
  String? channelName;
  int? rtcUid;
  String? rtcToken;
  int? tokenExpireIn;

  CallStatusData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    callType = json['call_type'];
    status = json['status'];
    direction = json['direction'];
    duration = json['duration'] ?? 0;
    bookingId = json['booking_id'];
    channelId = json['channel_id'];
    otherUser = json['other_user'] != null ? Map<String, dynamic>.from(json['other_user']) : null;
    agoraAppId = json['agora_app_id'];
    channelName = json['channel_name'];
    rtcUid = json['rtc_uid'];
    rtcToken = json['rtc_token'];
    tokenExpireIn = json['token_expire_in'];
  }
}
