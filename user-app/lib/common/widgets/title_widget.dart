import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class TitleWidget extends StatelessWidget {
  final String? title;
  final TextDecoration? textDecoration;
  final Function()? onTap;
  final Color? titleColor;
  const TitleWidget({super.key, required this.title, this.onTap, this.textDecoration, this.titleColor});

  @override
  Widget build(BuildContext context) {
    bool onColoredBg = title == 'recently_view_services';

    /// nest. style section heading : bold black title + bold "See all â†’" arrow link
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

      Flexible(
        child: Text(title!.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge,
          color: onColoredBg
              ? Colors.white
              : titleColor ?? Theme.of(context).textTheme.bodyLarge!.color,
        ),maxLines: 1,overflow: TextOverflow.ellipsis,),
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall,),
      (onTap != null) ? InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('see_all'.tr,
            style: robotoBold.copyWith(
              decoration: textDecoration,
              color: onColoredBg
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge!.color,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.arrow_forward_rounded, size: 16,
            color: onColoredBg
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge!.color),
        ]),
      ) : const SizedBox(),
    ]);
  }
}


