import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class CategoryTabItem extends GetView<BookingRequestController> {
  const CategoryTabItem({super.key, required this.title, this.index});
  final String title;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final isActive = controller.bookingHistorySelectedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            index == 0
                ? Icons.list_alt_rounded
                : index == 1
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
            size: 14,
            color: isActive
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: robotoMedium.copyWith(
              fontSize: 12,
              color: isActive
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
