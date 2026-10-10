import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class CustomCheckBox extends StatelessWidget {
  final String title;
  final Function()? onTap;
  final bool? value;
  const CustomCheckBox({super.key, required this.title, this.onTap, this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 20.0,
        child: Checkbox(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2)),
            activeColor: InkColors.foreground,
            value: value,
            side:  BorderSide(width: 1, color: InkColors.mutedForeground),
            onChanged: onTap != null ?  (bool? isActive) => onTap!() : null
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall,),
      Text(title.tr,
        style: value == true
            ? robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: InkColors.foreground)
            : robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: InkColors.mutedForeground),
      ),
    ]);
  }
}
