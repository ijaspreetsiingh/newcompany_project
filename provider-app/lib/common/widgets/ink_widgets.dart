import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// INK shared screen primitives — Flutter port of design/src/components/app/ui.tsx
/// Pure black & white, editorial typography, soft paper surfaces.
/// ---------------------------------------------------------------------------

/// INK palette tokens (mirrors design/src/styles.css).
///
/// Every token is a *getter* so the whole palette flips with the active
/// theme. Call [InkColors.setDarkMode] whenever the theme changes (done by
/// `ThemeController` + `MyApp`) so every screen reads the right values.
class InkColors {
  InkColors._();

  static bool _dark = false;

  /// Current palette mode. `false` = light, `true` = dark.
  static bool get isDark => _dark;

  /// Switches the palette. Safe to call as often as needed.
  static void setDarkMode(bool value) {
    if (_dark == value) return;
    _dark = value;
  }

  static Color get background => _dark ? const Color(0xFF0A0A0A) : const Color(0xFFFBFBFB); // --background
  static Color get foreground => _dark ? const Color(0xFFEDEDED) : const Color(0xFF111111); // --foreground
  static Color get paper => _dark ? const Color(0xFF101010) : const Color(0xFFF5F5F5); // --paper
  static Color get card => _dark ? const Color(0xFF141414) : const Color(0xFFFFFFFF); // --card
  static Color get secondary => _dark ? const Color(0xFF1C1C1C) : const Color(0xFFF2F2F2); // --secondary
  static Color get mutedForeground => _dark ? const Color(0xFFA1A1AA) : const Color(0xFF737373); // --muted-foreground
  static Color get accent => _dark ? const Color(0xFF242424) : const Color(0xFFE5E5E5); // --accent
  static Color get destructive => _dark ? const Color(0xFFF87171) : const Color(0xFFC62828); // --destructive
  static Color get border => _dark ? const Color(0xFF2C2C2C) : const Color(0xFFE7E7E7); // --border
  static Color get inkSoft => _dark ? const Color(0xFFA1A1AA) : const Color(0xFF5B5B5B); // --ink-soft
  static Color get chart1 => _dark ? const Color(0xFFEDEDED) : const Color(0xFF2B2B2B);
  static Color get chart2 => _dark ? const Color(0xFFB4B4B4) : const Color(0xFF6B6B6B);
  static Color get chart3 => _dark ? const Color(0xFF7A7A7A) : const Color(0xFF9E9E9E);
  static Color get chart4 => _dark ? const Color(0xFF4A4A4A) : const Color(0xFFCFCFCF);

  /// Hairline tints of the ink colour — used for chip/border fills so they
  /// stay readable on both light and dark surfaces.
  static Color get inkTint => foreground.withValues(alpha: 0.08);
  static Color get inkTintStrong => foreground.withValues(alpha: 0.12);
  static Color get inkLine => foreground.withValues(alpha: 0.22);
  static Color get dangerTint => destructive.withValues(alpha: 0.10);

  /// Hero card gradient — intentionally dark in both themes (it is the one
  /// "ink" surface that always carries light text).
  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF242424), Color(0xFF141414)],
    stops: [0.0, 0.7],
  );

  static List<BoxShadow> get cardShadow => _dark
      ? const []
      : const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x2E000000), blurRadius: 24, offset: Offset(0, 8), spreadRadius: -14),
        ];

  static List<BoxShadow> get floatShadow => _dark
      ? const []
      : const [
          BoxShadow(color: Color(0x59000000), blurRadius: 30, offset: Offset(0, 10), spreadRadius: -12),
        ];
}

/// `ink-card` utility: white bg, 1px border, radius-xl (0.9rem+5 = ~19px), card shadow.
class InkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const InkCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 19,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: double.infinity,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? InkColors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? InkColors.border, width: borderWidth),
        boxShadow: InkColors.cardShadow,
      ),
      child: child,
    );
    if (onTap == null) return container;
    return GestureDetector(onTap: onTap, child: container);
  }
}

/// `ink-surface` utility: dark gradient hero card, radius-2xl (24px).
class InkSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const InkSurface({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: InkColors.gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: InkColors.cardShadow,
      ),
      child: child,
    );
  }
}

/// eyebrow — uppercase micro label (11px / 0.14em / 700 / muted).
class InkEyebrow extends StatelessWidget {
  final String text;
  final Color? color;

  const InkEyebrow(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        height: 1.2,
        letterSpacing: 1.54,
        fontWeight: FontWeight.w700,
        color: color ?? InkColors.mutedForeground,
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// TopBar — sticky header: circular back button + title/subtitle + trailing.
/// ---------------------------------------------------------------------------
class InkTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? right;

  const InkTopBar({super.key, required this.title, this.subtitle, this.onBack, this.right});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:  BoxDecoration(
        color: InkColors.background,
        border: Border(bottom: BorderSide(color: InkColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: InkColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: InkColors.border),
                ),
                child:  Icon(Icons.chevron_left_rounded, size: 20, color: InkColors.foreground),
              ),
            ),
          if (onBack != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:  TextStyle(
                    fontSize: 17,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: InkColors.foreground,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(fontSize: 11, height: 1.3, color: InkColors.mutedForeground),
                  ),
              ],
            ),
          ),
          if (right != null) right!,
        ],
      ),
    );
  }
}

/// Circular icon button used in headers (calendar / filter / bell ...).
class InkIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;
  final String? badge;

  const InkIconButton({super.key, required this.icon, this.onTap, this.filled = false, this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: filled ? InkColors.foreground : InkColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: InkColors.border),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                icon,
                size: 17,
                color: filled ? InkColors.background : InkColors.foreground,
              ),
            ),
            if (badge != null)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration:  BoxDecoration(color: InkColors.foreground, shape: BoxShape.circle),
                  child: Text(
                    badge!,
                    style:  TextStyle(
                      fontSize: 8,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: InkColors.background,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Section — px-4 block with title + optional action link on the right.
/// ---------------------------------------------------------------------------
class InkSection extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const InkSection({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style:  TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: InkColors.foreground,
                    ),
                  ),
                  if (action != null)
                    GestureDetector(
                      onTap: onAction,
                      child: Text(
                        action!,
                        style:  TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: InkColors.mutedForeground,
                          decoration: TextDecoration.underline,
                          decorationColor: InkColors.mutedForeground,
                          decorationThickness: 1,
                          height: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// StatusChip — pill status label (10px bold uppercase, 0.08em tracking).
/// ---------------------------------------------------------------------------
class InkStatusChip extends StatelessWidget {
  final String status;

  const InkStatusChip({super.key, required this.status});

  static const Map<String, String> labels = {
    'pending': 'PENDING',
    'accepted': 'ACCEPTED',
    'ongoing': 'ONGOING',
    'completed': 'COMPLETED',
    'canceled': 'CANCELED',
    'cancelled': 'CANCELED',
    'running': 'RUNNING',
    'paused': 'PAUSED',
    'resumed': 'RESUMED',
    'approved': 'APPROVED',
    'expired': 'EXPIRED',
    'settled': 'SETTLED',
    'denied': 'DENIED',
    'failed': 'FAILED',
    'successful': 'SUCCESSFUL',
    'cancel': 'CANCELED',
  };

  ({Color bg, Color fg, Color border}) _style() {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'paused':
      case 'expired':
        return (bg: InkColors.secondary, fg: InkColors.foreground, border: InkColors.inkLine);
      case 'accepted':
      case 'running':
      case 'approved':
      case 'settled':
        return (bg: InkColors.inkTint, fg: InkColors.foreground, border: InkColors.inkLine);
      case 'ongoing':
      case 'resumed':
        return (bg: InkColors.foreground, fg: InkColors.background, border: Colors.transparent);
      case 'completed':
      case 'successful':
        return (bg: InkColors.card, fg: InkColors.mutedForeground, border: InkColors.inkLine);
      case 'canceled':
      case 'cancelled':
      case 'cancel':
      case 'denied':
      case 'failed':
        return (bg: InkColors.dangerTint, fg: InkColors.destructive, border: InkColors.destructive.withValues(alpha: 0.3));
      default:
        return (bg: InkColors.secondary, fg: InkColors.foreground, border: InkColors.inkLine);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: s.border),
      ),
      child: Text(
        labels[status.toLowerCase()] ?? status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: s.fg,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Avatar — initials circle (black bg, white initials).
/// ---------------------------------------------------------------------------
class InkAvatar extends StatelessWidget {
  final String name;
  final double size;

  const InkAvatar({super.key, required this.name, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration:  BoxDecoration(color: InkColors.foreground, shape: BoxShape.circle),
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          color: InkColors.background,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Money — ₹ value in display font, tabular figures, en-IN grouping.
/// ---------------------------------------------------------------------------
class InkMoney extends StatelessWidget {
  final num value;
  final TextStyle? style;

  const InkMoney(this.value, {super.key, this.style});

  static String format(num value) {
    final v = value.toDouble();
    if (v == v.roundToDouble() && v.abs() < 1e15) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '₹${_indianGrouping(value)}',
      style: (style ?? const TextStyle()).copyWith(
        fontFamily: 'SpaceGrotesk',
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: -0.2,
      ),
    );
  }

  static String _indianGrouping(num value) {
    final negative = value.isNegative;
    final v = value.abs();
    final isInt = v == v.roundToDouble();
    String s = isInt ? v.round().toString() : v.toStringAsFixed(2);

    String whole;
    String? dec;
    if (!isInt) {
      final idx = s.indexOf('.');
      whole = s.substring(0, idx);
      dec = s.substring(idx);
    } else {
      whole = s;
    }

    String result;
    if (whole.length <= 3) {
      result = whole;
    } else {
      final last3 = whole.substring(whole.length - 3);
      String rest = whole.substring(0, whole.length - 3);
      final buf = <String>[];
      while (rest.length > 2) {
        buf.insert(0, rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) buf.insert(0, rest);
      result = '${buf.join(',')},$last3';
    }
    return '${negative ? '-' : ''}$result${dec ?? ''}';
  }
}

/// ---------------------------------------------------------------------------
/// Stat — eyebrow label + big display value + optional delta.
/// ---------------------------------------------------------------------------
class InkStat extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;

  const InkStat({super.key, required this.label, required this.value, this.delta});

  @override
  Widget build(BuildContext context) {
    return InkCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkEyebrow(label),
          const SizedBox(height: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:  TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 20,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: InkColors.foreground,
                ),
              ),
            ),
          ),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Text(
              delta!,
              style:  TextStyle(fontSize: 11, height: 1.2, color: InkColors.mutedForeground),
            ),
          ],
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Pills — horizontal scrolling filter chips.
/// ---------------------------------------------------------------------------
class InkPills extends StatelessWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;

  const InkPills({super.key, required this.items, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final item = items[i];
          final active = item == value;
          return GestureDetector(
            onTap: () => onChanged(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? InkColors.foreground : InkColors.card,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: active ? Colors.transparent : InkColors.border),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: active ? InkColors.background : InkColors.mutedForeground,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// EmptyState — centered muted message card.
/// ---------------------------------------------------------------------------
class InkEmptyState extends StatelessWidget {
  final String text;

  const InkEmptyState(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkCard(
      padding: const EdgeInsets.all(32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style:  TextStyle(fontSize: 13, height: 1.5, color: InkColors.mutedForeground),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// RowLink — bordered list row: leading + title/meta + chevron.
/// ---------------------------------------------------------------------------
class InkRowLink extends StatelessWidget {
  final String title;
  final String? meta;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  const InkRowLink({
    super.key,
    required this.title,
    this.meta,
    this.onTap,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration:  BoxDecoration(
          border: Border(bottom: BorderSide(color: InkColors.border)),
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: InkColors.foreground,
                    ),
                  ),
                  if (meta != null)
                    Text(
                      meta!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(fontSize: 12, height: 1.3, color: InkColors.mutedForeground),
                    ),
                ],
              ),
            ),
            trailing ??
                 Icon(Icons.chevron_right_rounded, size: 18, color: InkColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}

/// Primary pill button — solid ink (bg-foreground, text-background).
class InkPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final bool expanded;

  const InkPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.height = 44,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: InkColors.foreground,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style:  TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: InkColors.background,
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Secondary pill button — outlined.
class InkSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final bool expanded;

  const InkSecondaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.height = 44,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: InkColors.card,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: InkColors.border),
        ),
        child: Text(
          label,
          style:  TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: InkColors.foreground,
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Round search field (pill, bordered).
class InkSearchField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const InkSearchField({super.key, required this.hint, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: InkColors.card,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: InkColors.border),
      ),
      child: Row(
        children: [
           Icon(Icons.search_rounded, size: 16, color: InkColors.mutedForeground),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style:  TextStyle(fontSize: 13, color: InkColors.foreground),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle:  TextStyle(fontSize: 13, color: InkColors.mutedForeground),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
