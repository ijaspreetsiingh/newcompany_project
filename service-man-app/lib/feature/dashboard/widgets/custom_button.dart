import 'package:demandium_serviceman/utils/core_export.dart';

class DashboardCustomButton extends StatelessWidget {
  final String buttonText;
  final bool isSelectedButton;
  const DashboardCustomButton({super.key,required this.buttonText,required this.isSelectedButton}) ;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 32,
      width: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Ios27Tokens.radiusPill),
        color: isSelectedButton
            ? Theme.of(context).primaryColor
            : Ios27Tokens.fieldFill(context),
        border: Border.all(
          color: isSelectedButton ? Theme.of(context).primaryColor : Ios27Tokens.rim(context),
          width: 0.5,
        ),
      ),
      child:  Center(
        child: Text(
          buttonText,
          style:  TextStyle(
              fontSize: 12,
              color: isSelectedButton ? Colors.white : Theme.of(context).hintColor,
              fontWeight: FontWeight.w600),
        ),
      ),

    );
  }
}
