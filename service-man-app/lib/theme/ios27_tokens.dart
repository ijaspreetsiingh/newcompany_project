import 'dart:ui';

import 'package:flutter/material.dart';

/// Design tokens transcribed from the `design_refrence` prototype
/// (KaamPro monochrome token system — green reserved for live status).
/// Visual chrome only. Class keeps its historic `Ios27Tokens` name so the
/// whole app picks up the new palette without renaming call sites.
class Ios27Tokens {
  Ios27Tokens._();

  /// Settings > Appearance > Liquid Glass. 0 = fully tinted, 1 = ultra clear.
  static const double transparency = 0.5;

  static double get opacityScale => 1.6 + (-1.1 * transparency);
  static double get blurScale => 0.5 + (0.8 * transparency);

  /// Reference radii: --radius 0.75rem → rounded-md = 10px, rounded-lg = 12px.
  static const double radiusSm = 10;
  static const double radiusMd = 10;
  static const double radiusLg = 12;
  static const double radiusPill = 100;
  static const double controlHeight = 48;
  static const double minTap = 44;

  static const double blurRegular = 6;
  static const double blurSmall = 3.6;
  static const double blurClear = 1.6;
  static const double blurChrome = 50;
  static const double saturate = 1.8;

  /// Monochrome brand palette — primary is near-black in light mode and
  /// near-white in dark mode (see [accentDark]).
  static const Color accent = Color(0xFF070707);
  static const Color accentDark = Color(0xFFE2E8F0);
  static const Color accentDeep = Color(0xFF0F172B);
  static const Color accentSoft = Color(0xFF5B5B5B);
  static const Color accentTint = Color(0xFFEBEBEB);
  static const Color systemBlue = Color(0xFF070707);
  static const Color systemGreen = Color(0xFF008849);
  static const Color systemRed = Color(0xFFE7000B);
  static const Color systemOrange = Color(0xFFF59E0B);
  static const Color systemYellow = Color(0xFFFBBF24);
  static const Color systemTeal = Color(0xFF14B8A6);
  static const Color brandSecondary = Color(0xFFE6E6E6);

  /// Reference success tokens.
  static const Color success = Color(0xFF008849);
  static const Color successSoft = Color(0xFFD8F4DF);
  static const Color destructive = Color(0xFFE7000B);

  static const Color lightCanvas = Color(0xFFF7F7F7);
  static const Color lightGrouped = Color(0xFFF7F7F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightLabel = Color(0xFF070707);
  static const Color lightSecondaryLabel = Color(0xFF5B5B5B);
  static const Color lightTertiaryLabel = Color(0xFF8A8A8A);
  static const Color lightFill = Color(0xFFFFFFFF);
  static const Color lightSeparator = Color(0xB3CACACA);

  static const Color darkCanvas = Color(0xFF020618);
  static const Color darkGrouped = Color(0xFF020618);
  static const Color darkCard = Color(0xFF0F172B);
  static const Color darkLabel = Color(0xFFF8FAFC);
  static const Color darkSecondaryLabel = Color(0xFF90A1B9);
  static const Color darkTertiaryLabel = Color(0xFF90A1B9);
  static const Color darkFill = Color(0xFF0F172B);
  static const Color darkSeparator = Color(0x1AFFFFFF);

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
      return isDark ? darkCard : Colors.white;
    }
    if (isDark) {
      return darkCard;
    }
    return Colors.white;
  }

  static Color rim(BuildContext context, {bool small = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (small) {
      return isDark ? const Color(0x1AFFFFFF) : const Color(0xB3CACACA);
    }
    return isDark ? const Color(0x1AFFFFFF) : const Color(0xB3CACACA);
  }

  static Color edge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Colors.black.withValues(alpha: isDark ? 0.10 : 0.05);
  }

  static Color fieldFill(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkCard : lightCard;
  }

  static List<BoxShadow> glassShadow(
    BuildContext context, {
    bool small = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (small || isDark) {
      return const [];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> cardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return const [];
    return [
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
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: rim(context), width: 1),
      boxShadow: glass ? glassShadow(context, small: true) : cardShadow(context),
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
