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

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

      Flexible(
        child: Text(title!.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge,
          color: onColoredBg
              ? Colors.white
              : titleColor ?? Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .9),
        ),maxLines: 1,overflow: TextOverflow.ellipsis,),
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall,),
      (onTap != null) ? InkWell(
        onTap: onTap,
        child: Text('see_all'.tr,
          style: robotoMedium.copyWith(
            decoration: textDecoration,
            color: onColoredBg
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
      ) : const SizedBox(),
    ]);
  }
}
