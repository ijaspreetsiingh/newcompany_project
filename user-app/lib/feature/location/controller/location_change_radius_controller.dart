import 'package:get/get.dart';
import 'package:jdds/feature/home/widget/location_change_radius_dialog.dart';
import 'package:jdds/util/core_export.dart';

/// Location change ke liye banya popup-based radius search flow.
/// Same admin settings se use karta hai (initial radius, max radius)
/// aur progressive expansion karta hai jab service nahi mile.
///
/// Flow:
///  1. User apna location set karta hai (address details ke sath)
///  2. Same zone check + radius search
///  3. Agar service nahi mile → popup: "Search with more radius"
///  4. Expand karte hi radius badhta hai, max tak
///  5. Final nahi mile → "not available" popup with "Change Address" button
class LocationChangeRadiusController extends GetxService {
  final LocationRepo locationRepo;
  LocationChangeRadiusController({required this.locationRepo});

  double? _initial;
  double? _max;
  double _step = 5.0;
  double _current = 0;
  bool _checking = false;
  bool _dialogOpen = false;
  bool _dismissed = false;
  bool _finalShown = false;
  String? _locationKey;

  double get initialRadius => _initial ?? 5;
  double get maxRadius => _max ?? 15;
  double get currentRadius => _current;

  static String locationKeyOf(AddressModel address) {
    final double lat = double.tryParse(address.latitude ?? '') ?? 0;
    final double lng = double.tryParse(address.longitude ?? '') ?? 0;
    return '${lat}_${lng}_${address.zoneId ?? ''}';
  }

  /// Naya location select hone par → reset + check.
  Future<void> onLocationChanged(AddressModel address) async {
    final String key = locationKeyOf(address);
    if (key == _locationKey) return;
    resetForNewLocation();
    _locationKey = key;
  }

  void resetForNewLocation() {
    _initial = null;
    _max = null;
    _current = 0;
    _checking = false;
    _dialogOpen = false;
    _dismissed = false;
    _finalShown = false;
    _locationKey = null;
  }

  /// Location change screen se call hona → agar service nahi mila to popup.
  Future<bool> checkAvailabilityAndPrompt(AddressModel address) async {
    if (_checking || _dialogOpen || _dismissed || _finalShown) return false;

    final double lat = double.tryParse(address.latitude ?? '') ?? 0;
    final double lng = double.tryParse(address.longitude ?? '') ?? 0;
    if (lat == 0 && lng == 0) return false;

    final String key = locationKeyOf(address);
    if (key != _locationKey) {
      resetForNewLocation();
      _locationKey = key;
    }

    _checking = true;
    try {
      // Config load karo (initial + max radius)
      if (!await _ensureConfig()) {
        _checking = false;
        return false;
      }

      if (_current <= 0) {
        _current = initialRadius;
      }

      // Check karo current radius me service available hai ya nahi
      final bool? found = await _providersWithinCurrentRadius(address);
      if (found == null || _locationKey != key) {
        _checking = false;
        return false;
      }

      if (found) {
        // Service available! → true return kar do, popup na dikha.
        _checking = false;
        return true;
      }

      // Service nahi mila → progressive popup flow
      if (_current >= maxRadius) {
        _finalShown = true;
        _showFinalDialog(address);
        _checking = false;
        return false;
      }

      // Expand popup dikha
      final double step = _step;
      final double next =
          (_current + step) > maxRadius ? maxRadius : (_current + step);

      _dialogOpen = true;
      LocationChangeRadiusDialog.show(
        currentRadius: _current,
        nextRadius: next,
        step: step,
        maxRadius: maxRadius,
        onExpand: () {
          _dialogOpen = false;
          _current = next;
          // Dobara check karo expanded radius se
          unawaited(checkAvailabilityAndPrompt(address));
        },
        onDismiss: () {
          _dialogOpen = false;
          _dismissed = true;
        },
      );

      _checking = false;
      return false;
    } catch (_) {
      _checking = false;
      return false;
    }
  }

  Future<bool> _ensureConfig() async {
    if (_initial != null && _max != null) return true;
    try {
      final Response response = await locationRepo.getSearchRadius();
      if (response.statusCode == 200 &&
          response.body is Map &&
          response.body['response_code'] == 'default_200') {
        final dynamic content = response.body['content'];
        double initial = 5;
        double max = 50;
        double step = 5;
        if (content is Map) {
          initial = (content['initial_radius'] as num?)?.toDouble() ?? 5;
          max = (content['max_radius'] as num?)?.toDouble() ?? 50;
          step = (content['radius_increment_step'] as num?)?.toDouble() ?? 5;
        }
        if (initial <= 0) initial = 5;
        if (max < initial) max = initial;
        if (step <= 0) step = initial;
        _initial = initial;
        _max = max;
        _step = step;
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Check providers within current radius.
  Future<bool?> _providersWithinCurrentRadius(AddressModel address) async {
    try {
      final Response response = await locationRepo.apiClient.postData(
        AppConstants.getProviderList,
        {
          'limit': 1,
          'offset': 1,
          'lat': address.latitude,
          'lng': address.longitude,
          'zone_id': address.zoneId,
        },
      );
      if (response.statusCode != 200) return null;
      final dynamic body = response.body;
      if (body is! Map || body['response_code'] != 'default_200') return null;

      final dynamic content = body['content'];
      if (content is Map && content['data'] is List) {
        return (content['data'] as List).isNotEmpty;
      }
      if (content is List) return content.isNotEmpty;
      return false;
    } catch (_) {
      return null;
    }
  }

  void _showFinalDialog(AddressModel address) {
    _dialogOpen = true;
    LocationChangeRadiusDialog.showFinal(
      radius: maxRadius,
      maxRadius: maxRadius,
      onDismiss: () {
        _dialogOpen = false;
      },
      onChangeAddress: () {
        _dialogOpen = false;
        Get.back(result: false); // Go back to location selection
      },
    );
  }
}
