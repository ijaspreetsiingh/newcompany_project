import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/util/core_export.dart';

/// Location change ke liye radius search popup.
/// Same design jo home screen pe hai par location change workflow ke liye.
class LocationChangeRadiusDialog extends StatelessWidget {
  final double? currentRadius;
  final double? nextRadius;
  final double? maxRadius;
  final double? step;
  final double? radius;
  final VoidCallback? onExpand;
  final VoidCallback? onDismiss;
  final VoidCallback? onChangeAddress;
  final bool isFinal;

  const LocationChangeRadiusDialog({
    super.key,
    this.currentRadius,
    this.nextRadius,
    this.maxRadius,
    this.step,
    this.radius,
    this.onExpand,
    this.onDismiss,
    this.onChangeAddress,
    this.isFinal = false,
  });

  /// Expand mode popup
  static Future<void> show({
    required double currentRadius,
    required double nextRadius,
    required double step,
    required double maxRadius,
    required VoidCallback onExpand,
    required VoidCallback onDismiss,
  }) {
    return _open(
      LocationChangeRadiusDialog(
        currentRadius: currentRadius,
        nextRadius: nextRadius,
        step: step,
        maxRadius: maxRadius,
        onExpand: onExpand,
        onDismiss: onDismiss,
        isFinal: false,
      ),
    );
  }

  /// Final popup - max radius tak service nahi mila
  static Future<void> showFinal({
    required double radius,
    required double maxRadius,
    required VoidCallback onDismiss,
    required VoidCallback onChangeAddress,
  }) {
    return _open(
      LocationChangeRadiusDialog(
        radius: radius,
        maxRadius: maxRadius,
        onDismiss: onDismiss,
        onChangeAddress: onChangeAddress,
        isFinal: true,
      ),
    );
  }

  static Future<void> _open(Widget child) {
    final BuildContext? context = Get.context;
    if (context == null) return Future<void>.value();
    return showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierLabel: 'dialog',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, _, _) => PopScope(
        canPop: false,
        child: child,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final Animation<double> curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static String _km(double value) {
    return value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: _buildCard(context),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final Color primary = NestInk.primary;
    final double displayRadius = isFinal ? (radius ?? 0) : (currentRadius ?? 0);
    final bool wholeDisplay =
        displayRadius.truncateToDouble() == displayRadius;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: ResponsiveHelper.isDesktop(context) ? 340 : 320,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: NestInk.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                height: 28,
                width: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: Icon(Icons.close_rounded, color: NestInk.mutedText),
                  onPressed: () {
                    Get.back();
                    onDismiss?.call();
                  },
                ),
              ),
            ),
            const SizedBox(height: 2),

            // Icon
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.12),
              ),
              child: Icon(
                isFinal
                    ? Icons.location_off_rounded
                    : Icons.location_searching_rounded,
                size: 34,
                color: primary,
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              isFinal
                  ? 'service_not_available'.tr
                  : 'search_with_more_radius'.tr,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                fontSize: 18,
                color: NestInk.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle/Description
            if (isFinal)
              Text(
                'no_provider_in_area'.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                  fontSize: 14,
                  color: NestInk.mutedText,
                  height: 1.5,
                ),
              )
            else
              Column(
                children: [
                  Text(
                    'no_service_current_radius'.tr,
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                      fontSize: 14,
                      color: NestInk.mutedText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: robotoRegular.copyWith(
                        fontSize: 14,
                        color: NestInk.mutedText,
                      ),
                      children: [
                        TextSpan(text: 'current_radius'.tr + ': '),
                        TextSpan(
                          text: '${_km(currentRadius ?? 0)} km',
                          style: robotoBold.copyWith(
                            fontSize: 14,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Radius info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.explore_rounded, color: primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFinal ? 'max_radius_reached'.tr : 'expand_search'.tr,
                          style: robotoSmall.copyWith(
                            fontSize: 12,
                            color: NestInk.mutedText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (!isFinal)
                          RichText(
                            text: TextSpan(
                              style: robotoBold.copyWith(
                                fontSize: 16,
                                color: NestInk.primary,
                              ),
                              children: [
                                TextSpan(text: _km(nextRadius ?? 0)),
                                TextSpan(
                                  text: ' km',
                                  style: robotoRegular.copyWith(
                                    fontSize: 12,
                                    color: NestInk.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            '${_km(radius ?? 0)} km',
                            style: robotoBold.copyWith(
                              fontSize: 16,
                              color: primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            if (isFinal)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        onChangeAddress?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.location_on_rounded, size: 20),
                      label: Text(
                        'change_address'.tr,
                        style: robotoBold.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        onDismiss?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: BorderSide(color: primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'close'.tr,
                        style: robotoBold.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    onExpand?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.expand_rounded, size: 20),
                  label: Text(
                    'search_nearby'.tr,
                    style: robotoBold.copyWith(fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
