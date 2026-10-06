import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class BookingMenuItem extends GetView<BookingRequestController> {
  final String title;
  final int index;
  const BookingMenuItem({super.key, required this.title, required this.index});

  @override
  Widget build(BuildContext context) {
    final isActive = BooingListStatus.values.elementAt(index) == controller.bookingStatusState;

    return KFilterChip(
      label: title,
      selected: isActive,
      onTap: () => controller.updateBookingStatusState(
        BooingListStatus.values.elementAt(index),
      ),
    );
  }
}
