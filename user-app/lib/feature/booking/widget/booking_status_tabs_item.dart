import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class BookingStatusTabItem extends GetView<ServiceBookingController> {
  const BookingStatusTabItem({super.key, required this.title}) ;
  final String title;

  @override
  Widget build(BuildContext context) {
    /// nest. chip : selected = black fill, unselected = hatrline border
    final bool isSelected = controller.selectedBookingStatus.name == title;
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        border: isSelected ? null : Border.all(
          color: Theme.of(context).primaryColorLight.withValues(alpha: Get.isDarkMode ? 0.6 : 1),
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min ,children: [
        Image.asset(title.png, height: 20, width: 18,
          color: isSelected
              ? (Get.isDarkMode ? Colors.black : Colors.white)
              : Theme.of(context).textTheme.bodyLarge!.color),
        const SizedBox(width: 5,),
        Text( title.tr,
          textAlign: TextAlign.center,
          style:robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: isSelected
                ? (Get.isDarkMode ? Colors.black : Colors.white)
                : Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),

      ],),
    );
  }
}

extension on String {
  String get png => 'assets/images/$this.png';
}

