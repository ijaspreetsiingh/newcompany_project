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

  // Predefined themes for light and dark modes
  factory CustomThemeColors.light() => CustomThemeColors(
    buttonBackgroundColorMap: {
      'pending': Color(0x3f85c6f6),
      'accepted': Color(0x5e97c6f6),
      'ongoing': Color(0x629ac5f8),
      'completed': Color(0x4a83b691),
      'settled': Color(0x6e93b347),
      'canceled': Color(0x51F38484),
      'approved': Color(0x47568C67),
      'expired': Color(0x8C7C3B3B),
      'running': Color(0x4d7984da),
      'denied': Color(0x666e3737),
      'paused': Color(0x524caff8),
      'resumed': Color(0x6f2f5e41),
      'resume': Color(0x8e387c54),
      'subscription_purchase': Color(0x3cecc98d),
      'subscription_renew': Color(0x1d6bf5a2),
      'subscription_shift': Color(0x452599ee),
      'subscription_refund': Color(0x1dc97eee),
    },
    buttonTextColorMap: {
      'pending': Color(0xff0461A5),
      'accepted': Color(0xff2B95FF),
      'ongoing': Color(0xff2B95FF),
      'completed': Color(0xff0ea852),
      'settled': Color(0xf57b9826),
      'canceled': Color(0xffFF3737),
      'approved': Color(0xff16B559),
      'expired': Color(0xff9ca8af),
      'running': Color(0xff707ec6),
      'denied': Color(0xffFF3737),
      'paused': Color(0xff0461A5),
      'resumed': Color(0xff16B559),
      'resume': Color(0xff16B559),
      'subscription_purchase': Color(0xff2563EB),
      'subscription_renew': Color(0xff16B559),
      'subscription_shift': Color(0xff0461A5),
      'subscription_refund': Color(0xffba4af8),
    },
    error: Color(0xffEF4444),
    success: Color(0xff22C55E),
    info: Color(0xff3C76F1),
    warning: Color(0xffFFBB38),
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
    earningStatisticBorderColor: Color(0xffEFF1F4),
  );

  factory CustomThemeColors.dark() => CustomThemeColors(
    buttonBackgroundColorMap: {
      'pending': Color(0x3f85c6f6),
      'accepted': Color(0x5e97c6f6),
      'ongoing': Color(0x629ac5f8),
      'completed': Color(0x4a83b691),
      'settled': Color(0x6e93b347),
      'canceled': Color(0x51F38484),
      'approved': Color(0x47568C67),
      'expired': Color(0x8C7C3B3B),
      'running': Color(0x4d7984da),
      'denied': Color(0x666e3737),
      'paused': Color(0x524caff8),
      'resumed': Color(0x6f2f5e41),
      'resume': Color(0x8e387c54),
      'subscription_purchase': Color(0x3cecc98d),
      'subscription_renew': Color(0x1d6bf5a2),
      'subscription_shift': Color(0x452599ee),
      'subscription_refund': Color(0x1dc97eee),
    },
    buttonTextColorMap: {
      'pending': Color(0xff0461A5),
      'accepted': Color(0xff2B95FF),
      'ongoing': Color(0xff2B95FF),
      'completed': Color(0xff0ea852),
      'settled': Color(0xf57b9826),
      'canceled': Color(0xffFF3737),
      'approved': Color(0xff16B559),
      'expired': Color(0xff9ca8af),
      'running': Color(0xff707ec6),
      'denied': Color(0xffFF3737),
      'paused': Color(0xff0461A5),
      'resumed': Color(0xff16B559),
      'resume': Color(0xff16B559),
      'subscription_purchase': Color(0xff2563EB),
      'subscription_renew': Color(0xff16B559),
      'subscription_shift': Color(0xff0461A5),
      'subscription_refund': Color(0xffba4af8),
    },
    error: Color(0xffEF4444),
    success: Color(0xff22C55E),
    info: Color(0xff245BD1),
    warning: Color(0xffE6A832),
    shadow: null,
    lightShadow: null,
    cardBottomShadow: [BoxShadow()],
    cardShadow: [BoxShadow()],
    earningStatisticBorderColor: Color(0xff252d39),
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
      cardBottomShadow: cardBottomShadow,
      cardShadow: cardShadow,
      earningStatisticBorderColor: earningStatisticBorderColor,
    );
  }
}
