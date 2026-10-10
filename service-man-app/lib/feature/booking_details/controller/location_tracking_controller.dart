import 'dart:convert';
import 'dart:math' as math;

import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationTrackingController extends GetxController {
  final LatLng destination;
  final String destinationTitle;

  LocationTrackingController({
    required this.destination,
    required this.destinationTitle,
  });

  final MapController mapController = MapController();

  Position? currentPosition;
  bool isInitializing = true;
  bool isRouteLoading = false;
  bool followUser = false;
  bool isLocationUnavailable = false;
  bool isApproxRoute = false;

  List<LatLng> routePoints = <LatLng>[];
  double routeDistanceMeter = 0;
  double routeDurationSecond = 0;

  StreamSubscription<Position>? _positionSubscription;
  LatLng? _routeOrigin;
  DateTime? _lastRouteFetchAt;
  bool _permissionDeniedForever = false;
  bool _locationNoticeShown = false;

  static const String _osrmPrimaryUrl =
      'https://router.project-osrm.org/route/v1/driving';
  static const String _osrmBackupUrl =
      'https://routing.openstreetmap.de/routed-car/route/v1/driving';

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await _resolveCurrentPosition();
    _listenToPosition();
    await refreshRoute(fitCamera: true);
    isInitializing = false;
    update();
    _showLocationNoticeOnce();
  }

  Future<void> _resolveCurrentPosition() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLocationUnavailable = true;
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        _permissionDeniedForever = true;
        isLocationUnavailable = true;
        return;
      }
      if (permission == LocationPermission.denied) {
        isLocationUnavailable = true;
        return;
      }
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      isLocationUnavailable = currentPosition == null;
    } catch (_) {
      if (currentPosition == null) {
        isLocationUnavailable = true;
      }
    }
  }

  void _listenToPosition() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      ),
    ).listen(
      (Position position) {
        currentPosition = position;
        isLocationUnavailable = false;
        final LatLng me = LatLng(position.latitude, position.longitude);

        if (followUser) {
          _moveCamera(me, _currentZoomOr(16));
        }

        final LatLng? routeOrigin = _routeOrigin;
        final DateTime? lastFetchAt = _lastRouteFetchAt;
        if (routePoints.isEmpty) {
          refreshRoute(fitCamera: true);
        } else if (routeOrigin != null &&
            lastFetchAt != null &&
            DateTime.now().difference(lastFetchAt).inSeconds > 20 &&
            _haversineDistance(me, routeOrigin) > 300) {
          refreshRoute();
        }
        update();
      },
      onError: (Object error, StackTrace stackTrace) {
        // Position stream errors (e.g. permission revoked) are non-fatal here.
      },
    );
  }

  Future<void> refreshRoute({bool fitCamera = false}) async {
    if (isRouteLoading) return;

    final LatLng? origin = _currentLatLng();
    if (origin == null) {
      routePoints = <LatLng>[];
      routeDistanceMeter = 0;
      routeDurationSecond = 0;
      isApproxRoute = false;
      isRouteLoading = false;
      update();
      _moveCamera(destination, 15);
      return;
    }

    isRouteLoading = true;
    update();

    final double straightDistance = _haversineDistance(origin, destination);
    _RouteResult? result;

    // Very short gaps make the router return a degenerate zero-length route,
    // so only ask it when there is a real distance to cover.
    if (straightDistance >= 25) {
      result = await _fetchOsrmRoute(origin, destination, _osrmPrimaryUrl) ??
          await _fetchOsrmRoute(origin, destination, _osrmBackupUrl);
    }

    if (result != null) {
      routePoints = result.points;
      routeDistanceMeter = result.distanceMeter ?? straightDistance;
      routeDurationSecond = result.durationSecond ?? 0;
      isApproxRoute = false;
    } else {
      routePoints = <LatLng>[origin, destination];
      routeDistanceMeter = straightDistance;
      routeDurationSecond = 0;
      isApproxRoute = true;
    }

    _routeOrigin = origin;
    _lastRouteFetchAt = DateTime.now();
    isRouteLoading = false;
    update();

    if (fitCamera) {
      _fitRouteToPoints();
    }
  }

  Future<_RouteResult?> _fetchOsrmRoute(
    LatLng origin,
    LatLng destination,
    String baseUrl,
  ) async {
    try {
      final Uri uri = Uri.parse(
        '$baseUrl/${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson&alternatives=false&steps=false',
      );
      final http.Response response =
          await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;

      final dynamic body = jsonDecode(response.body);
      if (body is! Map<String, dynamic> ||
          body['code'] != 'Ok' ||
          body['routes'] is! List ||
          (body['routes'] as List).isEmpty) {
        return null;
      }
      final dynamic route = (body['routes'] as List).first;
      if (route is! Map) return null;

      final dynamic geometry = route['geometry'];
      if (geometry is! Map || geometry['coordinates'] is! List) return null;

      final List<LatLng> points = <LatLng>[];
      for (final dynamic coord in geometry['coordinates'] as List) {
        if (coord is List &&
            coord.length >= 2 &&
            coord[0] is num &&
            coord[1] is num) {
          points.add(
            LatLng((coord[1] as num).toDouble(), (coord[0] as num).toDouble()),
          );
        }
      }
      if (points.length < 2) return null;

      final double? distanceMeter = (route['distance'] as num?)?.toDouble();
      final double? durationSecond = (route['duration'] as num?)?.toDouble();

      // Reject a zero-length answer while the two points really are apart
      // (the router can snap both onto the same road node).
      if ((distanceMeter == null || distanceMeter <= 0) &&
          _haversineDistance(origin, destination) > 5) {
        return null;
      }

      return _RouteResult(
        points: points,
        distanceMeter: distanceMeter,
        durationSecond: durationSecond,
      );
    } catch (_) {
      return null;
    }
  }

  void recenter() {
    final LatLng? me = _currentLatLng();
    if (me == null) {
      showCustomSnackBar(
        'you_have_to_allow'.tr,
        type: ToasterMessageType.info,
      );
      _showLocationNoticeOnce();
      return;
    }
    followUser = true;
    update();
    _moveCamera(me, _currentZoomOr(16));
  }

  void disableFollow() {
    if (!followUser) return;
    followUser = false;
    update();
  }

  Future<void> openInGoogleMaps() async {
    final LatLng? origin = _currentLatLng();
    final String originParam = origin != null
        ? '&origin=${origin.latitude},${origin.longitude}'
        : '';
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1$originParam'
      '&destination=${destination.latitude},${destination.longitude}&mode=d',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {
      // Fall through to the error message below.
    }
    showCustomSnackBar(
      'failed_to_open_map'.tr,
      type: ToasterMessageType.info,
    );
  }

  LatLng? _currentLatLng() {
    final Position? position = currentPosition;
    return position == null
        ? null
        : LatLng(position.latitude, position.longitude);
  }

  double _currentZoomOr(double fallback) {
    try {
      return math.max(mapController.camera.zoom, fallback);
    } catch (_) {
      return fallback;
    }
  }

  void _moveCamera(LatLng center, double zoom) {
    _safeAction(() => mapController.move(center, zoom));
  }

  void _fitRouteToPoints() {
    _safeAction(() {
      if (routePoints.isEmpty) {
        mapController.move(destination, 15);
        return;
      }

      // Short routes would zoom the map into an unreadable maximum level,
      // so keep them at a sane fixed zoom instead.
      if (routeDistanceMeter < 400) {
        mapController.move(_midPointOf(routePoints), 17);
        return;
      }

      final LatLngBounds bounds = LatLngBounds.fromPoints(routePoints);
      final LatLng? me = _currentLatLng();
      if (me != null) {
        bounds.extend(me);
      }
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.fromLTRB(48, 48, 48, 230),
        ),
      );
      try {
        final camera = mapController.camera;
        if (camera.zoom > 17.5) {
          mapController.move(camera.center, 17.5);
        }
      } catch (_) {
        // Camera not ready - the fit above is enough.
      }
    });
  }

  static LatLng _midPointOf(List<LatLng> points) {
    double latitude = 0;
    double longitude = 0;
    for (final LatLng point in points) {
      latitude += point.latitude;
      longitude += point.longitude;
    }
    return LatLng(latitude / points.length, longitude / points.length);
  }

  void _safeAction(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        action();
      } catch (_) {
        // Map controller not ready yet - safe to ignore.
      }
    });
  }

  void _showLocationNoticeOnce() {
    if (!isLocationUnavailable || _locationNoticeShown) return;
    _locationNoticeShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_permissionDeniedForever) {
        Get.dialog(const PermissionDialog(), barrierDismissible: true);
      } else {
        showCustomSnackBar(
          'you_have_to_allow'.tr,
          type: ToasterMessageType.info,
        );
      }
    });
  }

  static double _haversineDistance(LatLng a, LatLng b) {
    const double radius = 6371000;
    final double dLat = _toRad(b.latitude - a.latitude);
    final double dLon = _toRad(b.longitude - a.longitude);
    final double lat1 = _toRad(a.latitude);
    final double lat2 = _toRad(b.latitude);
    final double h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * radius * math.asin(math.min(1, math.sqrt(h)));
  }

  static double _toRad(double degree) => degree * math.pi / 180;

  @override
  void onClose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    try {
      mapController.dispose();
    } catch (_) {
      // Controller may already be disposed by the map widget.
    }
    super.onClose();
  }
}

class _RouteResult {
  final List<LatLng> points;
  final double? distanceMeter;
  final double? durationSecond;

  const _RouteResult({
    required this.points,
    required this.distanceMeter,
    required this.durationSecond,
  });
}
