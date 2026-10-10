import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';


class BookingEditScreen extends StatefulWidget {
  final bool isSubBooking;
  const BookingEditScreen({super.key, required this.isSubBooking}) ;
  @override
  State<BookingEditScreen> createState() => _BookingEditScreenState();

}

class _BookingEditScreenState extends State<BookingEditScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<BookingEditController>().initializedControllerValue(Get.find<BookingDetailsController>().bookingDetails?.bookingContent?.bookingDetailsContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kBackground,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<BookingEditController>(builder: (bookingEditController){

          final BookingDetailsContent? bookingDetails = Get.find<BookingDetailsController>().bookingDetails?.bookingContent?.bookingDetailsContent;
          final String readableId = bookingDetails?.readableId ?? '';
          final DateTime? schedule = bookingEditController.scheduleTime != null ? DateTime.tryParse(bookingEditController.scheduleTime!) : null;
          final bool canAddService = !(bookingEditController.cartList.length == 1 && bookingEditController.cartList[0].variantKey == null);

          return Column( children: [

            PageHeader(
              title: 'update_booking_title'.tr,
              subtitle: (readableId.isNotEmpty && readableId != 'null') ? '#$readableId' : '',
              onBack: (){
                if(Navigator.canPop(context)){
                  Get.back();
                }else{
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                }
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [

                  const PaymentStatusButton(),
                  const SizedBox(height: 20),

                  Text('booking_status'.tr, style: robotoMedium.copyWith(
                    fontSize: 12, fontWeight: FontWeight.w600, color: context.kMutedForeground,
                  )),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: context.kCard,
                      borderRadius: BorderRadius.circular(kRadiusMd),
                      border: Border.all(color: context.kInputBorder, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        dropdownColor: context.kCard,
                        borderRadius: BorderRadius.circular(kRadiusSm),
                        elevation: 2,
                        hint: Text(bookingEditController.selectedBookingStatus == '' ?
                        "select_booking_status".tr : bookingEditController.selectedBookingStatus.tr,
                          style: robotoRegular.copyWith(
                              fontSize: 14,
                              color: bookingEditController.selectedBookingStatus == '' ?
                              context.kMutedForeground : context.kForeground
                          ),
                        ),
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.kMutedForeground, size: 20,),
                        items: bookingEditController.statusTypeList.map((String items) {
                          bool isDisabled = bookingDetails?.bookingStatus == "ongoing" &&
                              (items.toLowerCase() == "accepted" || items == 'canceled');
                          return DropdownMenuItem(
                            value: items,
                            enabled: !isDisabled,
                            child: Text(items.tr,
                              style: robotoRegular.copyWith(
                                fontSize: 14,
                                color: isDisabled ? context.kMutedForeground.withValues(alpha:0.4) : context.kForeground,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            bookingEditController.changeBookingStatusDropDownValue(newValue);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(children: [
                    Expanded(child: _scheduleBox(
                      context: context,
                      label: 'service_date'.tr,
                      icon: Icons.calendar_today_outlined,
                      value: schedule != null ? DateConverter.dateStringMonthYear(schedule) : '--',
                      onTap: () => bookingEditController.selectDate(),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _scheduleBox(
                      context: context,
                      label: 'time_label'.tr,
                      icon: Icons.access_time_rounded,
                      value: schedule != null ? DateConverter.convertStringTimeToDate(schedule) : '--',
                      onTap: () => bookingEditController.selectDate(),
                    )),
                  ]),

                  const SizedBox(height: 20),

                  SectionHeader(
                    title: 'services'.tr,
                    trailing: widget.isSubBooking ? null : Opacity(
                      opacity: canAddService ? 1 : 0.4,
                      child: KButton(
                        label: 'add'.tr,
                        icon: Icons.add_rounded,
                        outline: true,
                        height: 32,
                        expanded: false,
                        onTap: canAddService ? (){
                          showModalBottomSheet(
                              useRootNavigator: true,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              context: context, builder: (context) => SubcategoryServiceView (
                                categoryId: "", subCategoryId: '', serviceList: bookingEditController.serviceList??[],)
                          );
                        } : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Column(children: [
                    for (int index = 0; index < bookingEditController.cartList.length; index++) ...[
                      CartServiceWidget(
                        cart: bookingEditController.cartList[index],
                        cartIndex: index,
                        disableQuantityButton: !canAddService,
                        isSubBooking: widget.isSubBooking,
                      ),
                      if (index != bookingEditController.cartList.length - 1) const SizedBox(height: 12),
                    ],
                  ]),

                  const SizedBox(height: 100),

                ],),
              ),
            ),

            Padding( padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SafeArea(
                top: false,
                child: CustomButton(
                  btnTxt: "update_booking_btn".tr,
                  isLoading: bookingEditController.statusUpdateLoading,
                  onPressed: (){
                    bookingEditController.updateBooking(
                      bookingId : bookingDetails?.subBooking?.id ?? bookingDetails?.id,
                      subBookingId: bookingDetails?.id,
                      zoneId : bookingDetails?.zoneId ?? bookingDetails?.subBooking?.zoneId ?? "",
                      isSubBooking: widget.isSubBooking,
                    );
                  },
                ),
              ),
            )
          ]);
        }),
      ),

    );
  }

  Widget _scheduleBox({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.kCard,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: context.kInputBorder, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: robotoRegular.copyWith(fontSize: 11, color: context.kMutedForeground)),
              const SizedBox(height: 2),
              Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
                style: robotoMedium.copyWith(fontSize: 13, color: context.kForeground)),
            ]),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: context.kMutedForeground),
        ]),
      ),
    );
  }
}
