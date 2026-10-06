import 'package:get/get.dart';
import 'package:jdds/common/widgets/address_selection_bottom_sheet.dart';
import 'package:jdds/util/core_export.dart';

/// Progressive radius search flow - OPTIMIZED FOR SPEED.
/// Niyam:
///  1. Har location par pehle zone/initial radius (server default) se search.
///  2. Agar current radius me koi provider/serviceman NA mile → popup:
///     "Service not available at your location" + [Search with more radius].
///  3. Expand karne par radius `initial` (step) se badhta hai, max admin
///     setting (`max_search_radius`) tak — har expansion par dobara check.
///  4. Max tak kuch na mile → final "not available" popup.
///  5. Location change hote hi radius state reset + Home/Services refresh.
class RadiusSearchController extends GetxService {
  final LocationRepo locationRepo;
  RadiusSearchController({required this.locationRepo});

  /// Home ka service-gate (availableServiceCount) 0 tha aur radius search me
  /// provider mil gaya → home ko full content dikhane ke liye notify karta hai.
  static final ValueNotifier<int> homeGate = ValueNotifier<int>(0);

  double? _initial;
  double? _max;
  double _current = 0;
  bool _checking = false;
  bool _dialogOpen = false;
  bool _dismissed = false;
  bool _finalShown = false;
  String? _locationKey;

  double get initialRadius => _initial ?? 5;
  double get maxRadius => _max ?? 50;
  double get currentRadius => _current;

  /// Radius flow ka current state — Home inhe dekh kar decide karta hai ki
  /// location popup khud dikhana hai ya nahi (double dialog nahi chahiye).
  bool get isDialogOpen => _dialogOpen;
  bool get wasDismissed => _dismissed;
  bool get isFinalShown => _finalShown;
  bool get isBusy => _checking;

  static String locationKeyOf(AddressModel address) {
    final double lat = double.tryParse(address.latitude ?? '') ?? 0;
    final double lng = double.tryParse(address.longitude ?? '') ?? 0;
    return '${lat}_${lng}_${address.zoneId ?? ''}';
  }

  /// Naye address save hone par (LocationController.saveUserAddress se).
  /// Sirf tab reset + refresh jab actually location/zone badla ho.
  Future<void> onAddressSaved(AddressModel address) async {
    final String key = locationKeyOf(address);
    if (key == _locationKey) return;
    resetForNewLocation();
    _locationKey = key;
    refreshServicesTab();
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
    SearchRadiusState.activeRadius = null;
    SearchRadiusState.initialRadius = null;
    SearchRadiusState.maxRadius = null;
    homeGate.value = 0;
  }

  /// Services tab ki data (categories + service list) turant refresh.
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

  /// ✅ OPTIMIZED - NO DELAYS - Check immediately and show popup fast
  Future<void> checkAvailabilityAndPrompt() async {
    if (_checking || _dialogOpen || _dismissed || _finalShown) return;
    if (!Get.isRegistered<LocationController>()) return;

    final AddressModel? address =
        Get.find<LocationController>().getUserAddress();
    if (address == null) return;

    final double lat = double.tryParse(address.latitude ?? '') ?? 0;
    final double lng = double.tryParse(address.longitude ?? '') ?? 0;
    if (lat == 0 && lng == 0) return;

    final String key = locationKeyOf(address);
    if (key != _locationKey) {
      resetForNewLocation();
      _locationKey = key;
    }

    _checking = true;
    try {
      // Fetch config with timeout (don't block forever)
      if (!await _ensureConfig()) {
        // Use defaults if config fetch fails
        _initial = 5;
        _max = 50;
      }

      // Recheck location hasn't changed
      if (_locationKey != key) {
        _checking = false;
        return;
      }

      // Setup current radius
      if (_current <= 0) {
        _current = initialRadius;
        SearchRadiusState.activeRadius = _current;
      }

      // IMMEDIATELY check providers - NO DELAY
      final bool? found = await _providersWithinCurrentRadius();
      
      if (found == null) {
        // Check failed (offline) - abort
        _checking = false;
        return;
      }
      
      if (_locationKey != key) {
        // Location changed during check
        _checking = false;
        return;
      }

      if (found) {
        // Service found! Open gate and exit
        _openHomeGateIfZoneEmpty(address);
        _checking = false;
        return;
      }

      // Service NOT found - show progressive popup

      // Check guards again
      if (_dialogOpen || _dismissed || _finalShown) {
        _checking = false;
        return;
      }

      if (_current >= maxRadius) {
        // Max radius reached - show final dialog
        _finalShown = true;
        _showFinalDialog();
        _checking = false;
        return;
      }

      // Show expand dialog
      final double step = initialRadius;
      final double next = (_current + step) > maxRadius 
          ? maxRadius 
          : (_current + step);

      _dialogOpen = true;
      _checking = false;
      
      RadiusSearchDialog.show(
        currentRadius: _current,
        nextRadius: next,
        step: step,
        maxRadius: maxRadius,
        onExpand: () {
          _dialogOpen = false;
          _current = next;
          SearchRadiusState.activeRadius = next;
          unawaited(_reloadAfterRadiusChange(address));
          unawaited(checkAvailabilityAndPrompt());
        },
        onDismiss: () {
          _dialogOpen = false;
          _dismissed = true;
        },
      );
    } catch (e) {
      _checking = false;
      if (kDebugMode) print('RadiusSearch Error: $e');
    }
  }

  /// ✅ OPTIMIZED - Fetch config with timeout
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
        if (content is Map) {
          initial = (content['initial_radius'] as num?)?.toDouble() ?? 5;
          max = (content['max_radius'] as num?)?.toDouble() ?? 50;
        }
        if (initial <= 0) initial = 5;
        if (max < initial) max = initial;
        _initial = initial;
        _max = max;
        SearchRadiusState.initialRadius = initial;
        SearchRadiusState.maxRadius = max;
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// null = check fail (offline); true/false = asli result.
  /// ✅ FAST - minimal data transfer
  Future<bool?> _providersWithinCurrentRadius() async {
    try {
      final Response response = await locationRepo.apiClient.postData(
        AppConstants.getProviderList,
        {
          'limit': 1,
          'offset': 1,
          'radius': _current,
        },
      );
      if (response.statusCode != 200) return null;
      final dynamic body = response.body;
      if (body is! Map || body['response_code'] != 'default_200') {
        return null;
      }
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

  /// Zone me count 0 tha (ServiceNotAvailableScreen) par radius search me
  /// provider mil gaya → gate khol do taaki Home full content dikhaye.
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
    RadiusSearchDialog.showFinal(
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
    );
  }
}
