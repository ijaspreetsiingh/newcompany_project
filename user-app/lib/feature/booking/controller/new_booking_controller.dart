import 'package:get/get.dart';

class NewBookingController extends GetxController implements GetxService {
  DateTime selectedDate = DateTime.now();
  int workingHours = 1;
  String selectedTime = '09:00';
  String? selectedPromoCode;
  double discountAmount = 0.0;
  String? selectedAddress;
  double? selectedLatitude;
  double? selectedLongitude;

  void selectDate(DateTime date) {
    selectedDate = date;
    update();
  }

  void updateWorkingHours(int hours) {
    workingHours = hours;
    update();
  }

  void selectTime(String time) {
    selectedTime = time;
    update();
  }

  void selectPromoCode(String code) {
    selectedPromoCode = code;
    update();
  }

  void removePromoCode() {
    selectedPromoCode = null;
    discountAmount = 0.0;
    update();
  }

  void setAddress(String address, {double? lat, double? lng}) {
    selectedAddress = address;
    selectedLatitude = lat;
    selectedLongitude = lng;
    update();
  }

  void resetBookingData() {
    selectedDate = DateTime.now();
    workingHours = 1;
    selectedTime = '09:00';
    selectedPromoCode = null;
    discountAmount = 0.0;
    selectedAddress = null;
    selectedLatitude = null;
    selectedLongitude = null;
    update();
  }

  String getFormattedDateTime() {
    return '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} $selectedTime:00';
  }
}
