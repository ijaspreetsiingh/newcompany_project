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
      'pending': Color(0xff1D293D),
      'accepted': Color(0xff1D293D),
      'ongoing': Color(0xffD8F4DF),
      'completed': Color(0xff1D293D),
      'canceled': Color(0xff1D293D),
      'approved': Color(0xff1D293D),
      'denied': Color(0xff1D293D),
    },
    buttonTextColorMap: {
      'pending': Color(0xffF8FAFC),
      'accepted': Color(0xffF8FAFC),
      'ongoing': Color(0xff008849),
      'completed': Color(0xffF8FAFC),
      'canceled': Color(0xffF8FAFC),
      'approved': Color(0xffF8FAFC),
      'denied': Color(0xffF8FAFC),
    },
    error: Color(0xffE7000B),
    success: Color(0xff008849),
    info: Color(0xffE2E8F0),
    warning: Color(0xffE6A832),
    cardShadow: [BoxShadow()],
    orderStatisticBorderColor: Color(0x1AFFFFFF),
    canceledBusinessSummaryCardColor: Color(0xffE7000B),
    canceledBusinessSummaryCurveColor: Color(0xffF87171),
    assignedBusinessSummaryCardColor: Color(0xFFE2E8F0),
    assignedBusinessSummaryCurveColor: Color(0xFF90A1B9),
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
