import 'dart:async';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/booking_details/model/bookings_details_model.dart';

/// AUTO-ASSIGN: incoming booking popup ka countdown timer controller.
/// - booking details fetch karta hai
/// - countdown chalata hai (backend se remaining seconds le kar)
/// - accept/reject API call karta hai
/// - expire hone par popup close karke list refresh karta hai
class BookingTimerController extends GetxController implements GetxService {
  final BookingDetailsRepo bookingDetailsRepo;
  BookingTimerController({required this.bookingDetailsRepo});

  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isLoading = false;
  bool _expired = false;
  bool _accepted = false;
  bool _rejected = false;
  String? _bookingId;
  BookingDetailsContent? _bookingDetails;

  int get remainingSeconds => _remainingSeconds;
  bool get isLoading => _isLoading;
  bool get expired => _expired;
  bool get accepted => _accepted;
  bool get rejected => _rejected;
  String? get bookingId => _bookingId;
  BookingDetailsContent? get bookingDetails => _bookingDetails;

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

    // backend se remaining time lo
    Response statusResponse = await bookingDetailsRepo.getAutoAssignStatus(bookingId);
    if (statusResponse.statusCode == 200) {
      final content = statusResponse.body['content'];
      if (content != null) {
        _remainingSeconds = (int.tryParse(content['remaining_seconds']?.toString() ?? '0') ?? 0);

        // booking already accepted/canceled hai toh popup band karo
        final String bookingStatus = content['booking_status']?.toString() ?? '';
        if (bookingStatus != 'pending') {
          Get.back();
          return;
        }
      }
    } else {
      _remainingSeconds = 120; // fallback
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        update();
      } else {
        timer.cancel();
        _expired = true;
        update();

        // 3 sec baad popup close karo
        Future.delayed(const Duration(seconds: 3), () {
          _closePopupAndRefresh();
        });
      }
    });

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

    await bookingDetailsRepo.ignoreBookingRequest(_bookingId!);
    _timer?.cancel();
    _rejected = true;
    _isLoading = false;
    update();

    Future.delayed(const Duration(seconds: 2), () {
      _closePopupAndRefresh();
    });
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
