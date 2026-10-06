import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// nest. shared UI components (reference: designnew/src/routes/index.tsx)
/// Har screen me reuse hote hain - theme colors follow karte hain
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

/// nest. primary button - flat black rounded-2xl, white text
class NestButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isOutlined;
  final bool isDestructive;
  final IconData? icon;
  const NestButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isOutlined = false,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color bg = isOutlined
        ? Colors.transparent
        : isDestructive
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary;
    final Color fg = isOutlined
        ? Theme.of(context).textTheme.bodyLarge!.color!
        : (isDark ? Colors.black : Colors.white);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            side: isOutlined
                ? BorderSide(color: Theme.of(context).primaryColorLight.withValues(alpha: isDark ? 0.6 : 1))
                : BorderSide.none,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: Dimensions.paddingSizeSmall),
          ],
          Flexible(child: Text(label, style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: fg,
          ), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}

/// nest. page header : back circle + bold title + optional action
class NestPageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? action;
  final VoidCallback? onBackPressed;
  const NestPageHeader({super.key, required this.title, this.action, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color borderColor = Theme.of(context).primaryColorLight.withValues(alpha: isDark ? 0.4 : 1);

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: onBackPressed ?? () {
          if (Navigator.canPop(context)) {
            Get.back();
          } else {
            Get.offAllNamed(RouteHelper.getMainRoute('home'));
          }
        },
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18,
          color: Theme.of(context).textTheme.bodyLarge!.color),
      ),
      title: Text(title, style: robotoBold.copyWith(
        fontSize: Dimensions.fontSizeExtraLarge,
        color: Theme.of(context).textTheme.bodyLarge!.color,
      ), maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [
        if (action != null) ...[
          action!,
          const SizedBox(width: Dimensions.paddingSizeDefault),
        ],
      ],
      shape: Border(bottom: BorderSide(width: 0.6, color: borderColor)),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// nest. section title : bold black + "See all â†’" arrow link
class NestSectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onActionTap;
  const NestSectionTitle({super.key, required this.title, this.action, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault, Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: Text(title, style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeExtraLarge,
          color: Theme.of(context).textTheme.bodyLarge!.color,
        ), maxLines: 1, overflow: TextOverflow.ellipsis)),
        if (action != null)
          InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(action!, style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                )),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 15,
                  color: Theme.of(context).textTheme.bodyLarge!.color),
              ]),
            ),
          ),
      ]),
    );
  }
}

/// nest. price summary card : grey rounded, rows + divider + total
class NestPriceSummary extends StatelessWidget {
  final List<SummaryRow> rows;
  final String? totalLabel;
  final String totalValue;
  const NestPriceSummary({
    super.key,
    required this.rows,
    required this.totalValue,
    this.totalLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('payment_summary'.tr, style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).textTheme.bodyLarge!.color,
        )),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        ...rows.map((row) => Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(row.label, style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodySmall?.color,
            )),
            Text(row.value, style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            )),
          ]),
        )),
        Divider(height: 1, thickness: 1,
          color: Theme.of(context).primaryColorDark.withValues(alpha: 0.15)),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(totalLabel ?? 'amount_to_pay'.tr, style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          )),
          Text(totalValue, style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          )),
        ]),
      ]),
    );
  }
}

class SummaryRow {
  final String label;
  final String value;
  const SummaryRow(this.label, this.value);
}

/// nest. selection row : grey icon chip + title + sub + radio/check (radio list me)
class NestSelectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? sub;
  final String? trailing;
  final bool selected;
  final VoidCallback? onTap;
  const NestSelectionCard({
    super.key,
    required this.icon,
    required this.title,
    this.sub,
    this.trailing,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color borderColor = Theme.of(context).primaryColorLight.withValues(alpha: isDark ? 0.4 : 1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            height: 40, width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColorLight,
            ),
            child: Icon(icon, size: 19, color: Theme.of(context).textTheme.bodyLarge!.color),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (sub != null && sub!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(sub!, style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ])),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          trailing != null
              ? Text(trailing!, style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  letterSpacing: 0.5,
                  color: Theme.of(context).colorScheme.primary,
                ))
              : _NestRadio(selected: selected),
        ]),
      ),
    );
  }
}

/// nest. radio indicator : black circle with white check when selected
class _NestRadio extends StatelessWidget {
  final bool selected;
  const _NestRadio({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22, width: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).hintColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 14,
              color: Get.isDarkMode ? Colors.black : Colors.white)
          : const SizedBox(),
    );
  }
}

/// nest. progress stepper : 1 â†’ 2 â†’ 3 with labels (Schedule, Payment, Confirmed)
class NestProgressSteps extends StatelessWidget {
  final int current;
  final List<String> labels;
  const NestProgressSteps({super.key, required this.current, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(children: [
        Row(children: List.generate(labels.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Expanded(child: Container(height: 1.5,
              color: (index ~/ 2) < current
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).primaryColorLight));
          }
          final int step = index ~/ 2;
          final bool done = step < current;
          return Container(
            height: 28, width: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? Theme.of(context).colorScheme.primary : Colors.transparent,
              border: Border.all(
                color: done
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).hintColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Center(child: done
                ? Icon(Icons.check_rounded, size: 15,
                    color: Get.isDarkMode ? Colors.black : Colors.white)
                : Text('${step + 1}', style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor))),
          );
        })),
        const SizedBox(height: 6),
        Row(children: labels.map((label) => Expanded(child: Text(label,
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Theme.of(context).hintColor,
          )))).toList()),
      ]),
    );
  }
}

/// nest. empty state : grey circle icon + bold title + grey text
class NestEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? text;
  final String? actionLabel;
  final VoidCallback? onAction;
  const NestEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          height: 64, width: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColorLight,
          ),
          child: Icon(icon, size: 28, color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Text(title, textAlign: TextAlign.center, style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          color: Theme.of(context).textTheme.bodyLarge!.color,
        )),
        if (text != null) ...[
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(text!, textAlign: TextAlign.center, style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).hintColor,
          )),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: Dimensions.paddingSizeLarge),
          SizedBox(
            width: 180,
            child: NestButton(label: actionLabel!, onTap: onAction, isOutlined: true),
          ),
        ],
      ]),
    ));
  }
}



