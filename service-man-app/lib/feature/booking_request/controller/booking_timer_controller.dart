import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:demandium_serviceman/feature/booking_details/model/booking_details_model.dart';

/// AUTO-ASSIGN: serviceman incoming booking popup ka countdown timer controller.
/// Backend se remaining seconds lekar countdown chalata hai,
/// accept/reject API call karta hai, expire hone par popup band karta hai.
class BookingTimerController extends GetxController implements GetxService {
  final BookingRequestRepo bookingRequestRepo;
  final BookingDetailsRepo bookingDetailsRepo;
  BookingTimerController({required this.bookingRequestRepo, required this.bookingDetailsRepo});

  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isLoading = false;
  bool _expired = false;
  bool _accepted = false;
  bool _rejected = false;
  String? _bookingId;
  BookingDetailsContent? _bookingDetails;
  BookingContent? _bookingContent;

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
    Response response = await bookingDetailsRepo.getBookingDetails(bookingID: bookingId, isSubBooking: false);
    if (response.statusCode == 200) {
      _bookingContent = BookingDetailsModel.fromJson(response.body).bookingContent;
      _bookingDetails = _bookingContent?.bookingDetailsContent;
    }
    _isLoading = false;

    // serviceman ke liye fixed 30 sec timer (plan ke according)
    _remainingSeconds = 30;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        update();
      } else {
        timer.cancel();
        _expired = true;
        update();

        // 3 sec baad popup close
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

    Response response = await bookingRequestRepo.acceptBooking(_bookingId!);
    if (response.statusCode == 200) {
      _timer?.cancel();
      _accepted = true;
      _isLoading = false;
      showCustomSnackBar('booking_accepted_successfully'.tr, type: ToasterMessageType.success);

      Future.delayed(const Duration(seconds: 2), () {
        _closePopupAndRefresh();
      });
    } else {
      _isLoading = false;
      ApiChecker.checkApi(response);
      _expired = true;
    }
    update();
  }

  Future<void> rejectBooking() async {
    if (_bookingId == null || _isLoading) return;
    _isLoading = true;
    update();

    await bookingRequestRepo.rejectBooking(_bookingId!);
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
      Get.find<BookingRequestController>().getBookingList(
        Get.find<BookingRequestController>().bookingStatusState.name.toLowerCase(), 1,
      );
    } catch (_) {}
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
