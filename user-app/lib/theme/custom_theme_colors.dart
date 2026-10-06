import 'package:flutter/material.dart';

class CustomThemeColors extends ThemeExtension<CustomThemeColors> {
  final Map<String, Color> buttonBackgroundColorMap;
  final Map<String, Color> buttonTextColorMap;
  final Color error;
  final Color success;
  final Color info;
  final Color warning;
  final Color cardColor;
  final Color searchBarBorder;

  const CustomThemeColors({
    required this.buttonBackgroundColorMap,
    required this.buttonTextColorMap,
    required this.error,
    required this.success,
    required this.info,
    required this.warning,
    required this.cardColor,
    required this.searchBarBorder,
  });

  // Predefined themes for light and dark modes
  // Black & white "nest." palette - status colors are neutral greys,
  // differentiated by tone (light/dark) instead of hue.
  factory CustomThemeColors.light() => const CustomThemeColors(
    buttonBackgroundColorMap: {
      'pending': Color(0x14FFFFFF),
      'accepted': Color(0x1FFFFFFF),
      'ongoing': Color(0x2EFFFFFF),
      'completed': Color(0x14000000),
      'settled': Color(0x1F000000),
      'canceled': Color(0x0D000000),
      'approved': Color(0x1F000000),
      'exptred' : Color(0x0F000000),
      'running' : Color(0x26FFFFFF),
      'denied':  Color(0x1A000000),
      'paused': Color(0x1FFFFFFF),
      'resumed' : Color(0x1F000000),
      'resume' : Color(0x1F000000),
      'subscription_purchase' : Color(0x14000000),
      'subscription_renew' : Color(0x1F000000),
      'subscription_shift' : Color(0x26FFFFFF),
      'subscription_refund' : Color(0x0D000000),
    },
    buttonTextColorMap: {
      'pending': Color(0xFF333333),
      'accepted': Color(0xFF141414),
      'ongoing': Color(0xFF141414),
      'completed': Color(0xFF000000),
      'settled': Color(0xFF333333),
      'canceled': Color(0xFF7D7D7D),
      'approved': Color(0xFF000000),
      'exptred' : Color(0xFF7D7D7D),
      'running' : Color(0xFF141414),
      'denied':  Color(0xFF4D4D4D),
      'paused': Color(0xFF141414),
      'resumed' : Color(0xFF000000),
      'resume' : Color(0xFF000000),
      'subscription_purchase' : Color(0xFF000000),
      'subscription_renew' : Color(0xFF000000),
      'subscription_shift' : Color(0xFF141414),
      'subscription_refund' : Color(0xFF4D4D4D),
    },
    error: Color(0xFFD64545),
    success: Color(0xFF141414),
    info: Color(0xFF4D4D4D),
    warning: Color(0xFF7D7D7D),
    cardColor: Color(0xFFF6F6F6),
    searchBarBorder: Color(0xFFE5E5E5),
  );

  factory CustomThemeColors.dark() => const CustomThemeColors(
    buttonBackgroundColorMap: {
      'pending': Color(0x1FFFFFFF),
      'accepted': Color(0x29FFFFFF),
      'ongoing': Color(0x33FFFFFF),
      'completed': Color(0x1FFFFFFF),
      'settled': Color(0x14FFFFFF),
      'canceled': Color(0x0FFFFFFF),
      'approved': Color(0x1FFFFFFF),
      'exptred' : Color(0x0FFFFFFF),
      'running' : Color(0x29FFFFFF),
      'denied':  Color(0x1FFFFFFF),
      'paused': Color(0x1FFFFFFF),
      'resumed' : Color(0x1FFFFFFF),
      'resume' : Color(0x1FFFFFFF),
      'subscription_purchase' : Color(0x1FFFFFFF),
      'subscription_renew' : Color(0x1FFFFFFF),
      'subscription_shift' : Color(0x29FFFFFF),
      'subscription_refund' : Color(0x14FFFFFF),
    },
    buttonTextColorMap: {
      'pending': Color(0xFFD4D4D4),
      'accepted': Color(0xFFF1F1F1),
      'ongoing': Color(0xFFF1F1F1),
      'completed': Color(0xFFFFFFFF),
      'settled': Color(0xFFD4D4D4),
      'canceled': Color(0xFF8C8C8C),
      'approved': Color(0xFFFFFFFF),
      'exptred' : Color(0xFF8C8C8C),
      'running' : Color(0xFFF1F1F1),
      'denied':  Color(0xFFB3B3B3),
      'paused': Color(0xFFF1F1F1),
      'resumed' : Color(0xFFFFFFFF),
      'resume' : Color(0xFFFFFFFF),
      'subscription_purchase' : Color(0xFFFFFFFF),
      'subscription_renew' : Color(0xFFFFFFFF),
      'subscription_shift' : Color(0xFFF1F1F1),
      'subscription_refund' : Color(0xFFB3B3B3),
    },
    error: Color(0xFFE07A7A),
    success: Color(0xFFF1F1F1),
    info: Color(0xFFB3B3B3),
    warning: Color(0xFFD4D4D4),
    cardColor: Color(0xFF262626),
    searchBarBorder: Color(0xFF2E2E2E),
  );

  @override
  CustomThemeColors copyWith({
    Map<String, Color>? buttonBackgroundColorMap,
    Map<String, Color>? buttonTextColorMap,
  }) {
    return CustomThemeColors(
      buttonBackgroundColorMap: buttonBackgroundColorMap ?? this.buttonBackgroundColorMap,
      buttonTextColorMap: buttonTextColorMap ?? this.buttonTextColorMap,
      error: error,
      success: success,
      info: info,
      warning: warning,
      cardColor: cardColor,
      searchBarBorder: searchBarBorder,
    );
  }

  @override
  CustomThemeColors lerp(ThemeExtension<CustomThemeColors>? other, double t) {
    if (other is! CustomThemeColors) return this;

    return CustomThemeColors(
      buttonBackgroundColorMap: buttonBackgroundColorMap,
      buttonTextColorMap: buttonTextColorMap,
      error: error,
      success: success,
      info: info,
      warning: warning,
      cardColor: cardColor,
      searchBarBorder: searchBarBorder,
    );
  }
}

