import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local online/offline work availability flag (reference "Work availability"
/// toggle on the dashboard and "Available for jobs" on the profile).
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
  }
}
