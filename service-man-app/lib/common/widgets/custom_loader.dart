
import 'package:demandium_serviceman/utils/core_export.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({super.key,});

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Ios27Tokens.glassFill(context),
          borderRadius: BorderRadius.circular(Ios27Tokens.radiusMd),
          border: Border.all(color: Ios27Tokens.rim(context), width: 0.5),
        ),
        alignment: Alignment.center,
        child: CircularProgressIndicator(color: Theme.of(context).primaryColorLight.withValues(alpha:0.6),)));
  }
}
