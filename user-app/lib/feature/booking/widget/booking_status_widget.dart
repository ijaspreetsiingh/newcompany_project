import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

/// nest. status chip : hatrline border pill + dot + bold label (monochrome)
class BookingStatusButtonWidget extends StatelessWidget {
  final String? bookingStatus;
  const BookingStatusButtonWidget({super.key, this.bookingStatus});

  @override
  Widget build(BuildContext context) {
    final bool isCanceled = bookingStatus == "canceled" || bookingStatus == "denied";
    final Color contentColor = isCanceled
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).textTheme.bodyLarge!.color!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isCanceled ? Theme.of(context).colorScheme.error.withValues(alpha: 0.08) : Colors.transparent,
        border: Border.all(
          color: isCanceled
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.4)
              : Theme.of(context).primaryColorLight.withValues(alpha: Get.isDarkMode ? 0.6 : 1),
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 6, width: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: contentColor,
          ),
        ),
        const SizedBox(width: 6),
        Text(bookingStatus?.tr ?? "",
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: contentColor,
          ),
        ),
      ]),
    );
  }
}

