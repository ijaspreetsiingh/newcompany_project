import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class BookingHistorySectionMenu extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return GetBuilder<BookingRequestController>(
      builder: (bookingRequestController) {
        return Container(
          color: context.kBackground,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: bookingRequestController.bookingHistoryStatus.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return CategoryTabItem(
                  title: bookingRequestController.bookingHistoryStatus[index].toLowerCase().tr,
                  index: index,
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  double get maxExtent => 64;

  @override
  double get minExtent => 64;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
