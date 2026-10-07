import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/helper/responsive_helper.dart';
import 'package:jdds/util/dimensions.dart';
import 'package:jdds/util/styles.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';

/// Progressive radius search ke dono popups ka common UI:
///  - expand mode: current radius me koi provider nahi → "Search with more radius"
///  - final mode: max radius tak kuch nahi mila → "not available" + Change Address
///
/// Frosted-blur backdrop + nest. card style (EnableLocationPopup jaisa).
/// System back disabled hai — sirf button callbacks dialog band karte hain,
/// taaki `_dialogOpen` flag hamesha consistent rahe.
class RadiusSearchDialog extends StatelessWidget {
  final double? currentRadius;
  final double? nextRadius;
  final double? maxRadius;
  final double? step;
  final double? radius;
  final VoidCallback? onExpand;
  final VoidCallback? onDismiss;
  final VoidCallback? onChangeAddress;

  const RadiusSearchDialog({
    super.key,
    this.currentRadius,
    this.nextRadius,
    this.maxRadius,
    this.step,
    this.radius,
    this.onExpand,
    this.onDismiss,
    this.onChangeAddress,
  });

  /// Radius badhane wala popup (max se pehle).
  static Future<void> show({
    required double currentRadius,
    required double nextRadius,
    required double step,
    required double maxRadius,
    required VoidCallback onExpand,
    required VoidCallback onDismiss,
  }) {
    return _open(
      RadiusSearchDialog(
        currentRadius: currentRadius,
        nextRadius: nextRadius,
        step: step,
        maxRadius: maxRadius,
        onExpand: onExpand,
        onDismiss: onDismiss,
      ),
    );
  }

  /// Aakhri popup — max radius tak provider nahi mila.
  static Future<void> showFinal({
    required double radius,
    required double maxRadius,
    required VoidCallback onDismiss,
    required VoidCallback onChangeAddress,
  }) {
    return _open(
      RadiusSearchDialog(
        radius: radius,
        maxRadius: maxRadius,
        onDismiss: onDismiss,
        onChangeAddress: onChangeAddress,
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

  /// GetX trParams `{ key }` (spaces) expect karta hai — hamare lang files me
  /// `{radius}` hai, isliye dono form manually replace ho jaate hain.
  static String _fmt(String template, String key, String value) {
    return template.replaceAll('{$key}', value).replaceAll('{ $key }', value);
  }

  static String _km(double value) {
    return value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  bool get _isExpandMode => onExpand != null;

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
    final double displayRadius =
        _isExpandMode ? (currentRadius ?? 0) : (radius ?? 0);
    final bool wholeDisplay =
        displayRadius.truncateToDouble() == displayRadius;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: ResponsiveHelper.isDesktop(context)
            ? Dimensions.webMaxWidth / 2.5
            : 340,
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

            /// Icon medallion
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.12),
              ),
              child: Icon(
                _isExpandMode
                    ? Icons.location_searching_rounded
                    : Icons.location_off_rounded,
                size: 34,
                color: primary,
              ),
            ),
            const SizedBox(height: 18),

            Text(
              'service_not_available_at_your_location'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
                color: NestInk.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            Text(
              _fmt(
                'no_provider_within'.tr,
                'radius',
                displayRadius.toStringAsFixed(wholeDisplay ? 0 : 2),
              ),
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                height: 1.5,
                color: NestInk.mutedText,
              ),
              textAlign: TextAlign.center,
            ),

            if (_isExpandMode) ...[
              const SizedBox(height: 16),

              /// Radius progression chip: 5 km → 10 km
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _radiusChip('${_km(currentRadius ?? 0)} km', primary),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: primary,
                    ),
                  ),
                  _radiusChip('${_km(nextRadius ?? 0)} km', primary),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _fmt('max_radius'.tr, 'radius', _km(maxRadius ?? 0)),
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: NestInk.mutedText,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 20),

            /// Primary action
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  (_isExpandMode ? onExpand : onChangeAddress)?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: NestInk.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  (_isExpandMode
                          ? 'search_with_more_radius'
                          : 'change_address')
                      .tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: NestInk.background,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            /// Secondary action
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  Get.back();
                  onDismiss?.call();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: NestInk.mutedText,
                  side: BorderSide(color: NestInk.border, width: 1.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'cancel'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: NestInk.mutedText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radiusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: color,
        ),
      ),
    );
  }
}
