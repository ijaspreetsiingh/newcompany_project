import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';

class CategoryTabItem extends GetView<BookingRequestController> {
  const CategoryTabItem({super.key, required this.title, this.index});
  final String title;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final isActive = controller.bookingHistorySelectedIndex == index;

    return KFilterChip(
      label: title,
      selected: isActive,
      onTap: index == null
          ? null
          : () {
              controller.updateBookingHistorySelectedIndex(index!);
              controller.getBookingHistory(
                controller.bookingHistoryStatus[index!],
                1,
              );
            },
    );
  }
}
