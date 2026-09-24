
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class LocationService extends GetxService {
  StreamSubscription<Position>? _positionSubscription;
  Timer? _uploadTimer;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  bool _isActive = false;
  bool get isActive => _isActive;

  Future<void> startLocationTracking() async {
    if (_isActive) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    _isActive = true;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _currentPosition = position;
    });

    _uploadLocation();
    _uploadTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _uploadLocation();
    });
  }

  Future<void> _uploadLocation() async {
    if (_currentPosition == null) return;

    try {
      Response response = await Get.find<ApiClient>().postData(
        AppConstants.updateLocationUrl,
        {
          "lat": _currentPosition!.latitude.toString(),
          "lng": _currentPosition!.longitude.toString(),
        },
      );
      if (kDebugMode) {
        print("Location uploaded: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Location upload error: $e");
      }
    }
  }

  void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _uploadTimer?.cancel();
    _uploadTimer = null;
    _isActive = false;
    _currentPosition = null;
  }

  @override
  void onClose() {
    stopLocationTracking();
    super.onClose();
  }
}
