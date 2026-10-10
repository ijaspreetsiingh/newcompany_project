import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final Function()? onTap;
  const QuantityButton({super.key, required this.isIncrement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingEditController>(builder: (bookingEditController){

      final bool enabled = !bookingEditController.isLoading && onTap != null;

      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(kRadiusMd),
        child: Container(
          height: 36, width: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.kCard,
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: Border.all(color: context.kInputBorder, width: 1),
          ),
          child: Icon(
            isIncrement ? Icons.add_rounded : Icons.remove_rounded,
            size: 18,
            color: enabled ? context.kForeground : context.kMutedForeground,
          ),
        ),
      );
    });
  }
}
