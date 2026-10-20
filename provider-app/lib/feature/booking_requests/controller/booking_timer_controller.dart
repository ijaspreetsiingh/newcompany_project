import 'dart:async';
import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:jassdbx_provider/feature/booking_details/model/bookings_details_model.dart';
import 'package:jassdbx_provider/feature/booking_details/model/assign_suggestion_model.dart';

/// AUTO-ASSIGN: incoming booking popup ka controller.
/// - booking details fetch karta hai
/// - countdown chalata hai (backend auto-assign-state se remaining seconds)
/// - eligible serviceman suggestions load; provider exactly one select karta hai
/// - assign / reject API call karta hai
/// - expire hone par popup close karke list refresh karta hai
class BookingTimerController extends GetxController implements GetxService {
  final BookingDetailsRepo bookingDetailsRepo;
  BookingTimerController({required this.bookingDetailsRepo});

  static const int maxTeamSize = 1;

  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isLoading = false;
  bool _expired = false;
  bool _accepted = false;
  bool _rejected = false;
  bool _assigned = false;
  bool _providerManualMode = false;
  String? _bookingId;
  BookingDetailsContent? _bookingDetails;

  // ---- assign suggestions (team) ----
  List<AssignSuggestion> _suggestions = [];
  bool _suggestionsLoading = false;
  bool _assigning = false;
  final Set<String> _selectedIds = {};

  int get remainingSeconds => _remainingSeconds;
  bool get isLoading => _isLoading;
  bool get expired => _expired;
  bool get accepted => _accepted;
  bool get rejected => _rejected;
  bool get assigned => _assigned;
  bool get providerManualMode => _providerManualMode;
  String? get bookingId => _bookingId;
  BookingDetailsContent? get bookingDetails => _bookingDetails;

  List<AssignSuggestion> get suggestions => _suggestions;
  bool get suggestionsLoading => _suggestionsLoading;
  bool get assigning => _assigning;
  List<String> get selectedIds => _selectedIds.toList();

  Future<void> startTimer(String bookingId) async {
    _bookingId = bookingId;
    _isLoading = true;
    update();

    // booking details fetch karo (popup me dikhane ke liye)
    Response response = await bookingDetailsRepo.getBookingDetails(bookingId);
    if (response.statusCode == 200) {
      _bookingDetails = BookingDetailsModel.fromJson(response.body).content;
    }
    _isLoading = false;

    bool windowActive = false;

    // backend se remaining time lo
    Response statusResponse = await bookingDetailsRepo.getAutoAssignStatus(bookingId);
    if (statusResponse.statusCode == 200) {
      final content = statusResponse.body['content'];
      if (content != null) {
        // backend float bhejta hai (16.75) — round karke lo warna parse fail hoga
        _remainingSeconds = (num.tryParse(content['remaining_seconds']?.toString() ?? '0') ?? 0).round();

        final String bookingStatus = content['booking_status']?.toString() ?? '';
        final String timerStatus = content['timer_status']?.toString() ?? '';
        _providerManualMode = content['assignment_mode']?.toString() == 'provider_manual' ||
            content['assignment_mode']?.toString() == 'manual_required';
        windowActive = bookingStatus == 'pending' && _providerManualMode;

        // Provider manual decision timer khatam hone ke baad bhi dashboard se
        // assign kar sakta hai. Accepted/canceled bookings close kar do.
        if (bookingStatus != 'pending' || (!_providerManualMode && timerStatus == 'accepted')) {
          Get.back();
          return;
        }
      }
    } else {
      _remainingSeconds = 120; // fallback
    }

    // decision window active hai toh serviceman suggestions load karo
    if (windowActive) {
      await loadSuggestions();
    }

    _timer?.cancel();
    if (!_providerManualMode) _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        update();
      } else {
        timer.cancel();
        if (!_assigned && !_accepted && !_rejected) {
          _expired = true;
          update();

          // 3 sec baad popup close karo
          Future.delayed(const Duration(seconds: 3), () {
            _closePopupAndRefresh();
          });
        }
      }
    });

    update();
  }

  /// Distance-sorted serviceman list (slot status ke saath)
  Future<void> loadSuggestions() async {
    if (_bookingId == null) return;
    _suggestionsLoading = true;
    update();

    Response response = await bookingDetailsRepo.getAssignSuggestions(_bookingId!);
    if (response.statusCode == 200 && response.body['content'] != null) {
      final List<dynamic> list = response.body['content']['servicemen'] ?? [];
      _suggestions = list.map((e) => AssignSuggestion.fromJson(e)).toList();
    }
    _suggestionsLoading = false;
    update();
  }

  /// Exactly one category-eligible serviceman can be selected.
  void toggleSuggestion(String servicemanId) {
    if (!_suggestions.any((item) => item.id == servicemanId && item.isCategoryMatch)) return;
    if (_selectedIds.contains(servicemanId)) {
      _selectedIds.remove(servicemanId);
    } else {
      _selectedIds.clear();
      _selectedIds.add(servicemanId);
    }
    update();
  }

  /// Selected (1-5) servicemen ko assign karo — pehla accept karne wala lead
  Future<void> assignSelected() async {
    if (_bookingId == null || _assigning) return;
    if (_selectedIds.isEmpty || _selectedIds.length > maxTeamSize) return;

    _assigning = true;
    update();

    Response response = await bookingDetailsRepo.assignServicemen(_bookingId!, _selectedIds.toList());
    if (response.statusCode == 200 &&
        (response.body['response_code'] == 'serviceman_assign_success_200' || response.body['response_code'] == 'default_200')) {
      _timer?.cancel();
      _assigned = true;
      _assigning = false;
      showCustomSnackBar('assigned_successfully'.tr, type: ToasterMessageType.success);

      Future.delayed(const Duration(seconds: 2), () {
        _closePopupAndRefresh();
      });
    } else {
      _assigning = false;
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> acceptBooking() async {
    if (_bookingId == null || _isLoading) return;
    _isLoading = true;
    update();

    Response response = await bookingDetailsRepo.acceptBookingRequest(_bookingId!);
    if (response.statusCode == 200 &&
        (response.body['response_code'] == 'status_update_success_200' || response.body['response_code'] == 'default_200')) {
      _timer?.cancel();
      _accepted = true;
      _isLoading = false;
      showCustomSnackBar('booking_accepted_successfully'.tr, type: ToasterMessageType.success);

      // 2 sec baad popup close
      Future.delayed(const Duration(seconds: 2), () {
        _closePopupAndRefresh();
      });
    } else {
      _isLoading = false;
      // expired ya koi aur error -> popup band karo
      ApiChecker.checkApi(response);
      _expired = true;
    }
    update();
  }

  Future<void> rejectBooking() async {
    if (_bookingId == null || _isLoading) return;
    _isLoading = true;
    update();

    // API success check zaroori hai — fail hone par bhi rejected dikhana ghost rejection thi
    Response response = await bookingDetailsRepo.ignoreBookingRequest(_bookingId!);
    if (response.statusCode == 200) {
      _timer?.cancel();
      _rejected = true;
      _isLoading = false;
      update();

      Future.delayed(const Duration(seconds: 2), () {
        _closePopupAndRefresh();
      });
    } else {
      // popup khula rakho taaki provider dobara try kar sake
      _isLoading = false;
      update();
      ApiChecker.checkApi(response);
    }
  }

  void _closePopupAndRefresh() {
    if (Get.currentRoute.contains(RouteHelper.incomingBookingPopup)) {
      Get.back();
    }
    try {
      final BookingRequestController bookingRequestController = Get.find<BookingRequestController>();
      bookingRequestController.getBookingRequestList(bookingRequestController.bookingStatus, 1, reload: true);
      Get.find<DashboardController>().getDashboardData(reload: true);
    } catch (_) {}
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
