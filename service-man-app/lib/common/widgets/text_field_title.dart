import 'package:jassdbx_serviceman/utils/core_export.dart';

class TextFieldTitle extends StatelessWidget {
  final String title;
  final bool requiredMark;
  final double? fontSize;
  const TextFieldTitle({super.key, required this.title, this.requiredMark = false, this.fontSize}) ;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall, top: Dimensions.paddingSizeDefault),
      child: RichText(
          text:
            TextSpan(children: <TextSpan>[
                TextSpan(text: title, style: robotoMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: fontSize ?? Dimensions.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                )),
                TextSpan(text: requiredMark?' *':"", style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error)),
          ])),
    );
  }
}
