import 'package:jassdbx_provider/util/core_export.dart';

/// Design System Specs (from /design):
/// - Padding horizontal: 16px (px-4)
/// - Section spacing: 24px (gap-6)
/// - Card radius: 0.9rem (14.4px)
/// - Spacing: 8px, 12px, 16px, 24px base units
/// - Font: Space Grotesk (display), Manrope (body)

class InkSection extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget child;
  final EdgeInsets padding;

  const InkSection({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.02,
                  height: 1.2,
                ),
              ),
              if (action != null && onAction != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    action!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: InkColors.mutedForeground,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12), // mb-3
          child,
        ],
      ),
    );
  }
}

class InkStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;

  const InkStatCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14), // p-3.5
      decoration: BoxDecoration(
        color: InkColors.card,
        border: Border.all(color: InkColors.border, width: 1),
        borderRadius: BorderRadius.circular(14.4), // radius-xl
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, -14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.14,
              color: InkColors.mutedForeground,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: InkColors.foreground,
                height: 1,
              ),
            ),
          ),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Text(
              delta!,
              style: TextStyle(
                fontSize: 11,
                color: InkColors.mutedForeground,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class InkEmptyState extends StatelessWidget {
  final String text;

  const InkEmptyState({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: InkColors.card,
        border: Border.all(color: InkColors.border),
        borderRadius: BorderRadius.circular(14.4),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: InkColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}

class InkDivider extends StatelessWidget {
  final double height;
  const InkDivider({super.key, this.height = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: InkColors.border,
    );
  }
}

/// Spacing constants matching design system
class InkSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Colors from design system
class InkDesignColors {
  static const Color background = Color(0xFFFBFBFB); // oklch(0.985 0 0)
  static const Color foreground = Color(0xFF252525); // oklch(0.145 0 0)
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE5E5E5); // oklch(0.905 0 0)
  static const Color mutedForeground = Color(0xFF8B8B8B); // oklch(0.545 0 0)
  static const Color secondary = Color(0xFFF3F3F3); // oklch(0.955 0 0)
}
