import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class BookingRequestMenuItem extends GetView<BookingRequestController> {
  const BookingRequestMenuItem({super.key, required this.title,this.index, required this.bookingCount});
  final String title;
  final int? index;
  final BookingCount? bookingCount;

  @override
  Widget build(BuildContext context) {

    int? allBookingCount = (bookingCount?.pending??0) + (bookingCount?.accepted??0) + (bookingCount?.ongoing??0) + (bookingCount?.completed??0)+ (bookingCount?.canceled??0);

    final bool isActive = controller.currentIndex == index;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? InkColors.foreground : InkColors.card,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        border: Border.all(color: isActive ? Colors.transparent : InkColors.border),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [

          Text(title.tr,textAlign: TextAlign.center,
            style: robotoSemiBold.copyWith(
                fontSize: 12,
                height: 1.3,
                color: isActive ? InkColors.background : InkColors.mutedForeground
            ),
          ),

          if (bookingCount != null) ...[
            const SizedBox(width: 6),
            Text(
              title== "all" ? bookingCount == null ? "" :
              "${(allBookingCount)}" :
              title== "accepted" ? bookingCount?.accepted == null ? "" :
              "${bookingCount?.accepted}" :
              title== "ongoing" ?  bookingCount?.ongoing == null ? "":
              "${bookingCount?.ongoing}" :
              title== "completed" ? bookingCount?.completed == null ? "" :
              "${bookingCount?.completed}":
              title== "canceled" ? bookingCount?.canceled == null ? "" :
              "${bookingCount?.canceled}" :
              bookingCount?.pending == null ? "" :
              "${bookingCount?.pending}",

              style: robotoBold.copyWith(
                color: isActive ? InkColors.background : InkColors.mutedForeground,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
