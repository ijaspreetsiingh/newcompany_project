import 'dart:convert';
import 'package:get/get.dart';
import 'package:jassdbx_provider/feature/profile/repository/user_repo.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class CancelledBookingController extends GetxController {
  final UserRepo userRepo;
  CancelledBookingController({required this.userRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _assigningBookingId;
  String? get assigningBookingId => _assigningBookingId;

  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> get bookings => _bookings;

  Future<void> loadBookings({bool refresh = false}) async {
    _isLoading = true;
    if (refresh) _bookings = [];
    update();

    try {
      final Response response = await userRepo.getCancelledByServicemanBookings(1);
      if (response.statusCode == 200) {
        dynamic body = response.body;
        if (body is String) {
          try { body = jsonDecode(body); } catch (_) {}
        }
        if (body is Map) {
          final dynamic content = body['content'];
          List<dynamic> rows = [];
          if (content is Map && content['data'] is List) {
            rows = content['data'];
          } else if (content is List) {
            rows = content;
          }
          _bookings = rows
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[CancelledBookings] load error: $e');
    }

    _isLoading = false;
    update();
  }

  Future<void> assignServiceman(String bookingId, String servicemanId) async {
    _assigningBookingId = bookingId;
    update();

    try {
      final Response response = await userRepo.manualAssignAfterCancel(
        bookingId: bookingId,
        servicemanId: servicemanId,
      );
      if (response.statusCode == 200) {
        showCustomSnackBar('serviceman_assigned_successfully'.tr,
            type: ToasterMessageType.success);
        // Remove from list — manual assign done
        _bookings.removeWhere((b) => b['id'] == bookingId);
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[CancelledBookings] assign error: $e');
    }

    _assigningBookingId = null;
    update();
  }
}
