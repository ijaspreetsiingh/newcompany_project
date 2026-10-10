import 'package:jassdbx_serviceman/theme/custom_theme_colors.dart';
import 'package:jassdbx_serviceman/theme/ios27_tokens.dart';
import 'package:jassdbx_serviceman/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// KaamPro theme — monochrome token system transcribed from design_refrence.
/// Display headings use Outfit, body copy uses Figtree.
class Ios27Theme {
  Ios27Theme._();

  static const String _body = kBodyFont;
  static const String _display = kDisplayFont;

  static TextTheme _textTheme(Color label, Color secondary) {
    TextStyle display(double size, FontWeight weight, {Color? color}) =>
        TextStyle(
          fontFamily: _display,
          fontWeight: weight,
          fontSize: size,
          letterSpacing: 0,
          color: color ?? label,
        );
    TextStyle body(double size, FontWeight weight, {Color? color}) =>
        TextStyle(
          fontFamily: _body,
          fontWeight: weight,
          fontSize: size,
          letterSpacing: 0,
          color: color ?? label,
        );

    return TextTheme(
      displayLarge: display(36, FontWeight.w800),
      displayMedium: display(30, FontWeight.w700),
      displaySmall: display(26, FontWeight.w700),
      headlineLarge: display(24, FontWeight.w700),
      headlineMedium: display(20, FontWeight.w700),
      headlineSmall: display(18, FontWeight.w700),
      titleLarge: display(20, FontWeight.w700),
      titleMedium: display(16, FontWeight.w700),
      titleSmall: display(14, FontWeight.w700),
      bodyLarge: body(16, FontWeight.w400),
      bodyMedium: body(14, FontWeight.w400),
      bodySmall: body(12, FontWeight.w400, color: secondary),
      labelLarge: body(14, FontWeight.w500),
      labelMedium: body(12, FontWeight.w500),
      labelSmall: body(10, FontWeight.w500, color: secondary),
    );
  }

  static InputDecorationTheme _input(bool isDark) {
    final card = isDark ? Ios27Tokens.darkCard : Ios27Tokens.lightCard;
    final border = isDark
        ? const Color(0x26FFFFFF)
        : const Color(0xFFDEDEDE);
    final focus = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF070707);
    final hint = isDark
        ? Ios27Tokens.darkSecondaryLabel
        : Ios27Tokens.lightSecondaryLabel;
    final radius = BorderRadius.circular(Ios27Tokens.radiusSm);
    OutlineInputBorder outline(Color color) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: 1),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: card,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: TextStyle(
        fontFamily: _body,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: hint,
      ),
      helperStyle: TextStyle(fontFamily: _body, fontSize: 12, color: hint),
      errorStyle: TextStyle(
        fontFamily: _body,
        fontSize: 12,
        color: Ios27Tokens.destructive,
      ),
      prefixStyle: TextStyle(
        fontFamily: _body,
        fontSize: 14,
        color: isDark ? Ios27Tokens.darkLabel : Ios27Tokens.lightLabel,
      ),
      suffixStyle: TextStyle(
        fontFamily: _body,
        fontSize: 14,
        color: isDark ? Ios27Tokens.darkLabel : Ios27Tokens.lightLabel,
      ),
      border: outline(border),
      enabledBorder: outline(border),
      focusedBorder: outline(focus),
      errorBorder: outline(Ios27Tokens.destructive),
      focusedErrorBorder: outline(Ios27Tokens.destructive),
      disabledBorder: outline(border.withValues(alpha: 0.5)),
    );
  }

  static ThemeData light() {
    const canvas = Ios27Tokens.lightCanvas;
    const card = Ios27Tokens.lightCard;
    const label = Ios27Tokens.lightLabel;
    const secondary = Ios27Tokens.lightSecondaryLabel;
    final scheme = const ColorScheme.light(
      primary: Color(0xFF070707),
      onPrimary: Color(0xFFFCFCFC),
      primaryContainer: Color(0xFF070707),
      onPrimaryContainer: Color(0xFFFCFCFC),
      secondary: Color(0xFFE6E6E6),
      onSecondary: Color(0xFF070707),
      secondaryContainer: Color(0xFFEBEBEB),
      onSecondaryContainer: Color(0xFF070707),
      tertiary: Color(0xFF008849),
      onTertiary: Color(0xFFFCFCFC),
      tertiaryContainer: Color(0xFFD8F4DF),
      onTertiaryContainer: Color(0xFF008849),
      surface: canvas,
      onSurface: label,
      onSurfaceVariant: secondary,
      surfaceContainerHighest: card,
      error: Color(0xFFE7000B),
      onError: Color(0xFFF8FAFC),
      outline: Color(0xFFCACACA),
      outlineVariant: Color(0xFFDEDEDE),
      scrim: Colors.black,
    );
    return _base(
      brightness: Brightness.light,
      accent: const Color(0xFF070707),
      onAccent: const Color(0xFFFCFCFC),
      accentDark: const Color(0xFF070707),
      canvas: canvas,
      card: card,
      label: label,
      secondary: secondary,
      hint: const Color(0xFF5B5B5B),
      focus: card,
      hover: const Color(0xFFEBEBEB),
      disabled: const Color(0xFFDEDEDE),
      shadow: const Color(0x14000000),
      scheme: scheme,
      overlay: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: canvas,
      ),
      extensions: [CustomThemeColors.light()],
    );
  }

  static ThemeData dark() {
    const canvas = Ios27Tokens.darkCanvas;
    const card = Ios27Tokens.darkCard;
    const label = Ios27Tokens.darkLabel;
    const secondary = Ios27Tokens.darkSecondaryLabel;
    final scheme = const ColorScheme.dark(
      primary: Color(0xFFE2E8F0),
      onPrimary: Color(0xFF0F172B),
      primaryContainer: Color(0xFFE2E8F0),
      onPrimaryContainer: Color(0xFF0F172B),
      secondary: Color(0xFF1D293D),
      onSecondary: Color(0xFFF8FAFC),
      secondaryContainer: Color(0xFF1D293D),
      onSecondaryContainer: Color(0xFFF8FAFC),
      tertiary: Color(0xFF008849),
      onTertiary: Color(0xFFF8FAFC),
      tertiaryContainer: Color(0xFF0B3D24),
      onTertiaryContainer: Color(0xFFD8F4DF),
      surface: canvas,
      onSurface: label,
      onSurfaceVariant: secondary,
      surfaceContainerHighest: card,
      error: Color(0xFFE7000B),
      onError: Color(0xFFF8FAFC),
      outline: Color(0x1AFFFFFF),
      outlineVariant: Color(0x26FFFFFF),
      scrim: Colors.black,
    );
    return _base(
      brightness: Brightness.dark,
      accent: const Color(0xFFE2E8F0),
      onAccent: const Color(0xFF0F172B),
      accentDark: const Color(0xFFE2E8F0),
      canvas: canvas,
      card: card,
      label: label,
      secondary: secondary,
      hint: const Color(0xFF90A1B9),
      focus: card,
      hover: const Color(0xFF1D293D),
      disabled: const Color(0xFF1D293D),
      shadow: Colors.black,
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
    required Color onAccent,
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
    final border = isDark ? const Color(0x1AFFFFFF) : const Color(0xB3CACACA);

    return ThemeData(
      useMaterial3: true,
      fontFamily: _body,
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
      dividerColor: border,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      colorScheme: scheme,
      textTheme: _textTheme(label, secondary),
      extensions: extensions,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        foregroundColor: label,
        shadowColor: Colors.transparent,
        systemOverlayStyle: overlay,
        titleTextStyle: TextStyle(
          fontFamily: _display,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: label,
        ),
        iconTheme: IconThemeData(color: label, size: 22),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Ios27Tokens.radiusMd),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Ios27Tokens.radiusLg),
          side: BorderSide(color: border, width: 1),
        ),
        titleTextStyle: TextStyle(
          fontFamily: _display,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: label,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _body,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: label,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        modalBackgroundColor: card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: accent,
          foregroundColor: onAccent,
          minimumSize: const Size(88, Ios27Tokens.controlHeight),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Ios27Tokens.radiusSm),
          ),
          textStyle: const TextStyle(
            fontFamily: _body,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          minimumSize: const Size(88, Ios27Tokens.controlHeight),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Ios27Tokens.radiusSm),
          ),
          textStyle: const TextStyle(
            fontFamily: _body,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: label,
          backgroundColor: canvas,
          minimumSize: const Size(88, Ios27Tokens.controlHeight),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          side: BorderSide(
            color: isDark ? const Color(0x26FFFFFF) : const Color(0xFFDEDEDE),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Ios27Tokens.radiusSm),
          ),
          textStyle: const TextStyle(
            fontFamily: _body,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: label,
          minimumSize: const Size(0, 36),
          textStyle: const TextStyle(
            fontFamily: _body,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: onAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Ios27Tokens.radiusPill),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: Color(0xFFDEDEDE), width: 1),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.resolveWith((_) => onAccent),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFFCFCFC);
          }
          return isDark ? const Color(0xFF90A1B9) : const Color(0xFF5B5B5B);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Ios27Tokens.success;
          }
          return isDark ? const Color(0xFF1D293D) : const Color(0xFFDEDEDE);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: label,
        labelColor: label,
        unselectedLabelColor: secondary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontFamily: _body,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: _body,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: label,
        textColor: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: accent,
        labelStyle: TextStyle(
          fontFamily: _body,
          color: label,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: _body,
          color: onAccent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          color: isDark ? const Color(0x26FFFFFF) : const Color(0xFFDEDEDE),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Ios27Tokens.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: accent,
        contentTextStyle: TextStyle(
          fontFamily: _body,
          color: onAccent,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Ios27Tokens.radiusSm),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
      inputDecorationTheme: _input(isDark),
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
