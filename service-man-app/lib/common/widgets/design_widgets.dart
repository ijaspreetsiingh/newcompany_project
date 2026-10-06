import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

/// Semantic colors of the reference (KaamPro) design system.
extension DesignColors on BuildContext {
  Color get kBackground => Theme.of(this).scaffoldBackgroundColor;
  Color get kCard => Theme.of(this).cardColor;
  Color get kForeground => Theme.of(this).colorScheme.onSurface;
  Color get kMuted => Theme.of(this).colorScheme.secondaryContainer;
  Color get kMutedForeground => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get kBorder => Theme.of(this).colorScheme.outline;
  Color get kInputBorder => Theme.of(this).colorScheme.outlineVariant;
  Color get kPrimary => Theme.of(this).colorScheme.primary;
  Color get kPrimaryForeground => Theme.of(this).colorScheme.onPrimary;
  Color get kSuccess => const Color(0xFF008849);
  Color get kSuccessSoft => const Color(0xFFD8F4DF);
  Color get kDestructive => Theme.of(this).colorScheme.error;
}

const double kRadiusSm = 8;
const double kRadiusMd = 10;
const double kRadiusLg = 12;

/// 36x36 ghost icon button (reference `Button size="icon" variant="ghost"`).
class KIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? color;
  final bool showBadge;

  const KIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 36,
    this.iconSize = 20,
    this.color,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = color ?? context.kForeground;
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kRadiusMd),
          hoverColor: context.kMuted,
          highlightColor: context.kMuted,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, size: iconSize, color: fg),
              if (showBadge)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.kSuccess,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.kBackground, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sticky page header with back button, title, subtitle and trailing action.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? right;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: context.kBackground,
        border: Border(bottom: BorderSide(color: context.kBorder, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          if (onBack != null) ...[
            KIconButton(icon: Icons.arrow_back_rounded, onTap: onBack, color: context.kForeground),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(
                    fontSize: 20,
                    color: context.kForeground,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: 12,
                      color: context.kMutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?right,
        ],
      ),
    );
  }
}

/// Bordered card used all over the reference design.
class KCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final VoidCallback? onTap;

  const KCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.radius = kRadiusMd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? context.kCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: context.kBorder, width: 1),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: content,
    );
  }
}

/// Stat tile — label on top, bold display value below.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool success;

  const StatCard({super.key, required this.label, required this.value, this.success = false});

  @override
  Widget build(BuildContext context) {
    return KCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(fontSize: 10, color: context.kMutedForeground),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: robotoBold.copyWith(
              fontSize: 20,
              color: success ? context.kSuccess : context.kForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status pill — green only for live (ongoing) status, muted otherwise.
/// Pass the RAW status (e.g. 'pending'); the label is translated.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  bool get _isLive {
    final s = status.toLowerCase();
    return s == 'ongoing' || s == 'in_progress';
  }

  @override
  Widget build(BuildContext context) {
    final bool live = _isLive;
    final Color bg = live ? context.kSuccessSoft : context.kMuted;
    final Color fg = live ? context.kSuccess : context.kForeground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.tr,
            style: robotoBold.copyWith(fontSize: 10, color: fg),
          ),
        ],
      ),
    );
  }
}

/// Section heading (display font, semibold).
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoBold.copyWith(fontSize: 18, color: context.kForeground),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// "See all" style link button.
class LinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const LinkButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kRadiusSm),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: robotoMedium.copyWith(fontSize: 12, color: context.kForeground),
            ),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded, size: 14, color: context.kMutedForeground),
          ],
        ),
      ),
    );
  }
}

/// Filter chip used for list filters (reference button size="sm").
class KFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const KFilterChip({super.key, required this.label, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.kPrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(kRadiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadiusMd),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: selected ? null : Border.all(color: context.kInputBorder, width: 1),
          ),
          child: Text(
            label,
            style: (selected ? robotoMedium : robotoMedium).copyWith(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? context.kPrimaryForeground : context.kForeground,
            ),
          ),
        ),
      ),
    );
  }
}

/// Section title + divided card rows (reference `MenuGroup`).
class MenuGroup extends StatelessWidget {
  final String? title;
  final List<MenuGroupItem> items;

  const MenuGroup({super.key, this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title!.toUpperCase(),
              style: robotoBold.copyWith(
                fontSize: 12,
                letterSpacing: 0.5,
                color: context.kMutedForeground,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: context.kCard,
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: Border.all(color: context.kBorder, width: 1),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                InkWell(
                  onTap: items[i].onTap,
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(items[i].icon, size: 18, color: context.kForeground),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            items[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoMedium.copyWith(
                              fontSize: 14,
                              color: context.kForeground,
                            ),
                          ),
                        ),
                        if (items[i].trailing != null)
                          items[i].trailing!
                        else
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: context.kMutedForeground,
                          ),
                      ],
                    ),
                  ),
                ),
                if (i != items.length - 1)
                  Divider(height: 1, thickness: 1, color: context.kBorder),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class MenuGroupItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  const MenuGroupItem({required this.icon, required this.label, this.onTap, this.trailing});
}

/// Reference `ToggleRow` — title + caption on the left, 48x28 switch on the right.
class ToggleRow extends StatelessWidget {
  final String title;
  final String? text;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ToggleRow({
    super.key,
    required this.title,
    this.text,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: robotoBold.copyWith(fontSize: 14, color: context.kForeground),
              ),
              if (text != null) ...[
                const SizedBox(height: 2),
                Text(
                  text!,
                  style: robotoRegular.copyWith(fontSize: 12, color: context.kMutedForeground),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onChanged == null ? null : () => onChanged!(!value),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 28,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: value ? context.kSuccess : context.kMuted,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: context.kCard,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty list state (reference `Empty`).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const EmptyState({super.key, required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: context.kMuted, shape: BoxShape.circle),
            child: Icon(icon, size: 24, color: context.kMutedForeground),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: robotoBold.copyWith(fontSize: 14, color: context.kForeground),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(fontSize: 12, color: context.kMutedForeground),
          ),
        ],
      ),
    );
  }
}

/// Avatar with optional online dot (reference `Avatar`).
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final bool large;
  final bool online;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.large = false,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = large ? 96 : 44;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.kCard, width: 2),
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? CustomImage(image: imageUrl!, width: size, height: size, fit: BoxFit.cover)
                : Container(
                    color: context.kMuted,
                    alignment: Alignment.center,
                    child: Text(
                      (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : 'S',
                      style: robotoBold.copyWith(
                        fontSize: large ? 34 : 16,
                        color: context.kMutedForeground,
                      ),
                    ),
                  ),
          ),
        ),
        if (online)
          Positioned(
            right: 0,
            bottom: 0,
            child: _PulseDot(context: context),
          ),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  final BuildContext context;
  const _PulseDot({required this.context});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BuildContext c = widget.context;
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.42).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: c.kSuccess,
          shape: BoxShape.circle,
          border: Border.all(color: c.kBackground, width: 2),
        ),
      ),
    );
  }
}

/// Uppercase caption used inside primary cards (`Info` section titles).
class CaptionTitle extends StatelessWidget {
  final String text;

  const CaptionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: robotoBold.copyWith(
        fontSize: 12,
        letterSpacing: 0.5,
        color: context.kMutedForeground,
      ),
    );
  }
}

/// Bordered info card with icon rows (reference `Info`).
class InfoCard extends StatelessWidget {
  final String title;
  final List<InfoRow> rows;

  const InfoCard({super.key, required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CaptionTitle(title),
          const SizedBox(height: 12),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(row.icon, size: 16, color: context.kMutedForeground),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row.text,
                      style: robotoRegular.copyWith(fontSize: 14, color: context.kForeground),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class InfoRow {
  final IconData icon;
  final String text;

  const InfoRow(this.icon, this.text);
}

/// Full width primary/outline button following the reference button metrics.
class KButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool outline;
  final bool destructive;
  final double height;
  final bool expanded;

  const KButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.outline = false,
    this.destructive = false,
    this.height = 48,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = destructive
        ? context.kDestructive
        : outline
        ? Colors.transparent
        : context.kPrimary;
    final Color fg = outline
        ? (destructive ? context.kDestructive : context.kForeground)
        : (bg.computeLuminance() > 0.5 ? const Color(0xFF070707) : const Color(0xFFFCFCFC));

    final Widget child = Material(
      color: bg,
      borderRadius: BorderRadius.circular(kRadiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadiusMd),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: outline && !destructive
                ? Border.all(color: context.kInputBorder, width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: robotoMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!expanded) return child;
    return SizedBox(width: double.infinity, child: child);
  }
}
