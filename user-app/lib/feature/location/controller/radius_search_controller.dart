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
            if (initial > 0 && max >= initial) {
              _initial = initial;
              _max = max;
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
      // Setup radius IMMEDIATELY using defaults
      if (_current <= 0) {
        _current = initialRadius;
        SearchRadiusState.activeRadius = _current;
      }

      // Check providers
      final bool? found = await _providersWithinCurrentRadius();
      
      if (found == null) {
        _checking = false;
        return;
      }
      
      if (_locationKey != key) {
        _checking = false;
        return;
      }

      if (found) {
        _openHomeGateIfZoneEmpty(address);
        _checking = false;
        return;
      }

      // NOT FOUND - SHOW POPUP IMMEDIATELY
      if (_dialogOpen || _dismissed || _finalShown) {
        _checking = false;
        return;
      }

      if (_current >= maxRadius) {
        _finalShown = true;
        _showFinalDialog();
        _checking = false;
        return;
      }

      // Calculate next radius
      final double step = initialRadius;
      final double next = (_current + step) > maxRadius ? maxRadius : (_current + step);

      _dialogOpen = true;
      _checking = false;
      
      // 🔥 POPUP SHOWS INSTANTLY - NO WAIT
      RadiusSearchBottomSheet.show(
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
    } catch (e) {
      _checking = false;
      if (kDebugMode) print('RadiusSearch Error: $e');
    }
  }

  /// Fast provider check - 1 API call
  Future<bool?> _providersWithinCurrentRadius() async {
    try {
      final Response response = await locationRepo.apiClient.postData(
        AppConstants.getProviderList,
        {
          'limit': 1,
          'offset': 1,
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
