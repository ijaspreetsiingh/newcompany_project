import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final Function()? onPressed;
  final bool? transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double? radius;
  final IconData? icon;
  final Color? color;
  final String btnTxt;
  final bool isLoading;
  const CustomButton({super.key, this.onPressed, this.transparent = false, this.margin, this.width, this.height,this.color,
    this.fontSize, this.radius = Ios27Tokens.radiusSm, this.icon,required this.btnTxt, this.isLoading = false });

  @override
  Widget build(BuildContext context) {
    final Color bg = onPressed == null
        ? Theme.of(context).disabledColor
        : transparent!
        ? Colors.transparent
        : color ?? Theme.of(context).colorScheme.primary;
    final Color fg = transparent!
        ? Theme.of(context).colorScheme.primary
        : _onColor(bg);
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      elevation: 0,
      backgroundColor: bg,
      foregroundColor: fg,
      minimumSize: Size(width != null ? width! : Dimensions.webMaxWidth, height != null ? height! : Ios27Tokens.controlHeight),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius!),
      ),
    );

    return Center(child: SizedBox(width: width ?? Dimensions.webMaxWidth, child: Padding(
      padding: margin == null ? const EdgeInsets.all(0) : margin!,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: flatButtonStyle,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          icon != null ? Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
            child: Icon(icon, color: fg, size: fontSize ?? Dimensions.fontSizeLarge,),
          ) : const SizedBox(),

          isLoading ? Padding( padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: SizedBox(height: fontSize ?? Dimensions.fontSizeDefault , width: fontSize ?? Dimensions.fontSizeDefault,
              child: CircularProgressIndicator(color: fg, strokeWidth: 2,),
            ),
          ): const SizedBox(),

          Text( isLoading ? "loading".tr :btnTxt, textAlign: TextAlign.center, style: robotoMedium.copyWith(
            color: fg,
            fontSize: fontSize ?? Dimensions.fontSizeLarge,
          )),
        ]),
      ),
    )));
  }

  static Color _onColor(Color bg) {
    try {
      return bg.computeLuminance() > 0.5 ? const Color(0xFF070707) : const Color(0xFFFCFCFC);
    } catch (_) {
      return Colors.white;
    }
  }
}