import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jassdbx_serviceman/feature/auth/repository/auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Online/offline work availability ("Available for jobs" toggle).
/// Local + backend dono par save hota hai — backend auto-assign sirf
/// on-duty (is_on_duty=1) servicemen ko karta hai.
class WorkStatusService {
  WorkStatusService._();

  static const String _key = 'serviceman_work_status';

  static final ValueNotifier<bool> online = ValueNotifier(true);

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      online.value = prefs.getBool(_key) ?? true;
    } catch (_) {}
  }

  static Future<void> setStatus(bool value) async {
    online.value = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, value);
    } catch (_) {}

    // Backend ko bhi bhejo (fire & forget — local to save ho hi chuka)
    try {
      Get.find<AuthRepo>().updateWorkStatus(value);
    } catch (_) {}
  }

  /// App start par backend se actual duty status lao (login ke baad)
  static Future<void> syncFromServer() async {
    try {
      final response = await Get.find<AuthRepo>().getWorkStatus();
      if (response != null && response.statusCode == 200) {
        final dynamic content = response.body['content'];
        if (content is Map && content['is_on_duty'] != null) {
          final bool isOnDuty = '${content['is_on_duty']}' == '1';
          online.value = isOnDuty;
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_key, isOnDuty);
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
}
