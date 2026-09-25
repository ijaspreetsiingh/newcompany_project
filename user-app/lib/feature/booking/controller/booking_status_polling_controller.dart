import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

/// AUTO-ASSIGN: booking place hone ke baad ye controller har 3 seconds me
/// booking status poll karta hai. Jab provider accept kar leta hai toh
/// callback fire hota hai (UI "Provider Found!" dikhane ke liye).
class BookingStatusPollingController extends GetxController implements GetxService {
  final BookingDetailsRepo bookingDetailsRepo;
  BookingStatusPollingController({required this.bookingDetailsRepo});

  Timer? _timer;
  bool _isPolling = false;
  bool _providerFound = false;
  int _pollCount = 0;
  static const int _maxPollCount = 100; // ~5 min baad stop

  BookingDetailsContent? _bookingDetails;

  bool get isPolling => _isPolling;
  bool get providerFound => _providerFound;
  BookingDetailsContent? get bookingDetails => _bookingDetails;

  final List<Function(BookingDetailsContent)> _onProviderFoundCallbacks = [];

  void onProviderFound(Function(BookingDetailsContent) callback) {
    _onProviderFoundCallbacks.add(callback);
  }

  void startPolling(String bookingId) {
    stopPolling();
    _isPolling = true;
    _providerFound = false;
    _pollCount = 0;
    update();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollCount++;
      if (_pollCount > _maxPollCount) {
        stopPolling();
        return;
      }

      try {
        Response response = await bookingDetailsRepo.getBookingDetails(bookingID: bookingId);
        if (response.statusCode == 200) {
          final content = BookingDetailsContent.fromJson(response.body['content']);
          _bookingDetails = content;

          // provider assign ho gaya aur accepted hai
          if (content.providerId != null &&
              content.providerId!.isNotEmpty &&
              (content.bookingStatus == 'accepted' || content.bookingStatus == 'ongoing')) {
            _providerFound = true;
            stopPolling();

            for (final callback in _onProviderFoundCallbacks) {
              callback(content);
            }
          }
        }
      } catch (_) {}
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
    _isPolling = false;
    update();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
