import 'package:jdds/feature/create_post/widget/custom_date_time_picker.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceSchedule extends StatefulWidget {
  const ServiceSchedule({super.key}) ;

  @override
  State<ServiceSchedule> createState() => _ServiceScheduleState();
}

class _ServiceScheduleState extends State<ServiceSchedule> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF171717) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);
    final iconBgColor = isDark ? const Color(0xFF262626) : const Color(0xFFF6F6F6);

    return GetBuilder<CartController>(builder: (cartController){
      return GetBuilder<ScheduleController>(builder: (scheduleController){
        return  Column( crossAxisAlignment: CrossAxisAlignment.start, children: [

          Text("preferable_time".tr, style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          )),
          const SizedBox(height: 12,),

          Container(
            width: Get.width,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              color: bgColor,
            ),
            child: Row( children: [

              Container(
                height: 40, width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBgColor,
                ),
                child: Icon(Icons.calendar_today_outlined, size: 18,
                  color: primaryColor),
              ),
              const SizedBox(width: 12),

              Expanded( child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(
                  scheduleController.selectedScheduleType == ScheduleType.asap ?'ASAP'.tr :
                  scheduleController.selectedScheduleType == ScheduleType.schedule && scheduleController.scheduleTime != null ?
                  DateConverter.dateMonthYearTimeTwentyFourFormat(DateConverter.dateTimeStringToDate(scheduleController.scheduleTime!)) : "select_schedule_time".tr,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                if (scheduleController.selectedScheduleType == ScheduleType.asap)
                  Text('as_soon_as_possible'.tr, style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: mutedColor),
                  ),
              ])),

              InkWell( onTap: () {
                String? errorText = cartController.checkScheduleBookingAvailability();
                if( errorText !=null ){
                  customSnackBar(errorText.tr);
                }else{
                  showModalBottomSheet(backgroundColor: Colors.transparent, isScrollControlled: true, context: context, builder: (BuildContext context){
                    return const CustomDateTimePicker();
                  });
                }
              },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('change'.tr, style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: bgColor),
                  ),
                ),
              ),

            ]),
          ),

          const SizedBox(height: 16),

        ]);},
      );
    });
  }
}

