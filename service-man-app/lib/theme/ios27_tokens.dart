import 'dart:ui';

import 'package:flutter/material.dart';

/// iOS 27 design tokens transcribed from the public ios27-design-system kit
/// (measured against Apple iOS 27 UI Kit 27.0.2). Visual chrome only.
class Ios27Tokens {
  Ios27Tokens._();

  /// Settings > Appearance > Liquid Glass. 0 = fully tinted, 1 = ultra clear.
  static const double transparency = 0.5;

  static double get opacityScale => 1.6 + (-1.1 * transparency);
  static double get blurScale => 0.5 + (0.8 * transparency);

  static const double radiusSm = 14;
  static const double radiusMd = 22;
  static const double radiusLg = 34;
  static const double radiusPill = 100;
  static const double controlHeight = 50;
  static const double minTap = 44;

  static const double blurRegular = 6;
  static const double blurSmall = 3.6;
  static const double blurClear = 1.6;
  static const double blurChrome = 50;
  static const double saturate = 1.8;

  /// Option B — Royal Blue brand palette
  static const Color accent = Color(0xFF2563EB);
  static const Color accentDark = Color(0xFF1D4ED8);
  static const Color accentDeep = Color(0xFF1E40AF);
  static const Color accentSoft = Color(0xFF3B82F6);
  static const Color accentTint = Color(0xFFDBEAFE);
  static const Color systemBlue = Color(0xFF2563EB);
  static const Color systemGreen = Color(0xFF22C55E);
  static const Color systemRed = Color(0xFFEF4444);
  static const Color systemOrange = Color(0xFFF59E0B);
  static const Color systemYellow = Color(0xFFFBBF24);
  static const Color systemTeal = Color(0xFF14B8A6);
  static const Color brandSecondary = Color(0xFF0EA5E9);

  static const Color lightCanvas = Color(0xFFF2F2F7);
  static const Color lightGrouped = Color(0xFFF2F2F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightLabel = Color(0xFF000000);
  static const Color lightSecondaryLabel = Color(0x993C3C43);
  static const Color lightTertiaryLabel = Color(0x4D3C3C43);
  static const Color lightFill = Color(0x14747480);
  static const Color lightSeparator = Color(0x4A3C3C43);

  static const Color darkCanvas = Color(0xFF000000);
  static const Color darkGrouped = Color(0xFF000000);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkLabel = Color(0xFFFFFFFF);
  static const Color darkSecondaryLabel = Color(0x99EBEBF5);
  static const Color darkTertiaryLabel = Color(0x4DEBEBF5);
  static const Color darkFill = Color(0x1F767680);
  static const Color darkSeparator = Color(0x99545458);

  static bool reduceTransparency(BuildContext context) {
    final features =
        MediaQuery.maybeOf(context)?.accessibleNavigation == true ||
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.highContrastOf(context);
    return features;
  }

  static double glassAlpha(BuildContext context, {double base = 0.7}) {
    if (reduceTransparency(context)) return 0.94;
    return (base * opacityScale).clamp(0.35, 0.94);
  }

  static double glassBlur(BuildContext context, {double base = blurRegular}) {
    if (reduceTransparency(context)) return 0;
    return base * blurScale;
  }

  static Color glassFill(BuildContext context, {bool prominent = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (prominent) {
      return Colors.white.withValues(alpha: 0.94);
    }
    if (isDark) {
      return const Color(
        0xFF1A1A1A,
      ).withValues(alpha: glassAlpha(context, base: 0.7));
    }
    return Colors.white.withValues(alpha: glassAlpha(context, base: 0.7));
  }

  static Color rim(BuildContext context, {bool small = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (small) {
      return Color(isDark ? 0xFFE6E6E6 : 0xFFEBEBEB);
    }
    return Color(isDark ? 0xFFA6A6A6 : 0xFFDBDBDB);
  }

  static Color edge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Colors.black.withValues(alpha: isDark ? 0.10 : 0.05);
  }

  static Color fieldFill(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkFill : lightFill;
  }

  static List<BoxShadow> glassShadow(
    BuildContext context, {
    bool small = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (small) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.04 : 0.02),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.25),
        blurRadius: 48,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> cardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return const [];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static BoxDecoration surface(
    BuildContext context, {
    double radius = radiusMd,
    bool glass = false,
  }) {
    return BoxDecoration(
      color: glass ? glassFill(context) : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: rim(context), width: 0.5),
      boxShadow: glass ? glassShadow(context) : cardShadow(context),
    );
  }

  static ImageFilter blurFilter(
    BuildContext context, {
    double base = blurRegular,
  }) {
    final sigma = glassBlur(context, base: base);
    return ImageFilter.blur(
      sigmaX: sigma,
      sigmaY: sigma,
      tileMode: TileMode.clamp,
    );
  }
}
