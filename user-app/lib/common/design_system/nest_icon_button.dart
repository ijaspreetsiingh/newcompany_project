import 'package:flutter/material.dart';

/// nest. Design System Icon Button
/// Circular icon button with 42px size
class NestIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;

  const NestIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.filled = false,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = filled
        ? (isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414))
        : Colors.transparent;
    final defaultIconColor = filled
        ? (isDark ? const Color(0xFF0D0D0D) : Colors.white)
        : (isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414));
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);

    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: backgroundColor ?? defaultBgColor,
          shape: BoxShape.circle,
          border: !filled ? Border.all(color: borderColor) : null,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Icon(
              icon,
              size: 19,
              color: iconColor ?? defaultIconColor,
            ),
          ),
        ),
      ),
    );
  }
}



