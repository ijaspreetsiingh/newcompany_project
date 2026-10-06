import 'package:flutter/material.dart';

class CustomThemeColors extends ThemeExtension<CustomThemeColors> {
  final Map<String, Color> buttonBackgroundColorMap;
  final Map<String, Color> buttonTextColorMap;
  final Color error;
  final Color success;
  final Color info;
  final Color warning;
  final List<BoxShadow>? shadow;
  final List<BoxShadow>? lightShadow;
  final List<BoxShadow>? cardShadow;
  final List<BoxShadow>? cardBottomShadow;
  final Color? earningStatisticBorderColor;

  const CustomThemeColors({
    required this.buttonBackgroundColorMap,
    required this.buttonTextColorMap,
    required this.error,
    required this.success,
    required this.info,
    required this.warning,
    required this.shadow,
    required this.lightShadow,
    required this.cardShadow,
    required this.cardBottomShadow,
    required this.earningStatisticBorderColor,
  });

  // Monochrome status chips: neutral = ink tint, active = solid ink, alert = red tint
  factory CustomThemeColors.light() => CustomThemeColors(
    buttonBackgroundColorMap: {
      'pending': Color(0x14111111),
      'accepted': Color(0xFF111111),
      'ongoing': Color(0xFF111111),
      'completed': Color(0xFF111111),
      'settled': Color(0xFF111111),
      'canceled': Color(0x1AEF4444),
      'approved': Color(0xFF111111),
      'expired': Color(0x14111111),
      'running': Color(0xFF111111),
      'denied': Color(0x1AEF4444),
      'paused': Color(0x14111111),
      'resumed': Color(0xFF111111),
      'resume': Color(0xFF111111),
      'subscription_purchase': Color(0x14111111),
      'subscription_renew': Color(0x14111111),
      'subscription_shift': Color(0x14111111),
      'subscription_refund': Color(0x14111111),
    },
    buttonTextColorMap: {
      'pending': Color(0xFF52525B),
      'accepted': Color(0xFFFFFFFF),
      'ongoing': Color(0xFFFFFFFF),
      'completed': Color(0xFFFFFFFF),
      'settled': Color(0xFFFFFFFF),
      'canceled': Color(0xFFDC2626),
      'approved': Color(0xFFFFFFFF),
      'expired': Color(0xFF71717A),
      'running': Color(0xFFFFFFFF),
      'denied': Color(0xFFDC2626),
      'paused': Color(0xFF52525B),
      'resumed': Color(0xFFFFFFFF),
      'resume': Color(0xFFFFFFFF),
      'subscription_purchase': Color(0xFF52525B),
      'subscription_renew': Color(0xFF52525B),
      'subscription_shift': Color(0xFF52525B),
      'subscription_refund': Color(0xFF52525B),
    },
    error: Color(0xFFDC2626),
    success: Color(0xFF16A34A),
    info: Color(0xFF52525B),
    warning: Color(0xFFB45309),
    shadow: [
      BoxShadow(
        offset: const Offset(0, 2),
        blurRadius: 8,
        color: Colors.black.withValues(alpha: 0.08),
      ),
    ],
    lightShadow: [
      BoxShadow(
        offset: const Offset(0, 1),
        blurRadius: 4,
        spreadRadius: 0,
        color: Colors.black.withValues(alpha: 0.05),
      ),
    ],
    cardShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ],
    cardBottomShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        offset: const Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
    earningStatisticBorderColor: Color(0xFFEDEDED),
  );

  factory CustomThemeColors.dark() => CustomThemeColors(
    buttonBackgroundColorMap: {
      'pending': Color(0x1AFFFFFF),
      'accepted': Color(0xFFEDEDED),
      'ongoing': Color(0xFFEDEDED),
      'completed': Color(0xFFEDEDED),
      'settled': Color(0xFFEDEDED),
      'canceled': Color(0x22EF4444),
      'approved': Color(0xFFEDEDED),
      'expired': Color(0x1AFFFFFF),
      'running': Color(0xFFEDEDED),
      'denied': Color(0x22EF4444),
      'paused': Color(0x1AFFFFFF),
      'resumed': Color(0xFFEDEDED),
      'resume': Color(0xFFEDEDED),
      'subscription_purchase': Color(0x1AFFFFFF),
      'subscription_renew': Color(0x1AFFFFFF),
      'subscription_shift': Color(0x1AFFFFFF),
      'subscription_refund': Color(0x1AFFFFFF),
    },
    buttonTextColorMap: {
      'pending': Color(0xFFA1A1AA),
      'accepted': Color(0xFF0A0A0A),
      'ongoing': Color(0xFF0A0A0A),
      'completed': Color(0xFF0A0A0A),
      'settled': Color(0xFF0A0A0A),
      'canceled': Color(0xFFF87171),
      'approved': Color(0xFF0A0A0A),
      'expired': Color(0xFF71717A),
      'running': Color(0xFF0A0A0A),
      'denied': Color(0xFFF87171),
      'paused': Color(0xFFA1A1AA),
      'resumed': Color(0xFF0A0A0A),
      'resume': Color(0xFF0A0A0A),
      'subscription_purchase': Color(0xFFA1A1AA),
      'subscription_renew': Color(0xFFA1A1AA),
      'subscription_shift': Color(0xFFA1A1AA),
      'subscription_refund': Color(0xFFA1A1AA),
    },
    error: Color(0xFFF87171),
    success: Color(0xFF4ADE80),
    info: Color(0xFFA1A1AA),
    warning: Color(0xFFFBBF24),
    shadow: null,
    lightShadow: null,
    cardBottomShadow: [BoxShadow()],
    cardShadow: [BoxShadow()],
    earningStatisticBorderColor: Color(0xFF242424),
  );

  @override
  CustomThemeColors copyWith({
    Map<String, Color>? buttonBackgroundColorMap,
    Map<String, Color>? buttonTextColorMap,
  }) {
    return CustomThemeColors(
      buttonBackgroundColorMap:
          buttonBackgroundColorMap ?? this.buttonBackgroundColorMap,
      buttonTextColorMap: buttonTextColorMap ?? this.buttonTextColorMap,
      error: error,
      success: success,
      info: info,
      warning: warning,
      shadow: shadow,
      lightShadow: lightShadow,
      cardShadow: cardShadow,
      cardBottomShadow: cardBottomShadow,
      earningStatisticBorderColor: earningStatisticBorderColor,
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
      shadow: shadow,
      lightShadow: lightShadow,
      cardShadow: cardShadow,
      cardBottomShadow: cardBottomShadow,
      earningStatisticBorderColor: earningStatisticBorderColor,
    );
  }
}
