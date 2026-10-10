import 'package:get/get.dart';
import 'package:jdds/common/widgets/address_selection_bottom_sheet.dart';
import 'package:jdds/feature/home/widget/radius_search_bottom_sheet.dart';
import 'package:jdds/util/core_export.dart';

/// ⚡ ULTRA-FAST Progressive radius search - NO BLOCKING CALLS
/// Niyam:
///  1. Default values used immediately (5km initial, 50km max)
///  2. Config fetched in BACKGROUND - never blocks popup
///  3. Agar current radius me koi provider NA mile → popup INSTANTLY
///  4. Expand karne par radius badhta hai, max tak
///  5. Location change hote hi state reset + refresh
class RadiusSearchController extends GetxService {
  final LocationRepo locationRepo;
  RadiusSearchController({required this.locationRepo});

  static final ValueNotifier<int> homeGate = ValueNotifier<int>(0);

  // DEFAULT VALUES - NO WAIT FOR API
  double _initial = 5.0;
  double _max = 50.0;
  double _step = 5.0;
  int _maxAttempts = 5;
  bool _popupEnabled = true;
  int _attempts = 0;
  double _current = 0;
  bool _checking = false;
  bool _dialogOpen = false;
  bool _dismissed = false;
  bool _finalShown = false;
  String? _locationKey;
  bool _configFetched = false;

  double get initialRadius => _initial;
  double get maxRadius => _max;
  double get currentRadius => _current;

  bool get isDialogOpen => _dialogOpen;
  bool get wasDismissed => _dismissed;
  bool get isFinalShown => _finalShown;
  bool get isBusy => _checking;

  static String locationKeyOf(AddressModel address) {
    final double lat = double.tryParse(address.latitude ?? '') ?? 0;
    final double lng = double.tryParse(address.longitude ?? '') ?? 0;
    return '${lat}_${lng}_${address.zoneId ?? ''}';
  }

  /// Naye location par config background me fetch karo
  Future<void> onAddressSaved(AddressModel address) async {
    final String key = locationKeyOf(address);
    if (key == _locationKey) return;
    resetForNewLocation();
    _locationKey = key;
    _fetchConfigInBackground();  // Non-blocking!
    refreshServicesTab();
  }

  void resetForNewLocation() {
    _initial = 5.0;      // Reset to defaults
    _max = 50.0;
    _step = 5.0;
    _maxAttempts = 5;
    _popupEnabled = true;
    _attempts = 0;
    _current = 0;
    _checking = false;
    _dialogOpen = false;
    _dismissed = false;
    _finalShown = false;
    _locationKey = null;
    _configFetched = false;
    SearchRadiusState.activeRadius = null;
    SearchRadiusState.initialRadius = null;
    SearchRadiusState.maxRadius = null;
    homeGate.value = 0;
  }

  /// Background fetch - NO AWAIT, NO BLOCKING
  void _fetchConfigInBackground() {
    if (_configFetched) return;
    _configFetched = true;
    
    // Fire and forget
    Future(() async {
      try {
        final Response response = await locationRepo.getSearchRadius().timeout(
          const Duration(milliseconds: 1500),  // Fast timeout
          onTimeout: () => Response(statusCode: 408),
        );
        
        if (response.statusCode == 200 &&
            response.body is Map &&
            response.body['response_code'] == 'default_200') {
          final dynamic content = response.body['content'];
          if (content is Map) {
            double initial = (content['initial_radius'] as num?)?.toDouble() ?? 5;
            double max = (content['max_radius'] as num?)?.toDouble() ?? 50;
            double step = (content['radius_increment_step'] as num?)?.toDouble() ?? 5;
            int attempts = (content['max_search_attempts'] as num?)?.toInt() ?? 5;
            bool popup = content['show_popup_on_location_change'] != false;
            if (initial > 0 && max >= initial) {
              _initial = initial;
              _max = max;
              if (step > 0) _step = step;
              if (attempts > 0) _maxAttempts = attempts;
              _popupEnabled = popup;
              SearchRadiusState.initialRadius = initial;
              SearchRadiusState.maxRadius = max;
            }
          }
        }
      } catch (_) {
        // Use defaults - already set
      }
    });
  }

  static void refreshServicesTab() {
    if (Get.isRegistered<CategoryController>()) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    if (Get.isRegistered<AllSearchController>()) {
      final AllSearchController searchController =
          Get.find<AllSearchController>();
      searchController.searchData(
        query: searchController.searchController.text.trim(),
        offset: 1,
        shouldUpdate: false,
        reload: true,
      );
    }
  }

  /// ⚡ INSTANT - No config fetch, uses defaults
  Future<void> checkAvailabilityAndPrompt() async {
    if (_checking || _dialogOpen || _dismissed || _finalShown) return;
    if (!Get.isRegistered<LocationController>()) return;

    final AddressModel? address = Get.find<LocationController>().getUserAddress();
    if (address == null) return;

    final double lat = double.tryParse(address.latitude ?? '') ?? 0;
    final double lng = double.tryParse(address.longitude ?? '') ?? 0;
    if (lat == 0 && lng == 0) return;

    final String key = locationKeyOf(address);
    if (key != _locationKey) {
      resetForNewLocation();
      _locationKey = key;
      _fetchConfigInBackground();
    }

    _checking = true;
    try {
      if (_current <= 0) {
        _current = initialRadius;
        SearchRadiusState.activeRadius = _current;
      }

      final bool? found = await _providersWithinCurrentRadius(address);

      if (found == null) {
        _checking = false;
        return;
      }

      if (_locationKey != key) {
        _checking = false;
        return;
      }

      if (found) {
        _dismissed = true;
        _openHomeGateIfZoneEmpty(address);
        _checking = false;
        return;
      }

      if (!_popupEnabled) {
        _dismissed = true;
        _checking = false;
        return;
      }

      if (_current >= maxRadius || _attempts >= _maxAttempts) {
        _finalShown = true;
        _showFinalDialog();
        _checking = false;
        return;
      }

      _checking = false;
      _showExpandPopup(address);
    } catch (e) {
      _checking = false;
      if (kDebugMode) print('RadiusSearch Error: $e');
    }
  }

  /// Expand popup dikhata hai — button tap pe async expand hota hai
  /// (loading sheet me dikhta hai), aur found=true pe permanently band.
  void _showExpandPopup(AddressModel address) {
    if (_dialogOpen || _dismissed || _finalShown) return;

    final double step = _step;
    final double current = _current;
    final double next =
        (current + step) > maxRadius ? maxRadius : (current + step);

    _dialogOpen = true;
    RadiusSearchBottomSheet.show(
      currentRadius: current,
      nextRadius: next,
      step: step,
      maxRadius: maxRadius,
      onExpand: () => _handleExpand(address, next),
      onSetManually: () {
        _dialogOpen = false;
        _dismissed = true;
        _navigateToLocationScreen();
      },
      onDismiss: () {
        _dialogOpen = false;
        _dismissed = true;
      },
    );
  }

  /// Expand tap hone par:
  /// 1. Sheet already band ho chuki hoti hai (button ne pop kar diya)
  /// 2. Loading overlay dikhao (user ko feedback mile)
  /// 3. Naye radius me provider check karo
  /// 4. Found → overlay hatao, reload background me, done (koi popup nahi)
  /// 5. Nahi mila (found=null, timeout, error) → overlay hatao, reload background me
  ///    — "next radius" tabahi na chahiye, kyunki check fail ho gaya tha.
  Future<void> _handleExpand(AddressModel address, double next) async {
    if (_checking) return;
    _checking = true;

    _attempts++;
    _current = next;
    SearchRadiusState.activeRadius = next;

    _showSearchingOverlay(next);

    try {
      final bool? found = await _providersWithinCurrentRadius(address);

      _hideSearchingOverlay();

      if (found == true) {
        _dismissed = true;
        _dialogOpen = false;
        _openHomeGateIfZoneEmpty(address);
        unawaited(_reloadAfterRadiusChange(address));
        _checking = false;
        return;
      }

      // found == null → check timeout/error gayab ho gaya, bas reload karo
      // ageya radius baadana ya next popup dikhna mat chahiye
      unawaited(_reloadAfterRadiusChange(address));
      _dialogOpen = false;
      _checking = false;
      return;
    } catch (_) {
      _hideSearchingOverlay();
      _dialogOpen = false;
      _checking = false;
    }
  }

  /// Chhota loading overlay — "Searching providers within X km..."
  void _showSearchingOverlay(double radius) {
    try {
      Get.dialog(
        PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              decoration: BoxDecoration(
                color: Get.context?.theme.cardColor ?? Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Searching within ${radius.toStringAsFixed(0)} km...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Get.context?.theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (_) {}
  }

  void _hideSearchingOverlay() {
    try {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (_) {}
  }

  /// Fast provider check - 1 API call (lat/lng + radius dono bhejte hain
  /// taaki backend radius filter sach me apply ho sake)
  Future<bool?> _providersWithinCurrentRadius(AddressModel address) async {
    try {
      final Response response = await locationRepo.apiClient.postData(
        AppConstants.getProviderList,
        {
          'limit': 1,
          'offset': 1,
          'lat': address.latitude,
          'lng': address.longitude,
          'radius': _current,
        },
      ).timeout(const Duration(seconds: 5));

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

  /// Home screen par services available nahi hain (ServiceNotAvailableScreen
  /// dikh rahi hai) — seedha expand popup dikhao, background me screen rahegi.
  Future<void> promptWhenServicesUnavailable() async {
    if (_checking || _dialogOpen || _dismissed || _finalShown) return;
    if (!Get.isRegistered<LocationController>()) return;

    final AddressModel? address = Get.find<LocationController>().getUserAddress();
    if (address == null) return;

    final double lat = double.tryParse(address.latitude ?? '') ?? 0;
    final double lng = double.tryParse(address.longitude ?? '') ?? 0;
    if (lat == 0 && lng == 0) return;

    final String key = locationKeyOf(address);
    if (key != _locationKey) {
      resetForNewLocation();
      _locationKey = key;
      _fetchConfigInBackground();
    }

    if (_current <= 0) {
      _current = initialRadius;
      SearchRadiusState.activeRadius = _current;
    }

    if (!_popupEnabled) {
      _dismissed = true;
      return;
    }

    if (_current >= maxRadius || _attempts >= _maxAttempts) {
      _finalShown = true;
      _showFinalDialog();
      return;
    }

    _showExpandPopup(address);
  }

  void _openHomeGateIfZoneEmpty(AddressModel address) {
    if ((address.availableServiceCountInZone ?? 0) > 0) return;
    address.availableServiceCountInZone = 1;
    if (Get.isRegistered<LocationController>()) {
      Get.find<LocationController>().saveUserAddress(address);
    }
    if (homeGate.value == 0) {
      homeGate.value = 1;
    }
  }

  Future<void> _reloadAfterRadiusChange(AddressModel address) async {
    await HomeScreen.loadData(
      true,
      availableServiceCount: address.availableServiceCountInZone ?? 0,
    );
    refreshServicesTab();
  }

  void _showFinalDialog() {
    _dialogOpen = true;
    RadiusSearchBottomSheet.showFinal(
      radius: maxRadius,
      maxRadius: maxRadius,
      onDismiss: () {
        _dialogOpen = false;
      },
      onChangeAddress: () {
        _dialogOpen = false;
        try {
          Get.bottomSheet(
            const AddressSelectionBottomSheet(),
            isScrollControlled: true,
            useRootNavigator: true,
            backgroundColor: Colors.transparent,
          );
        } catch (_) {}
      },
      onSetManually: () {
        _dialogOpen = false;
        _navigateToLocationScreen();
      },
    );
  }

  void _navigateToLocationScreen() {
    try {
      final AddressModel? address = Get.find<LocationController>().getUserAddress();
      Get.toNamed(
        RouteHelper.getPickMapRoute(
          RouteHelper.home,
          false,
          'false',
          null,
          address,
        ),
      );
    } catch (_) {}
  }
}
