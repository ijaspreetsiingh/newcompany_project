import 'package:flutter/material.dart';

class CustomThemeColors extends ThemeExtension<CustomThemeColors> {
  final Map<String, Color> buttonBackgroundColorMap;
  final Map<String, Color> buttonTextColorMap;
  final Color error;
  final Color success;
  final Color info;
  final Color warning;
  final List<BoxShadow>? cardShadow;
  final Color? orderStatisticBorderColor;
  final Color canceledBusinessSummaryCardColor;
  final Color canceledBusinessSummaryCurveColor;
  final Color assignedBusinessSummaryCardColor;
  final Color assignedBusinessSummaryCurveColor;
  final Color ongoingBusinessSummaryCardColor;
  final Color ongoingBusinessSummaryCurveColor;

  const CustomThemeColors({
    required this.buttonBackgroundColorMap,
    required this.buttonTextColorMap,
    required this.error,
    required this.success,
    required this.info,
    required this.warning,
    required this.cardShadow,
    required this.orderStatisticBorderColor,
    required this.canceledBusinessSummaryCardColor,
    required this.canceledBusinessSummaryCurveColor,
    required this.assignedBusinessSummaryCardColor,
    required this.assignedBusinessSummaryCurveColor,
    required this.ongoingBusinessSummaryCardColor,
    required this.ongoingBusinessSummaryCurveColor,
  });

  // Predefined themes for light and dark modes
  factory CustomThemeColors.light() => CustomThemeColors(
    buttonBackgroundColorMap: {
      'pending': Color(0xffEBEBEB),
      'accepted': Color(0xffEBEBEB),
      'ongoing': Color(0xffD8F4DF),
      'completed': Color(0xffEBEBEB),
      'canceled': Color(0xffEBEBEB),
      'approved': Color(0xffEBEBEB),
      'denied': Color(0xffEBEBEB),
    },
    buttonTextColorMap: {
      'pending': Color(0xff070707),
      'accepted': Color(0xff070707),
      'ongoing': Color(0xff008849),
      'completed': Color(0xff070707),
      'canceled': Color(0xff070707),
      'approved': Color(0xff070707),
      'denied': Color(0xff070707),
    },
    error: Color(0xffE7000B),
    success: Color(0xff008849),
    info: Color(0xff070707),
    warning: Color(0xffFFBB38),
    cardShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
    ],
    orderStatisticBorderColor: Color(0xffCACACA),
    canceledBusinessSummaryCardColor: Color(0xffE7000B),
    canceledBusinessSummaryCurveColor: Color(0xffF87171),
    assignedBusinessSummaryCardColor: Color(0xFF070707),
    assignedBusinessSummaryCurveColor: Color(0xFF5B5B5B),
    ongoingBusinessSummaryCardColor: Color(0xFF008849),
    ongoingBusinessSummaryCurveColor: Color(0xFF34A86B),
  );

  factory CustomThemeColors.dark() => CustomThemeColors(
    buttonBackgroundColorMap: {
      'pending': Color(0x1FFFFFFF),
      'accepted': Color(0x29FFFFFF),
      'ongoing': Color(0x33FFFFFF),
      'completed': Color(0x1FFFFFFF),
      'canceled': Color(0x0FFFFFFF),
      'approved': Color(0x1FFFFFFF),
      'denied': Color(0x1FFFFFFF),
    },
    buttonTextColorMap: {
      'pending': Color(0xFFD4D4D4),
      'accepted': Color(0xFFF1F1F1),
      'ongoing': Color(0xFFF1F1F1),
      'completed': Color(0xFFFFFFFF),
      'canceled': Color(0xFF8C8C8C),
      'approved': Color(0xFFFFFFFF),
      'denied': Color(0xFFB3B3B3),
    },
    error: Color(0xFFE07A7A),
    success: Color(0xFF008849),
    info: Color(0xFFB3B3B3),
    warning: Color(0xFFD4D4D4),
    cardShadow: [BoxShadow()],
    orderStatisticBorderColor: Color(0xFF333333),
    canceledBusinessSummaryCardColor: Color(0xFFE07A7A),
    canceledBusinessSummaryCurveColor: Color(0xFFE07A7A),
    assignedBusinessSummaryCardColor: Color(0xFFF1F1F1),
    assignedBusinessSummaryCurveColor: Color(0xFFB3B3B3),
    ongoingBusinessSummaryCardColor: Color(0xFF008849),
    ongoingBusinessSummaryCurveColor: Color(0xFF34A86B),
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
      cardShadow: cardShadow,
      orderStatisticBorderColor: orderStatisticBorderColor,
      canceledBusinessSummaryCardColor: canceledBusinessSummaryCardColor,
      canceledBusinessSummaryCurveColor: canceledBusinessSummaryCurveColor,
      assignedBusinessSummaryCardColor: assignedBusinessSummaryCardColor,
      assignedBusinessSummaryCurveColor: assignedBusinessSummaryCurveColor,
      ongoingBusinessSummaryCardColor: ongoingBusinessSummaryCardColor,
      ongoingBusinessSummaryCurveColor: ongoingBusinessSummaryCurveColor,
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
      cardShadow: cardShadow,
      orderStatisticBorderColor: orderStatisticBorderColor,
      canceledBusinessSummaryCardColor: canceledBusinessSummaryCardColor,
      canceledBusinessSummaryCurveColor: canceledBusinessSummaryCurveColor,
      assignedBusinessSummaryCardColor: assignedBusinessSummaryCardColor,
      assignedBusinessSummaryCurveColor: assignedBusinessSummaryCurveColor,
      ongoingBusinessSummaryCardColor: ongoingBusinessSummaryCardColor,
      ongoingBusinessSummaryCurveColor: ongoingBusinessSummaryCurveColor,
    );
  }
}
