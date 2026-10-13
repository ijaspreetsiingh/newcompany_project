import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfessionalDateTimePicker extends StatefulWidget {
  const ProfessionalDateTimePicker({super.key});

  @override
  State<ProfessionalDateTimePicker> createState() => _ProfessionalDateTimePickerState();
}

class _ProfessionalDateTimePickerState extends State<ProfessionalDateTimePicker> {
  late ScrollController _dateScrollController;
  List<DateTime> dateList = [];

  @override
  void initState() {
    super.initState();
    _dateScrollController = ScrollController();
    _generateDateList();
  }

  void _generateDateList() {
    dateList.clear();
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      dateList.add(today.add(Duration(days: i)));
    }
  }

  String _formatDateFull(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  String _formatDateDay(DateTime date) {
    return DateFormat('EEEE').format(date).substring(0, 3);
  }

  String _formatDateNum(DateTime date) {
    return DateFormat('d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final secondaryColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final cardBgColor = isDark ? const Color(0xFF262626) : const Color(0xFFF8F8F8);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);
    final accentColor = Theme.of(context).colorScheme.primary;

    return GetBuilder<ScheduleController>(builder: (scheduleController) {
      return Container(
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          color: bgColor,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== HEADER =====
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: secondaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'when_do_you_need_service'.tr,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'select_your_preferred_date_and_time'.tr,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // ===== ASAP BUTTON =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () {
                    scheduleController.updateScheduleType(scheduleType: ScheduleType.asap);
                    setState(() {});
                  },
                  child: Container(
                    width: Get.width,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: scheduleController.inttialSelectedScheduleType == ScheduleType.asap
                            ? accentColor
                            : borderColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: scheduleController.inttialSelectedScheduleType == ScheduleType.asap
                          ? accentColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flash_on_rounded,
                          color: scheduleController.inttialSelectedScheduleType == ScheduleType.asap
                              ? accentColor
                              : secondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'as_soon_as_possible'.tr,
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              'typical_2_hour_wait'.tr,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 20),

              // ===== DATE SELECTION TITLE =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'choose_a_date'.tr,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ===== HORIZONTAL SCROLLABLE DATE PICKER (30+ DATES) =====
              SizedBox(
                height: 100,
                child: ListView.builder(
                  controller: _dateScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: dateList.length,
                  itemBuilder: (context, index) {
                    final date = dateList[index];
                    final dateStr = DateFormat('yyyy-MM-dd').format(date);
                    final isSelected = scheduleController.selectedDate == dateStr;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () {
                          scheduleController.selectedDate = dateStr;
                          scheduleController.updateScheduleType(scheduleType: ScheduleType.schedule);
                          setState(() {});
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 70,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      accentColor,
                                      accentColor.withValues(alpha: 0.8),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : cardBgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: !isSelected
                                ? Border.all(color: borderColor, width: 1)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: accentColor.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatDateDay(date),
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDateNum(date),
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM').format(date),
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white : secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ===== TIME SELECTION TITLE =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'pick_a_time'.tr,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ===== TIME SELECTION GRID (PROFESSIONAL) =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GetBuilder<ScheduleController>(builder: (controller) {
                  final timeSlots = _generateTimeSlots();
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final time = timeSlots[index];
                      final isSelected = controller.selectedTime == time;

                      return InkWell(
                        onTap: () {
                          controller.selectedTime = time;
                          setState(() {});
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      accentColor,
                                      accentColor.withValues(alpha: 0.8),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : cardBgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: !isSelected
                                ? Border.all(color: borderColor, width: 1)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: accentColor.withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              time,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : primaryColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 24),

              // ===== SELECTED SUMMARY =====
              if (scheduleController.selectedDate != null ||
                  scheduleController.inttialSelectedScheduleType == ScheduleType.asap)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: accentColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                scheduleController.inttialSelectedScheduleType == ScheduleType.asap
                                    ? 'ASAP'.tr
                                    : 'Scheduled',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                              if (scheduleController.selectedDate != null)
                                Text(
                                  '${_formatDateFull(DateFormat('yyyy-MM-dd').parse(scheduleController.selectedDate!))} at ${scheduleController.selectedTime ?? 'TBD'}',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: secondaryColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // ===== ACTION BUTTONS =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'cancel'.tr.toUpperCase(),
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor,
                            accentColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () {
                          ConfigModel config =
                              Get.find<SplashController>().configModel;

                          if (scheduleController.inttialSelectedScheduleType ==
                              null) {
                            customSnackBar(
                              'select_your_preferable_booking_time'.tr,
                              showDefaultSnackBar: false,
                            );
                          } else if (config.content!.advanceBooking != null &&
                              config.content?.scheduleBookingTimeRestriction ==
                                  1 &&
                              scheduleController.inttialSelectedScheduleType !=
                                  ScheduleType.asap) {
                            if (scheduleController.checkValidityOfTimeRestriction(
                                    config.content!.advanceBooking!) !=
                                null) {
                              customSnackBar(
                                scheduleController.checkValidityOfTimeRestriction(
                                    config.content!.advanceBooking!),
                                showDefaultSnackBar: false,
                              );
                            } else {
                              scheduleController.buildSchedule(
                                scheduleType: ScheduleType.schedule,
                              );
                              Get.back();
                            }
                          } else {
                            scheduleController.buildSchedule(
                              scheduleType: scheduleController
                                      .inttialSelectedScheduleType ??
                                  ScheduleType.asap,
                            );
                            Get.back();
                          }
                        },
                        child: Text(
                          'done'.tr.toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  List<String> _generateTimeSlots() {
    final slots = <String>[];
    final is24Hour = Get.find<SplashController>().configModel.content?.timeFormat == '24';

    if (is24Hour) {
      for (int i = 0; i < 24; i++) {
        slots.add('${i.toString().padLeft(2, '0')}:00');
      }
    } else {
      for (int i = 0; i < 12; i++) {
        slots.add('${i == 0 ? 12 : i}:00 AM');
      }
      for (int i = 0; i < 12; i++) {
        slots.add('${i == 0 ? 12 : i}:00 PM');
      }
    }

    return slots;
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }
}
