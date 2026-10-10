import 'package:jassdbx_serviceman/feature/booking_details/controller/location_tracking_controller.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class LocationTrackingScreen extends StatelessWidget {
  final double destinationLat;
  final double destinationLng;
  final String destinationTitle;

  const LocationTrackingScreen({
    super.key,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationTitle,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationTrackingController>(
      init: LocationTrackingController(
        destination: LatLng(destinationLat, destinationLng),
        destinationTitle: destinationTitle,
      ),
      builder: (controller) {
        return Scaffold(
          backgroundColor: context.kBackground,
          body: Column(
            children: [
              CustomAppBar(
                title: 'navigation'.tr,
                subtitle: destinationTitle,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildMap(context, controller)),
                    if (controller.isRouteLoading)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(minHeight: 3),
                      ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: _buildRecenterButton(context, controller),
                    ),
                  ],
                ),
              ),
              _buildInfoPanel(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMap(
    BuildContext context,
    LocationTrackingController controller,
  ) {
    final LatLng? me = controller.currentPosition != null
        ? LatLng(
            controller.currentPosition!.latitude,
            controller.currentPosition!.longitude,
          )
        : null;

    return FlutterMap(
      mapController: controller.mapController,
      options: MapOptions(
        initialCenter: me ?? LatLng(destinationLat, destinationLng),
        initialZoom: 15,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onPositionChanged: (position, hasGesture) {
          if (hasGesture && controller.followUser) {
            controller.disableFollow();
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.jassdbx.jassods.serviceman',
        ),
        if (controller.routePoints.length >= 2 &&
            controller.routeDistanceMeter >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: controller.routePoints,
                strokeWidth: controller.isApproxRoute ? 5 : 7,
                pattern: controller.isApproxRoute
                    ? StrokePattern.dashed(segments: [14, 12])
                    : const StrokePattern.solid(),
                color: const Color(0xFF1A73E8),
                borderStrokeWidth: controller.isApproxRoute ? 0 : 10,
                borderColor: Colors.white,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(destinationLat, destinationLng),
              width: 48,
              height: 48,
              alignment: Alignment.topCenter,
              child: const Icon(
                Icons.location_pin,
                size: 48,
                color: Color(0xFFEA4335),
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            if (me != null)
              Marker(
                point: me,
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A73E8),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A73E8).withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecenterButton(
    BuildContext context,
    LocationTrackingController controller,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.kCard,
        shape: BoxShape.circle,
        border: Border.all(color: context.kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: controller.recenter,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Icon(
              Icons.my_location_rounded,
              size: 22,
              color: controller.followUser
                  ? context.kPrimary
                  : context.kForeground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPanel(
    BuildContext context,
    LocationTrackingController controller,
  ) {
    Widget status;
    if (controller.routePoints.isNotEmpty) {
      status = Row(
        children: [
          Text(
            _formatDistance(controller.routeDistanceMeter),
            style: robotoBold.copyWith(
              fontSize: 20,
              color: context.kForeground,
            ),
          ),
          if (controller.routeDurationSecond > 0)
            Text(
              ' · ${_formatDuration(controller.routeDurationSecond)}',
              style: robotoMedium.copyWith(
                fontSize: 14,
                color: context.kMutedForeground,
              ),
            ),
          if (controller.isApproxRoute) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.kMuted,
                borderRadius: BorderRadius.circular(kRadiusSm),
              ),
              child: Text(
                'approximate_route'.tr,
                style: robotoMedium.copyWith(
                  fontSize: 11,
                  color: context.kMutedForeground,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (controller.isRouteLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      );
    } else if (controller.isInitializing || controller.isRouteLoading) {
      status = Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            'loading'.tr,
            style: robotoRegular.copyWith(
              fontSize: 13,
              color: context.kMutedForeground,
            ),
          ),
        ],
      );
    } else {
      status = Text(
        'you_have_to_allow'.tr,
        style: robotoRegular.copyWith(
          fontSize: 13,
          color: context.kMutedForeground,
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.kCard,
        border: Border(top: BorderSide(color: context.kBorder, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: context.kDestructive,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    destinationTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(
                      fontSize: 14,
                      color: context.kForeground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            status,
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: KButton(
                    label: 'update_route'.tr,
                    icon: Icons.refresh_rounded,
                    outline: true,
                    onTap: () => controller.refreshRoute(fitCamera: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KButton(
                    label: 'google_maps'.tr,
                    icon: Icons.map_outlined,
                    onTap: controller.openInGoogleMaps,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDistance(double meters) {
  if (meters >= 1000) {
    final double km = meters / 1000;
    return '${km.toStringAsFixed(km >= 100 ? 0 : 1)} km';
  }
  return '${meters.round()} m';
}

String _formatDuration(double seconds) {
  final int minutes = (seconds / 60).ceil();
  if (minutes < 1) return '1 min';
  if (minutes < 60) return '$minutes min';
  final int hours = minutes ~/ 60;
  final int rest = minutes % 60;
  return rest == 0 ? '$hours hr' : '$hours hr $rest min';
}
