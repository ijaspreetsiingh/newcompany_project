import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class BookingRequestMenuBar extends StatefulWidget{
  const BookingRequestMenuBar({super.key});

  @override
  State<BookingRequestMenuBar> createState() => _BookingRequestMenuBarState();
}

class _BookingRequestMenuBarState extends State<BookingRequestMenuBar> {
  BookingRequestController controller   = Get.find();

  @override
  void initState() {
    super.initState();
    controller.menuScrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );
    Get.find<BookingRequestController>().menuScrollController!.scrollToIndex(controller.currentIndex, preferPosition: AutoScrollPosition.middle);
    controller.menuScrollController!.highlight(controller.currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingRequestController>(builder: (bookingRequestController){
      return Container(
        width: double.infinity,
        height: 44,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ListView.builder(
            controller: controller.menuScrollController,
            itemCount: 6,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context,index){
              return GetBuilder<BookingRequestController>(builder: (controller){
                return InkWell(
                  child: AutoScrollTag(
                    controller: controller.menuScrollController!,
                    key: ValueKey(index),
                    index: index,
                    child: BookingRequestMenuItem(
                      bookingCount: controller.bookingCount,
                      title: controller.bookingRequestStatusList[index].toLowerCase(),
                      index: index,
                    ),
                  ),
                  onTap: () async {
                    controller.updateBookingRequestIndex(index);
                    await controller.menuScrollController!.scrollToIndex(
                        index, preferPosition: AutoScrollPosition.middle,
                        duration: const Duration(milliseconds: 700)
                    );
                    await controller.menuScrollController!.highlight(index);
                  },
                );
              });
            }
        ),
      );
    });
  }
}
