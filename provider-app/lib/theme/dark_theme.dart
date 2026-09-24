import 'package:flutter/material.dart';

import 'custom_theme_colors.dart';
import 'light_theme.dart';

/// Option B — Royal Blue (dark)
/// Primary: #60A5FA (blue-400 for dark-bg contrast) · Deep: #1D4ED8
ThemeData dark = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: const Color(0xFF60A5FA),
  primaryColorLight: AppThemeColors.primaryLight,
  primaryColorDark: AppThemeColors.primaryDark,
  scaffoldBackgroundColor: const Color(0xFF0F172A),
  cardColor: const Color(0xFF1E293B),

  shadowColor: const Color(0xFF334155),
  canvasColor: const Color(0xFF1E293B),

  secondaryHeaderColor: const Color(0xFF94A3B8),
  disabledColor: const Color(0xFF475569),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF94A3B8),
  focusColor: const Color(0xFF1E3A5F),
  hoverColor: const Color(0xFF93C5FD),
  timePickerTheme: const TimePickerThemeData(
    backgroundColor: Color(0xFF1E293B),
  ),
  datePickerTheme: const DatePickerThemeData(
    backgroundColor: Color(0xFF1E293B),
  ),
  extensions: <ThemeExtension<CustomThemeColors>>[CustomThemeColors.dark()],
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF60A5FA),
    secondary: Color(0xFF38BDF8),
    onPrimary: Color(0xFF0F172A),
    onSecondary: Color(0xFF0F172A),
    onSecondaryContainer: AppThemeColors.success,
    tertiary: Color(0xFF3B82F6),
    onTertiary: Color(0xFFDBEAFE),
    error: Color(0xFFEF4444),
  ).copyWith(surface: const Color(0xFF0F172A)),

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFF60A5FA),
    selectionHandleColor: Color(0xFF60A5FA),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: const Color(0xFF60A5FA)),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF60A5FA),
      foregroundColor: const Color(0xFF0F172A),
      disabledForegroundColor: Colors.white70,
      disabledBackgroundColor: const Color(0xFF475569),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF60A5FA),
      side: const BorderSide(color: Color(0x4D60A5FA), width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF0F172A),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: const TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      color: Color(0xFF94A3B8),
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
      borderSide: BorderSide(
        color: const Color(0xFF60A5FA).withValues(alpha: 0.85),
        width: 1.3,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.3),
    ),
  ),

  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
    backgroundColor: Color(0xFF0F172A),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF60A5FA),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: const Color(0xFF334155),
    contentTextStyle: const TextStyle(
      fontFamily: 'Roboto',
      color: Colors.white,
      fontSize: 14,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  dividerTheme: const DividerThemeData(
    thickness: 0.5,
    color: Color(0x33FFFFFF),
  ),
);
