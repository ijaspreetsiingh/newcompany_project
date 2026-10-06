import 'dart:convert';

import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

/// Booking for someone else (relative/friend) ka pura state.
///  1. Pehle friend ki location validate karta hai (zone + cart services +
///     provider available ya nahi) — nahi mile to wahi "service not available"
///     popup (RadiusSearchDialog) dikhta hai.
///  2. Available ho to friend address save + local history (SharedPreferences)
///     taaki dobara dalna na pade.
///  3. Agar friend dusre zone me hai to cart ka provider friend ke zone ke
///     nearest provider se sync karta hai — backend usi provider ke price se
///     cart ko re-price karta hai (server authoritative).
enum FriendZoneStatus { available, notAvailable, failed }

class FriendZoneCheckResult {
  final FriendZoneStatus status;
  final String zoneId;
  final int availableServiceCount;
  final ProviderData? nearestProvider;

  const FriendZoneCheckResult({
    required this.status,
    this.zoneId = '',
    this.availableServiceCount = 0,
    this.nearestProvider,
  });

  bool get isAvailable => status == FriendZoneStatus.available;
}

class FriendLocationController extends GetxController {
  FriendLocationController({
    required this.sharedPreferences,
    required this.locationRepo,
    required this.cartRepo,
  });

  final SharedPreferences sharedPreferences;
  final LocationRepo locationRepo;
  final CartRepo cartRepo;

  static const String _historyKey = 'demand_friend_location_history';
  static const int _maxHistory = 10;

  AddressModel? _selectedFriendAddress;
  List<AddressModel> _history = [];
  bool _providerSynced = false;
  String? _originalProviderId;
  FriendZoneCheckResult? _lastCheck;
  String? _lastCheckedLocationKey;
  bool _busy = false;

  AddressModel? get selectedFriendAddress => _selectedFriendAddress;
  List<AddressModel> get history => List.unmodifiable(_history);
  bool get isBookingForOther => _selectedFriendAddress != null;
  bool get providerSynced => _providerSynced;
  bool get isBusy => _busy;
  FriendZoneCheckResult? get lastCheck => _lastCheck;

  static String _keyOf(AddressModel address) =>
      '${address.latitude}_${address.longitude}';

  bool isSameAsSelected(AddressModel address) =>
      _selectedFriendAddress != null &&
      _keyOf(_selectedFriendAddress!) == _keyOf(address);

  // ---------------------------------------------------------------- history

  void loadHistory() {
    try {
      final String? raw = sharedPreferences.getString(_historyKey);
      if (raw != null && raw.isNotEmpty) {
        final dynamic decoded = jsonDecode(raw);
        if (decoded is List) {
          _history = decoded
              .map((dynamic e) =>
                  AddressModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      }
    } catch (_) {
      _history = [];
    }
    update();
  }

  Future<void> _persistHistory() async {
    try {
      await sharedPreferences.setString(
        _historyKey,
        jsonEncode(_history.map((AddressModel e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  void _addToHistory(AddressModel address) {
    _history.removeWhere((AddressModel e) => _keyOf(e) == _keyOf(address));
    _history.insert(0, address);
    if (_history.length > _maxHistory) {
      _history = _history.sublist(0, _maxHistory);
    }
    _persistHistory();
  }

  // ------------------------------------------------------------ zone checks

  bool _isServiceAvailableInZone(Service? service, String zoneId) {
    if (service == null) return true;
    final List<Variations>? variations = service.variations;
    // Service ke paas zone data hi nahi hai → zone availability count par
    // rely karte hain (validateCartAt already count 0 reject kar chuka hai).
    if (variations == null || variations.isEmpty) return true;
    return variations.any((Variations v) => v.zoneId == zoneId);
  }

  Future<List<ProviderData>> _providersNear(
    String subCategoryId,
    double lat,
    double lng,
  ) async {
    try {
      final Response response = await cartRepo.getProviderBasedOnSubcategory(
        subCategoryId,
        latitude: lat,
        longitude: lng,
      );
      if (response.statusCode != 200) return [];
      final dynamic content =
          response.body is Map ? response.body['content'] : null;
      if (content is! List) return [];
      final List<ProviderData> providers = [];
      for (final dynamic element in content) {
        try {
          providers.add(ProviderData.fromJson(element));
        } catch (_) {}
      }
      providers.removeWhere(
        (ProviderData p) =>
            (p.isActive ?? 1) == 0 || (p.serviceAvailability ?? 1) == 0,
      );
      providers.sort((ProviderData a, ProviderData b) {
        final double? da = a.distance;
        final double? db = b.distance;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
      return providers;
    } catch (_) {
      return [];
    }
  }

  /// Friend ki location par cart ki services available hain ya nahi.
  /// - Zone mila + zone me service count > 0
  /// - Har cart service us zone me listed ho
  /// - Zone ke andar cart sub-category ka provider available ho
  Future<FriendZoneCheckResult> validateCartAt(AddressModel friend) async {
    if (_busy) {
      return _lastCheck ??
          const FriendZoneCheckResult(status: FriendZoneStatus.failed);
    }
    _busy = true;
    update();
    try {
      final double lat = double.tryParse(friend.latitude ?? '') ?? 0;
      final double lng = double.tryParse(friend.longitude ?? '') ?? 0;
      if (lat == 0 && lng == 0) {
        return _lastCheck = const FriendZoneCheckResult(
          status: FriendZoneStatus.notAvailable,
        );
      }

      String zoneId = '';
      int serviceCount = 0;
      try {
        final Response response =
            await locationRepo.getZone(lat.toString(), lng.toString());
        final dynamic body = response.body;
        final dynamic content = body is Map ? body['content'] : null;
        final dynamic zone = content is Map ? content['zone'] : null;
        zoneId = zone is Map ? zone['id']?.toString() ?? '' : '';
        serviceCount = content is Map
            ? int.tryParse(
                    content['available_services_count']?.toString() ?? '',
                  ) ??
                  0
            : 0;
        if (response.statusCode != 200 || zoneId.isEmpty) {
          zoneId = '';
          serviceCount = 0;
        }
      } catch (_) {
        return _lastCheck = const FriendZoneCheckResult(
          status: FriendZoneStatus.failed,
        );
      }

      if (zoneId.isEmpty || serviceCount <= 0) {
        _lastCheckedLocationKey = '${lat}_$lng';
        return _lastCheck = const FriendZoneCheckResult(
          status: FriendZoneStatus.notAvailable,
        );
      }

      final CartController cartController = Get.find<CartController>();
      final List<CartModel> carts = cartController.cartList;

      for (final CartModel cart in carts) {
        if (!_isServiceAvailableInZone(cart.service, zoneId)) {
          _lastCheckedLocationKey = '${lat}_$lng';
          return _lastCheck = FriendZoneCheckResult(
            status: FriendZoneStatus.notAvailable,
            zoneId: zoneId,
            availableServiceCount: serviceCount,
          );
        }
      }

      ProviderData? nearest;
      if (carts.isNotEmpty) {
        final List<ProviderData> providers = await _providersNear(
          carts.first.subCategoryId,
          lat,
          lng,
        );
        if (providers.isEmpty) {
          _lastCheckedLocationKey = '${lat}_$lng';
          return _lastCheck = FriendZoneCheckResult(
            status: FriendZoneStatus.notAvailable,
            zoneId: zoneId,
            availableServiceCount: serviceCount,
          );
        }
        nearest = providers.first;
      }

      _lastCheckedLocationKey = '${lat}_$lng';
      return _lastCheck = FriendZoneCheckResult(
        status: FriendZoneStatus.available,
        zoneId: zoneId,
        availableServiceCount: serviceCount,
        nearestProvider: nearest,
      );
    } finally {
      _busy = false;
      update();
    }
  }

  /// Location same hai jo validate hui thi to dobara API call nahi.
  FriendZoneCheckResult? cachedCheckFor(AddressModel friend) {
    final String key =
        '${double.tryParse(friend.latitude ?? '') ?? 0}_${double.tryParse(friend.longitude ?? '') ?? 0}';
    if (_lastCheckedLocationKey == key && _lastCheck != null) {
      return _lastCheck;
    }
    return null;
  }

  // ------------------------------------------------------------- selection

  Future<FriendZoneCheckResult> selectFriendLocation(
    AddressModel friend, {
    FriendZoneCheckResult? preCheck,
  }) async {
    final FriendZoneCheckResult check =
        preCheck ?? await validateCartAt(friend);
    if (!check.isAvailable) {
      _lastCheck = check;
      update();
      return check;
    }

    friend.zoneId = check.zoneId.isNotEmpty ? check.zoneId : friend.zoneId;
    friend.addressLabel = AddressLabel.others.name;
    friend.addressType = AddressLabel.others.name;

    _addToHistory(friend);
    _selectedFriendAddress = friend;
    update();

    await _syncProviderForFriend(friend, check);
    update();
    return check;
  }

  Future<FriendZoneCheckResult> selectFromHistory(AddressModel address) {
    return selectFriendLocation(address);
  }

  /// Dusre zone me booking → cart ka provider friend ke zone ke nearest
  /// provider par le jao. Backend provider change par cart ko us provider /
  /// zone ke hisaab se re-price karta hai (basket/modify/partner).
  Future<void> _syncProviderForFriend(
    AddressModel friend,
    FriendZoneCheckResult check,
  ) async {
    final CartController cartController = Get.find<CartController>();
    if (cartController.cartList.isEmpty) {
      _providerSynced = false;
      return;
    }

    final String userZone =
        Get.find<LocationController>().getUserAddress()?.zoneId ?? '';
    final bool differentZone = (friend.zoneId?.isNotEmpty ?? false) &&
        friend.zoneId != 'null' &&
        friend.zoneId != userZone;

    if (!differentZone) {
      // Same zone = best case: existing provider wahi ka wahi hai.
      _providerSynced = true;
      return;
    }

    final ProviderData? nearest = check.nearestProvider;
    if (nearest?.id == null) {
      _providerSynced = false;
      return;
    }

    if (cartController.selectedProvider?.id == nearest!.id) {
      _providerSynced = true;
      return;
    }

    _originalProviderId ??= cartController.selectedProvider?.id;

    try {
      final Response response = await cartRepo.updateProvider(nearest.id!);
      if (response.statusCode == 200) {
        await cartController.getCartListFromServer();
        _providerSynced = true;
        return;
      }
    } catch (_) {}
    _providerSynced = false;
  }

  /// House details popup ke baad history entry bhi update (persist) kar do.
  void updateHistoryEntry(AddressModel address) {
    final bool exists = _history.any(
      (AddressModel e) => _keyOf(e) == _keyOf(address),
    );
    if (!exists) return;
    _addToHistory(address);
    update();
  }

  Future<void> clearFriendSelection() async {
    if (_selectedFriendAddress == null) return;
    _selectedFriendAddress = null;
    _lastCheck = null;
    _lastCheckedLocationKey = null;
    final String? originalProvider = _originalProviderId;
    _originalProviderId = null;
    _providerSynced = false;
    update();

    if (originalProvider != null && originalProvider.isNotEmpty) {
      try {
        await cartRepo.updateProvider(originalProvider);
        await Get.find<CartController>().getCartListFromServer();
      } catch (_) {}
    }
    update();
  }

  // ----------------------------------------------------------------- price

  /// Cart item ka price friend ke zone me (server ke zone-wise variations se).
  double _zonePriceOf(CartModel cart) {
    final AddressModel? friend = _selectedFriendAddress;
    final String zoneId = friend?.zoneId ?? '';
    final Service? service = cart.service;
    if (zoneId.isEmpty || zoneId == 'null' || service == null) {
      return cart.serviceCost.toDouble();
    }

    final List<Variations>? variations = service.variations;
    if (variations != null) {
      for (final Variations v in variations) {
        if (v.zoneId == zoneId &&
            v.variantKey == cart.variantKey &&
            v.price != null) {
          return v.price!.toDouble();
        }
      }
      // Variant key match na ho to sirf zone wali pehli variation.
      for (final Variations v in variations) {
        if (v.zoneId == zoneId && v.price != null) {
          return v.price!.toDouble();
        }
      }
    }

    final VariationsAppFormat? appFormat = service.variationsAppFormat;
    if (appFormat != null && appFormat.zoneId == zoneId) {
      final List<ZoneWiseVariations>? list = appFormat.zoneWiseVariations;
      if (list != null) {
        for (final ZoneWiseVariations v in list) {
          if (v.variantKey == cart.variantKey && v.price != null) {
            return v.price!.toDouble();
          }
        }
      }
    }

    return cart.serviceCost.toDouble();
  }

  double? zoneSubtotalFor({
    required List<CartModel> cartList,
    required int daysCount,
  }) {
    if (!isBookingForOther || cartList.isEmpty) return null;
    double subtotal = 0;
    for (final CartModel cart in cartList) {
      subtotal += _zonePriceOf(cart) * cart.quantity * daysCount;
    }
    return subtotal;
  }

  /// Server total + (friend zone subtotal - current zone subtotal).
  /// Tab tak use hota hai jab tak provider switch se server re-price na ho jaye.
  double? estimateTotalFor({
    required List<CartModel> cartList,
    required double serverTotal,
    required int daysCount,
  }) {
    if (!isBookingForOther || cartList.isEmpty) return null;
    final double? zoneSubtotal =
        zoneSubtotalFor(cartList: cartList, daysCount: daysCount);
    if (zoneSubtotal == null) return null;
    final double baseSubtotal = CheckoutHelper.calculateSubTotal(
      cartList: cartList,
      daysCount: daysCount,
    );
    final double estimate = serverTotal + (zoneSubtotal - baseSubtotal);
    return estimate < 0 ? 0 : estimate;
  }

  /// Address & Schedule + Payment dono screens yahi dikhayenge.
  double displayTotal({
    required List<CartModel> cartList,
    required double serverTotal,
    required int daysCount,
  }) {
    if (!isBookingForOther) return serverTotal;
    if (_providerSynced) return serverTotal;
    return estimateTotalFor(
          cartList: cartList,
          serverTotal: serverTotal,
          daysCount: daysCount,
        ) ??
        serverTotal;
  }

  bool get showZoneEstimate => isBookingForOther && !_providerSynced;
}
