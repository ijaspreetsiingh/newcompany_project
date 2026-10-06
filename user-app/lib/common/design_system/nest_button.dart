import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// nest. Design System Button
/// Variants: primary, outline, ghost, danger
enum NestButtonVariant { primary, outline, ghost, danger }

class NestButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final NestButtonVariant variant;
  final bool fullWidth;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;

  const NestButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = NestButtonVariant.primary,
    this.fullWidth = false,
    this.isLoading = false,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final backgroundColor = _getBackgroundColor(isDark);
    final foregroundColor = _getForegroundColor(isDark);
    final borderColor = _getBorderColor(isDark);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
          ),
          disabledBackgroundColor: backgroundColor.withOpacity(0.5),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 8)],
                  Text(
                    text,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: foregroundColor,
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 8), trailing!],
                ],
              ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    switch (variant) {
      case NestButtonVariant.primary:
        return isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
      case NestButtonVariant.outline:
      case NestButtonVariant.ghost:
        return Colors.transparent;
      case NestButtonVariant.danger:
        return const Color(0xFFD64545);
    }
  }

  Color _getForegroundColor(bool isDark) {
    switch (variant) {
      case NestButtonVariant.primary:
        return isDark ? const Color(0xFF0D0D0D) : Colors.white;
      case NestButtonVariant.outline:
      case NestButtonVariant.ghost:
        return isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
      case NestButtonVariant.danger:
        return Colors.white;
    }
  }

  Color? _getBorderColor(bool isDark) {
    switch (variant) {
      case NestButtonVariant.primary:
      case NestButtonVariant.danger:
        return null;
      case NestButtonVariant.outline:
        return isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);
      case NestButtonVariant.ghost:
        return null;
    }
  }
}



