import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class BookingStatusDropdown extends StatelessWidget {
  const BookingStatusDropdown({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<BookingEditController>(builder: (bookingEditController){
      return Container(width: Get.width,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
            color: context.kCard,
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: Border.all(color: context.kInputBorder, width: 1)
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
              dropdownColor: context.kCard,
              borderRadius: BorderRadius.circular(kRadiusSm),
              elevation: 2,
              hint: Text(bookingEditController.selectedBookingStatus ==''?
              "select_identity_type".tr : bookingEditController.selectedBookingStatus.tr,
                style: robotoRegular.copyWith(
                    fontSize: 14,
                    color: bookingEditController.selectedBookingStatus ==''?
                    context.kMutedForeground :
                    context.kForeground
                ),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.kMutedForeground, size: 20,),
              items: bookingEditController.statusTypeList.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(items.tr,
                    style: robotoRegular.copyWith(
                      fontSize: 14,
                      color: context.kForeground,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) => bookingEditController.changeBookingStatusDropDownValue(newValue!)
          ),
        ),
      );
    });
  }
}
