import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/util/dimensions.dart';
import 'package:jdds/util/styles.dart';

/// Bottom Sheet Style Radius Search Dialog
/// Same design as location popup - slides up from bottom
class RadiusSearchBottomSheet extends StatefulWidget {
  final double? currentRadius;
  final double? nextRadius;
  final double? maxRadius;
  final double? step;
  final double? radius;
  final Future<void> Function()? onExpand;
  final VoidCallback? onDismiss;
  final VoidCallback? onChangeAddress;
  final VoidCallback? onSetManually;

  const RadiusSearchBottomSheet({
    super.key,
    this.currentRadius,
    this.nextRadius,
    this.maxRadius,
    this.step,
    this.radius,
    this.onExpand,
    this.onDismiss,
    this.onChangeAddress,
    this.onSetManually,
  });

  /// Radius badhane wala popup (max se pehle).
  /// onExpand async hai — sheet loading state me button spin kar sakta hai.
  static Future<void> show({
    required double currentRadius,
    required double nextRadius,
    required double step,
    required double maxRadius,
    required Future<void> Function() onExpand,
    required VoidCallback onSetManually,
    required VoidCallback onDismiss,
  }) {
    return _open(
      RadiusSearchBottomSheet(
        currentRadius: currentRadius,
        nextRadius: nextRadius,
        step: step,
        maxRadius: maxRadius,
        onExpand: onExpand,
        onSetManually: onSetManually,
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
    required VoidCallback onSetManually,
  }) {
    return _open(
      RadiusSearchBottomSheet(
        radius: radius,
        maxRadius: maxRadius,
        onDismiss: onDismiss,
        onChangeAddress: onChangeAddress,
        onSetManually: onSetManually,
      ),
    );
  }

  static Future<void> _open(Widget child) {
    final BuildContext? context = Get.context;
    if (context == null) return Future<void>.value();

    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (bottomContext) {
        return PopScope(
          canPop: false,
          child: child,
        );
      },
    );
  }

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
  State<RadiusSearchBottomSheet> createState() => _RadiusSearchBottomSheetState();
}

class _RadiusSearchBottomSheetState extends State<RadiusSearchBottomSheet> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: NestInk.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: _buildContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final Color primary = NestInk.primary;
    final double displayRadius = widget._isExpandMode
        ? (widget.currentRadius ?? 0)
        : (widget.radius ?? 0);
    final bool wholeDisplay =
        displayRadius.truncateToDouble() == displayRadius;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: NestInk.border,
            borderRadius: BorderRadius.circular(2),
          ),
          margin: const EdgeInsets.only(bottom: 20),
        ),

        // Icon medallion
        Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: 0.12),
          ),
          child: Icon(
            widget._isExpandMode
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
          RadiusSearchBottomSheet._fmt(
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

        if (widget._isExpandMode) ...[
          const SizedBox(height: 16),

          /// Radius progression chip: 5 km → 10 km
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _radiusChip(
                  '${RadiusSearchBottomSheet._km(widget.currentRadius ?? 0)} km',
                  primary),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: primary,
                ),
              ),
              _radiusChip(
                  '${RadiusSearchBottomSheet._km(widget.nextRadius ?? 0)} km',
                  primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            RadiusSearchBottomSheet._fmt(
                'max_radius'.tr,
                'radius',
                RadiusSearchBottomSheet._km(widget.maxRadius ?? 0)),
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: NestInk.mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 24),

        /// Primary action
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading
                ? null
                : () {
                    if (widget._isExpandMode) {
                      // Sheet turant band karo, expand background me chalega
                      Navigator.of(context).pop();
                      widget.onExpand?.call();
                    } else {
                      Navigator.of(context).pop();
                      widget.onChangeAddress?.call();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: NestInk.background,
              disabledBackgroundColor: primary.withValues(alpha: 0.7),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    (widget._isExpandMode
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
        const SizedBox(height: 12),

        /// Set Manually button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: _loading
                ? null
                : () {
                    Navigator.of(context).pop();
                    widget.onSetManually?.call();
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: NestInk.primary,
              side: BorderSide(color: NestInk.border, width: 1.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: NestInk.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Set Location Manually',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: NestInk.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        /// Cancel/Dismiss button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: _loading
                ? null
                : () {
                    Navigator.of(context).pop();
                    widget.onDismiss?.call();
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
