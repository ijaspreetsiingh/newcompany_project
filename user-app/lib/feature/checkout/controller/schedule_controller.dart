
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:intl/intl.dart';

enum ScheduleType {asap, schedule}

class ScheduleController extends GetxController implements GetxService{

  final ScheduleRepo scheduleRepo;
  ScheduleController({required this.scheduleRepo});


  ServiceType _selectedServiceType = ServiceType.regular;
  ServiceType get selectedServiceType => _selectedServiceType;

  int _scheduleDaysCount = 1;
  int get scheduleDaysCount => _scheduleDaysCount;


  /// Regular Booking ///

  ScheduleType _selectedScheduleType = ScheduleType.asap;
  ScheduleType get selectedScheduleType => _selectedScheduleType;

  ScheduleType? _inttialSelectedScheduleType;
  ScheduleType? get inttialSelectedScheduleType => _inttialSelectedScheduleType;

  String selectedDate =   DateFormat('yyyy-MM-dd').format(DateTime.now());
  String selectedTime = DateFormat('HH:mm:ss').format(DateTime.now().add(const Duration(minutes: 2)));

  String? scheduleTime;


  /// Repeat Booking /////

  RepeatBookingType _selectedRepeatBookingType = RepeatBookingType.daily;
  RepeatBookingType get selectedRepeatBookingType => _selectedRepeatBookingType;

  // Daily Repeat Booking
  DateTimeRange? _pickedDailyRepeatBookingDateRange;
  DateTimeRange? get pickedDailyRepeatBookingDateRange => _pickedDailyRepeatBookingDateRange;
  set updateDailyRepeatBookingDateRange(DateTimeRange? dateRange) => _pickedDailyRepeatBookingDateRange = dateRange;

  TimeOfDay? _pickedDailyRepeatTime;
  TimeOfDay? get pickedDailyRepeatTime => _pickedDailyRepeatTime;
  set updatePickedDailyRepeatTime(TimeOfDay? time) => _pickedDailyRepeatTime = time;


  // Weekly Repeat Booking
  DateTimeRange? _finalPickedWeeklyRepeatBookingDateRange;
  DateTimeRange? get pickedWeeklyRepeatBookingDateRange => _finalPickedWeeklyRepeatBookingDateRange;

  DateTimeRange? _inttialPickedWeeklyRepeatBookingDateRange;
  DateTimeRange? get inttialPickedWeeklyRepeatBookingDateRange => _inttialPickedWeeklyRepeatBookingDateRange;
  set updateinttialWeeklyRepeatBookingDateRange(DateTimeRange? dateRange) => _inttialPickedWeeklyRepeatBookingDateRange = dateRange;

  TimeOfDay? _pickedWeeklyRepeatTime;
  TimeOfDay? get pickedWeeklyRepeatTime => _pickedWeeklyRepeatTime;
  set updatePickedWeeklyRepeatTime(TimeOfDay? time) => _pickedWeeklyRepeatTime = time;

  bool _isFinalRepeatWeeklyBooking = false;
  bool get isFinalRepeatWeeklyBooking => _isFinalRepeatWeeklyBooking;

  bool _isinttialRepeatWeeklyBooking = false;
  bool get isinttialRepeatWeeklyBooking => _isinttialRepeatWeeklyBooking;


  List<String> daysList = ['saturday', "sunday", "monday", "tuesday", "wednesday", "thursday", "friday"];
  List<bool> finalDaysCheckList = [false, false, false, false, false, false, false];
  List<bool> inttialDaysCheckList = [false, false, false, false, false, false, false];


  // Custom Repeat Booking
  List<DateTime>  _pickedCustomRepeatBookingDateTimeList = [];
  List<DateTime>  get pickedCustomRepeatBookingDateTimeList => _pickedCustomRepeatBookingDateTimeList;

  List<DateTime>  _pickedinttialCustomRepeatBookingDateTimeList = [];
  List<DateTime>  get pickedinttialCustomRepeatBookingDateTimeList => _pickedinttialCustomRepeatBookingDateTimeList;
  set updateinttialCustomRepeatBookingDateRange(List<DateTime>  dateList) => _pickedinttialCustomRepeatBookingDateTimeList = dateList;



  void buildSchedule({bool shouldUpdate = true, required ScheduleType scheduleType, String? schedule}){

    if(schedule != null){
      _selectedScheduleType = ScheduleType.schedule;
      scheduleTime = schedule;
    }else if(scheduleType == ScheduleType.asap || _inttialSelectedScheduleType == ScheduleType.asap){
      _selectedScheduleType = ScheduleType.asap;
      _inttialSelectedScheduleType = ScheduleType.asap;
     scheduleTime = "${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${DateFormat('HH:mm:ss').format(DateTime.now().add(const Duration(minutes: 2)))}";
   }else{
      _selectedScheduleType = ScheduleType.schedule;
     scheduleTime = "$selectedDate $selectedTime";
   }
    if(shouldUpdate){
      update();
    }
  }

  void updateScheduleType({bool shouldUpdate = true, required ScheduleType scheduleType}){

    if(scheduleType == ScheduleType.asap){
      _inttialSelectedScheduleType= ScheduleType.asap;
    }else{
      _inttialSelectedScheduleType = ScheduleType.schedule;
    }
    if(shouldUpdate){
      update();
    }
  }

  DateTime? getSelectedDateTime(){
     return _selectedScheduleType == ScheduleType.schedule &&  scheduleTime !=null ? DateFormat('yyyy-MM-dd HH:mm:ss').parse(scheduleTime!) : null;
  }

  String? checkValidityOfTimeRestriction( AdvanceBooking advanceBooking){

    Duration  difference = DateConverter.dateTimeStringToDate("$selectedDate $selectedTime").difference(DateTime.now());

    if(advanceBooking.advancedBookingRestrictionType == "day" && difference.inDays < advanceBooking.advancedBookingRestrictionValue!){
      return "${'you_can_not_select_schedule_before'.tr} ${DateConverter.dateMonthYearTimeTwentyFourFormat(DateTime.now().add(Duration(days: advanceBooking.advancedBookingRestrictionValue!)))}";
    }else if (advanceBooking.advancedBookingRestrictionType == "hour" && difference.inHours < advanceBooking.advancedBookingRestrictionValue!){
      return "${'you_can_not_select_schedule_before'.tr} ${DateConverter.dateMonthYearTimeTwentyFourFormat(DateTime.now().add(Duration(hours: advanceBooking.advancedBookingRestrictionValue!)))}";
    }else{
      return null;
    }

  }

  void resetSchedule(){
    if(_selectedScheduleType == ScheduleType.schedule && scheduleTime != null){
      _inttialSelectedScheduleType = ScheduleType.schedule;
      return;
    }
    if(Get.find<SplashController>().configModel.content?.instantBooking == 1){
      _selectedScheduleType = ScheduleType.asap;
      _inttialSelectedScheduleType = ScheduleType.asap;
      scheduleTime = "${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${DateFormat('HH:mm:ss').format(DateTime.now().add(const Duration(minutes: 2)))}";
    }else{
      _selectedScheduleType = ScheduleType.schedule;
      scheduleTime = null;
    }
  }


  void setinttialScheduleValue(){
    if(_selectedScheduleType == ScheduleType.asap){
      _inttialSelectedScheduleType = ScheduleType.asap;
    }
  }

  void updateSelectedDate(String? date){
    if(date!=null){
      scheduleTime = date;
    }else{
     scheduleTime = null;
    }
  }

  Future<void> updatePostInformation(String postId,String scheduleTime) async {
    Response response = await scheduleRepo.changePostScheduleTime(postId,scheduleTime);

    if(response.statusCode==200 && response.body['response_code']=="default_update_200"){
      customSnackBar("service_schedule_updated_successfully".tr,type : ToasterMessageType.success);
    }
  }

  void removeinttialPickedCustomRepeatBookingDate ({required int index}){
    _pickedinttialCustomRepeatBookingDateTimeList.removeAt(index);
  }

  void removePickedCustomRepeatBookingDate ({required int index}){
    _pickedCustomRepeatBookingDateTimeList.removeAt(index);
  }


  void updateSelectedRepeatBookingType({RepeatBookingType? type}){
    if(type !=null){
      _selectedRepeatBookingType = type;
      update();
    }else{
      _selectedRepeatBookingType = RepeatBookingType.daily;
    }
  }

  void toggleDaysCheckedValue(int index) {
    inttialDaysCheckList[index] = !inttialDaysCheckList[index];
    update();
  }

  void updateWeeklyRepeatBookingStatus({bool shouldUpdate = true}){
    _inttialPickedWeeklyRepeatBookingDateRange = null;
    _isinttialRepeatWeeklyBooking = !_isinttialRepeatWeeklyBooking;
    if(shouldUpdate){
      update();
    }
  }

  void updateSelectedBookingType ({ServiceType? type}){
    if(type !=null){
      _selectedServiceType = type;
      update();
    }else{
      _selectedServiceType = ServiceType.regular;
    }
  }

  List<String> getWeeklyPickedDays() {
    List<String> pickedDays = [];
    for (int index = 0; index < finalDaysCheckList.length; index++) {
      if (finalDaysCheckList[index]) {
        pickedDays.add(daysList[index]);
      }
    }
    return pickedDays;
  }

  List<String> getinttialWeeklyPickedDays() {
    List<String> pickedDays = [];
    for (int index = 0; index < inttialDaysCheckList.length; index++) {
      if (inttialDaysCheckList[index]) {
        pickedDays.add(daysList[index]);
      }
    }
    return pickedDays;
  }


  void updateCustomRepeatBookingDateTime({required int index, required DateTime dateTime}){
    pickedinttialCustomRepeatBookingDateTimeList[index] = dateTime;
    update();
  }

  void resetScheduleData({RepeatBookingType? repeatBookingType, bool shouldUpdate = true}){

    if(repeatBookingType == RepeatBookingType.daily){
      _finalPickedWeeklyRepeatBookingDateRange = null;
      _pickedCustomRepeatBookingDateTimeList = [];
      _pickedDailyRepeatTime = null;
      _pickedWeeklyRepeatTime = null;
      finalDaysCheckList = [false, false, false, false, false, false, false];
      _isFinalRepeatWeeklyBooking = false;

    }else if(repeatBookingType == RepeatBookingType.weekly){
      _pickedDailyRepeatBookingDateRange = null;
      _pickedCustomRepeatBookingDateTimeList = [];
      _pickedDailyRepeatTime = null;
    }else if (repeatBookingType == RepeatBookingType.custom){
      _pickedDailyRepeatBookingDateRange = null;
      _finalPickedWeeklyRepeatBookingDateRange = null;
      _pickedDailyRepeatTime = null;
      _pickedWeeklyRepeatTime = null;
      finalDaysCheckList = [false, false, false, false, false, false, false];
      _isFinalRepeatWeeklyBooking = false;
    }else{
      _pickedDailyRepeatBookingDateRange = null;
      _finalPickedWeeklyRepeatBookingDateRange = null;
      _pickedCustomRepeatBookingDateTimeList = [];
      _pickedDailyRepeatTime = null;
      _selectedRepeatBookingType = RepeatBookingType.daily;
      _isFinalRepeatWeeklyBooking = false;
      finalDaysCheckList = [false, false, false, false, false, false, false];
    }

    calculateScheduleCountDays(serviceType: repeatBookingType == null ? ServiceType.regular : ServiceType.repeat, repeatBookingType: repeatBookingType ?? RepeatBookingType.daily);

    if(shouldUpdate){
      update();
    }
  }

  void inttWeeklySelectedSchedule({bool isFirst = true}){
    if(isFirst){
      _isinttialRepeatWeeklyBooking =  _isFinalRepeatWeeklyBooking;
      inttialDaysCheckList.clear();
      inttialDaysCheckList.addAll(finalDaysCheckList);
      _inttialPickedWeeklyRepeatBookingDateRange = _finalPickedWeeklyRepeatBookingDateRange;
    }else{
      _isFinalRepeatWeeklyBooking = _isinttialRepeatWeeklyBooking;
      finalDaysCheckList.clear();
      finalDaysCheckList.addAll(inttialDaysCheckList);
      _finalPickedWeeklyRepeatBookingDateRange = _inttialPickedWeeklyRepeatBookingDateRange;
      update();
    }
  }

  void inttCustomSelectedSchedule({bool isFirst = true}){
    if(isFirst){
     _pickedinttialCustomRepeatBookingDateTimeList.clear();
     _pickedinttialCustomRepeatBookingDateTimeList.addAll(_pickedCustomRepeatBookingDateTimeList);
    }else{
      _pickedCustomRepeatBookingDateTimeList.clear();
      _pickedCustomRepeatBookingDateTimeList.addAll(_pickedinttialCustomRepeatBookingDateTimeList);
      update();
    }
  }

  void calculateScheduleCountDays ({ServiceType? serviceType, required RepeatBookingType repeatBookingType}){

    if(selectedServiceType == ServiceType.regular || serviceType == ServiceType.regular){
      _scheduleDaysCount = 1;
    }else{
      if(repeatBookingType == RepeatBookingType.daily){
        _scheduleDaysCount = CheckoutHelper.calculateDaysCountBetweenDateRange(_pickedDailyRepeatBookingDateRange);
      } else if(repeatBookingType == RepeatBookingType.weekly){
        _scheduleDaysCount = CheckoutHelper.calculateDaysCountBetweenDateRangeWithSpecificSelectedDay(_finalPickedWeeklyRepeatBookingDateRange, getWeeklyPickedDays());
      } else{
        _scheduleDaysCount = _pickedCustomRepeatBookingDateTimeList.length;
      }
    }
  }

}


