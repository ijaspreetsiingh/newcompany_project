import 'package:jassdbx_provider/util/core_export.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// Picks the line icon used by [CategoryItem] from the category name so the
/// grid stays readable even when the API does not ship an image.
String categoryIconAsset(String name) {
  final String n = name.toLowerCase().trim();

  if (n.contains('air condition') ||
      n.contains('cool') ||
      n.startsWith('ac') ||
      n.contains(' ac')) {
    return 'assets/icons/ac.svg';
  }
  if (n.contains('deep') || n.contains('polish') || n.contains('shine')) {
    return 'assets/icons/sparkle.svg';
  }
  if (n.contains('clean') || n.contains('housekeep')) {
    return 'assets/icons/cleaning.svg';
  }
  if (n.contains('pest') ||
      n.contains('insect') ||
      n.contains('termite') ||
      n.contains('mosquito')) {
    return 'assets/icons/bug.svg';
  }
  if (n.contains('paint') ||
      n.contains('wall') ||
      n.contains('decor') ||
      n.contains('renovat')) {
    return 'assets/icons/roller.svg';
  }
  if (n.contains('fan') || n.contains('ventilat')) {
    return 'assets/icons/fan.svg';
  }
  if (n.contains('pipe') ||
      n.contains('leak') ||
      n.contains('plumb') ||
      n.contains('drain') ||
      n.contains('faucet') ||
      n.contains('tank') ||
      n.contains('water')) {
    return 'assets/icons/droplet.svg';
  }
  if (n.contains('carpent') ||
      n.contains('wood') ||
      n.contains('furniture') ||
      n.contains('handyman')) {
    return 'assets/icons/toolbox.svg';
  }
  if (n.contains('electric') ||
      n.contains('wiring') ||
      n.contains('socket') ||
      n.contains('switch') ||
      n.contains('bulb') ||
      n.contains('light')) {
    return 'assets/icons/bolt.svg';
  }
  if (n.contains('repair') ||
      n.contains('fix') ||
      n.contains('maintain') ||
      n.contains('install')) {
    return 'assets/icons/wrench.svg';
  }
  return 'assets/icons/grid.svg';
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.index,
    required this.title,
    required this.isSelected,
    required this.isSubscribed,
    this.subCategoryCount,
    this.serviceCount,
    this.subtitle,
    required this.onTap,
  });

  final int index;
  final String title;
  final bool isSelected;
  final bool isSubscribed;
  final int? subCategoryCount;
  final int? serviceCount;

  /// Category description — used as the card's second line when the exact
  /// sub-category / service counts are not known yet.
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String? meta;
    if (subCategoryCount != null && serviceCount != null) {
      meta = '${'sub_category'.trPlural('sub_categories', subCategoryCount, [ '$subCategoryCount' ])} · $serviceCount ${'services'.tr}';
    } else if (subtitle != null && subtitle!.trim().isNotEmpty) {
      meta = subtitle!.trim();
    }

    return InkCard(
      color: isSelected ? InkColors.secondary : null,
      borderColor: isSelected ? InkColors.foreground : null,
      borderWidth: isSelected ? 1.5 : 1,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: SizedBox(
        height: 112,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? InkColors.foreground : InkColors.inkTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SvgPicture.asset(
                    categoryIconAsset(title),
                    height: 22,
                    width: 22,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      isSelected ? InkColors.background : InkColors.foreground,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 28,
                  width: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSubscribed
                        ? InkColors.foreground
                        : Colors.transparent,
                    border: isSubscribed
                        ? null
                        : Border.all(color: InkColors.border),
                  ),
                  child: Icon(
                    isSubscribed ? Icons.check_rounded : Icons.add_rounded,
                    size: 14,
                    color: isSubscribed
                        ? InkColors.background
                        : InkColors.mutedForeground,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(
                    fontSize: 14,
                    height: 1.2,
                    color: InkColors.foreground,
                  ),
                ),
                if (meta != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: 11,
                      height: 1.3,
                      color: InkColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
