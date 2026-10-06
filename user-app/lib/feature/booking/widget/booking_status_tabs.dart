import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:google_fonts/google_fonts.dart';

class   ServiceRequestSectionMenu extends SliverPersistentHeaderDelegate{
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);

    return GetBuilder<ServiceBookingController>(builder: (serviceBookingController){
      return Container(
        color: bgColor,
        child: Center(
          child: Container(
            margin: EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Container(
              height: double.infinity, width: Dimensions.webMaxWidth,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  height: 32,
                  child: ListView.builder(
                    itemCount: 4,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context,index){
                      return GetBuilder<ServiceBookingController>(builder: (controller){
                        const tabs = [BookingStatusTabs.all, BookingStatusTabs.ongoing, BookingStatusTabs.completed, BookingStatusTabs.cancelled];
                        final tab = tabs[index];
                        final isSelected = controller.selectedBookingStatus == tab;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: InkWell(child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isSelected ? primaryColor : Colors.transparent, width: 3))),
                            child: Center(child: Text(tab.name == 'cancelled' ? 'canceled'.tr : tab.name.tr,
                              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? primaryColor : mutedColor))),
                          ),
                            onTap: (){
                              controller.updateBookingStatusTabs(tab);
                            },
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  double get maxExtent => ResponsiveHelper.isDesktop(Get.context!)  ? 110 : 56;

  @override
  double get minExtent => ResponsiveHelper.isDesktop(Get.context!)  ? 110 : 56;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

}

