import 'package:flutter/material.dart';

import 'custom_theme_colors.dart';
import 'light_theme.dart';

/// "Ink" — black & white theme (dark).
/// Base: #0A0A0A · Card: #141414 · Ink-inverse: #EDEDED
ThemeData dark = ThemeData(
  fontFamily: 'Manrope',
  primaryColor: const Color(0xFFEDEDED),
  primaryColorLight: AppThemeColors.primaryLight,
  primaryColorDark: AppThemeColors.primaryDark,
  scaffoldBackgroundColor: const Color(0xFF0A0A0A),
  cardColor: const Color(0xFF141414),

  shadowColor: const Color(0xFF1F1F1F),
  canvasColor: const Color(0xFF141414),

  secondaryHeaderColor: const Color(0xFF9A9A9A),
  disabledColor: const Color(0xFF3F3F46),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF8E8E93),
  focusColor: const Color(0xFF1F1F1F),
  hoverColor: const Color(0xFFEDEDED),
  timePickerTheme: const TimePickerThemeData(
    backgroundColor: Color(0xFF141414),
  ),
  datePickerTheme: const DatePickerThemeData(
    backgroundColor: Color(0xFF141414),
  ),
  extensions: <ThemeExtension<CustomThemeColors>>[CustomThemeColors.dark()],
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFEDEDED),
    secondary: Color(0xFF9A9A9A),
    onPrimary: Color(0xFF0A0A0A),
    onSecondary: Color(0xFF0A0A0A),
    onSecondaryContainer: AppThemeColors.success,
    tertiary: Color(0xFFEDEDED),
    onTertiary: Color(0xFF111111),
    error: Color(0xFFF87171),
  ).copyWith(surface: const Color(0xFF0A0A0A)),

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFFEDEDED),
    selectionHandleColor: Color(0xFFEDEDED),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: const Color(0xFFEDEDED)),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFEDEDED),
      foregroundColor: const Color(0xFF0A0A0A),
      disabledForegroundColor: Colors.white38,
      disabledBackgroundColor: const Color(0xFF3F3F46),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFEDEDED),
      side: const BorderSide(color: Color(0x33EDEDED), width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF141414),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: const TextStyle(
      fontFamily: 'Manrope',
      fontSize: 14,
      color: Color(0xFF8E8E93),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Color(0xFFFFFFFF).withValues(alpha: 0.08),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEDEDED), width: 1.3),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFF87171), width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.3),
    ),
  ),

  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
    backgroundColor: Color(0xFF0A0A0A),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFFEDEDED),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: const Color(0xFFF4F4F5),
    contentTextStyle: const TextStyle(
      fontFamily: 'Manrope',
      color: Color(0xFF111111),
      fontSize: 14,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  dividerTheme: const DividerThemeData(
    thickness: 0.5,
    color: Color(0x14FFFFFF),
  ),
);
