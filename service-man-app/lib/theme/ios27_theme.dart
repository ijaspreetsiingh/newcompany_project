import 'package:demandium_serviceman/theme/custom_theme_colors.dart';
import 'package:demandium_serviceman/theme/ios27_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Ios27Theme {
  Ios27Theme._();

  static const String _font = 'Roboto';

  static TextTheme _textTheme(Color label, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w700,
        fontSize: 34,
        letterSpacing: 0.37,
        color: label,
      ),
      displayMedium: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: 0.36,
        color: label,
      ),
      headlineLarge: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w700,
        fontSize: 22,
        letterSpacing: 0.35,
        color: label,
      ),
      headlineMedium: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: 0.38,
        color: label,
      ),
      titleLarge: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w600,
        fontSize: 17,
        letterSpacing: -0.41,
        color: label,
      ),
      titleMedium: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: -0.32,
        color: label,
      ),
      titleSmall: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: -0.24,
        color: label,
      ),
      bodyLarge: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w400,
        fontSize: 17,
        letterSpacing: -0.41,
        color: label,
      ),
      bodyMedium: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w400,
        fontSize: 15,
        letterSpacing: -0.24,
        color: label,
      ),
      bodySmall: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w400,
        fontSize: 13,
        letterSpacing: -0.08,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w600,
        fontSize: 17,
        letterSpacing: -0.41,
        color: label,
      ),
      labelMedium: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w500,
        fontSize: 13,
        letterSpacing: -0.08,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        letterSpacing: 0.06,
        color: secondary,
      ),
    );
  }

  static InputDecorationTheme _input(bool isDark, Color accent) {
    final fill = isDark ? Ios27Tokens.darkFill : Ios27Tokens.lightFill;
    final rim = isDark ? const Color(0xFFA6A6A6) : const Color(0xFFDBDBDB);
    final radius = BorderRadius.circular(Ios27Tokens.radiusSm);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: 0.5),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(
        fontFamily: _font,
        color: isDark
            ? Ios27Tokens.darkTertiaryLabel
            : Ios27Tokens.lightTertiaryLabel,
      ),
      border: border(rim),
      enabledBorder: border(rim),
      focusedBorder: border(accent),
      errorBorder: border(Ios27Tokens.systemRed),
      disabledBorder: border(rim.withValues(alpha: 0.5)),
    );
  }

  static ThemeData light() {
    const accent = Ios27Tokens.accent;
    const canvas = Ios27Tokens.lightCanvas;
    const card = Ios27Tokens.lightCard;
    const label = Ios27Tokens.lightLabel;
    const secondary = Ios27Tokens.lightSecondaryLabel;
    final scheme = const ColorScheme.light(
      primary: accent,
      onPrimary: Colors.white,
      secondary: Ios27Tokens.brandSecondary,
      tertiary: Ios27Tokens.systemRed,
      onTertiary: Ios27Tokens.systemYellow,
      surface: canvas,
      onSurface: label,
      surfaceTint: Color(0xFF22C55E),
      error: Ios27Tokens.systemRed,
    );
    return _base(
      brightness: Brightness.light,
      accent: accent,
      accentDark: const Color(0xFF1D4ED8),
      canvas: canvas,
      card: card,
      label: label,
      secondary: secondary,
      hint: const Color(0xFF8E8E93),
      focus: card,
      hover: const Color(0xFF1E40AF),
      disabled: const Color(0xFFC7C7CC),
      shadow: const Color(0xFFD1D5DB),
      scheme: scheme,
      overlay: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: canvas,
      ),
      extensions: [CustomThemeColors.light()],
    );
  }

  static ThemeData dark() {
    const accent = Ios27Tokens.accentDark;
    const canvas = Ios27Tokens.darkCanvas;
    const card = Ios27Tokens.darkCard;
    const label = Ios27Tokens.darkLabel;
    const secondary = Ios27Tokens.darkSecondaryLabel;
    final scheme = const ColorScheme.dark(
      primary: accent,
      onPrimary: Colors.white,
      secondary: Color(0xFF0EA5E9),
      tertiary: Ios27Tokens.systemRed,
      onTertiary: Color(0xFF1E3A5F),
      surface: canvas,
      onSurface: label,
      surfaceTint: Color(0xFF22C55E),
      error: Color(0xFFEF4444),
    );
    return _base(
      brightness: Brightness.dark,
      accent: accent,
      accentDark: const Color(0xFF1D4ED8),
      canvas: canvas,
      card: card,
      label: label,
      secondary: secondary,
      hint: const Color(0xFF8E8E93),
      focus: const Color(0xFF2C2C2E),
      hover: const Color(0xFFABA9A7),
      disabled: const Color(0xFF48484A),
      shadow: const Color(0xFF4A5361),
      scheme: scheme,
      overlay: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: canvas,
      ),
      extensions: [CustomThemeColors.dark()],
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required Color accent,
    required Color accentDark,
    required Color canvas,
    required Color card,
    required Color label,
    required Color secondary,
    required Color hint,
    required Color focus,
    required Color hover,
    required Color disabled,
    required Color shadow,
    required ColorScheme scheme,
    required SystemUiOverlayStyle overlay,
    required List<ThemeExtension<dynamic>> extensions,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      fontFamily: _font,
      brightness: brightness,
      primaryColor: accent,
      primaryColorLight: isDark ? Ios27Tokens.lightCanvas : accent,
      primaryColorDark: accentDark,
      secondaryHeaderColor: secondary,
      cardColor: card,
      disabledColor: disabled,
      scaffoldBackgroundColor: canvas,
      hintColor: hint,
      focusColor: focus,
      hoverColor: hover,
      shadowColor: shadow,
      dividerColor: isDark
          ? Ios27Tokens.darkSeparator
          : Ios27Tokens.lightSeparator,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      colorScheme: scheme,
      textTheme: _textTheme(label, secondary),
      extensions: extensions,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: card.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        foregroundColor: label,
        shadowColor: Colors.transparent,
        systemOverlayStyle: overlay,
        titleTextStyle: TextStyle(
          fontFamily: _font,
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: isDark ? Ios27Tokens.lightCanvas : accent,
        ),
        iconTheme: IconThemeData(
          color: isDark ? Ios27Tokens.lightCanvas : accent,
          size: 22,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Ios27Tokens.radiusMd),
          side: BorderSide(
            color: isDark ? const Color(0xFFA6A6A6) : const Color(0xFFDBDBDB),
            width: 0.5,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card.withValues(alpha: 0.92),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Ios27Tokens.radiusLg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card.withValues(alpha: 0.92),
        modalBackgroundColor: card.withValues(alpha: 0.92),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Ios27Tokens.radiusLg),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, Ios27Tokens.controlHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Ios27Tokens.radiusSm),
          ),
          textStyle: const TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, Ios27Tokens.controlHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Ios27Tokens.radiusSm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(88, Ios27Tokens.controlHeight),
          side: BorderSide(color: accent.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Ios27Tokens.radiusSm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Ios27Tokens.radiusLg),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return Colors.transparent;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Ios27Tokens.systemGreen;
          }
          return const Color(0xFF787880).withValues(alpha: 0.32);
        }),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: accent,
        labelColor: isDark ? Ios27Tokens.lightCanvas : accent,
        unselectedLabelColor: secondary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontFamily: _font,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Ios27Tokens.darkSeparator : Ios27Tokens.lightSeparator,
        thickness: 0.5,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: accent,
        textColor: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? Ios27Tokens.darkFill : Ios27Tokens.lightFill,
        selectedColor: accent,
        labelStyle: TextStyle(fontFamily: _font, color: label, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Ios27Tokens.radiusPill),
        ),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xCC1C1C1E),
        contentTextStyle: const TextStyle(
          fontFamily: _font,
          color: Colors.white,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Ios27Tokens.radiusSm),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
      inputDecorationTheme: _input(isDark, accent),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: accent,
        scaffoldBackgroundColor: canvas,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
