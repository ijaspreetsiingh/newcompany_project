import 'package:jdds/common/models/popup_menu_model.dart';
import 'package:jdds/feature/checkout/widget/payment_section/incomplete_offline_payment_dialog.dart';
import 'package:jdds/feature/home/widget/referal_welcome_dialog.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';


enum BookingDetailsTabs {bookingDetails, status}
class BookingDetailsController extends GetxController implements GetxService{
  BookingDetailsRepo bookingDetailsRepo;
  BookingDetailsController({required this.bookingDetailsRepo});

  BookingDetailsTabs _selectedDetailsTabs = BookingDetailsTabs.bookingDetails;
  BookingDetailsTabs get selectedBookingStatus =>_selectedDetailsTabs;


  final bookingIdController = TextEditingController();
  final phoneController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isCancelling = false;
  bool get isCancelling => _isCancelling;

  BookingDetailsContent? _bookingDetailsContent;
  BookingDetailsContent? get bookingDetailsContent => _bookingDetailsContent;

  BookingDetailsContent? _subBookingDetailsContent;
  BookingDetailsContent? get subBookingDetailsContent => _subBookingDetailsContent;

  DigitalPaymentMethod? _selectedDigitalPaymentMethod;
  DigitalPaymentMethod ? get selectedDigitalPaymentMethod => _selectedDigitalPaymentMethod;


  void updateBookingStatusTabs(BookingDetailsTabs bookingDetailsTabs){
    _selectedDetailsTabs = bookingDetailsTabs;
    update();
  }


  Future<void> bookingCancel({required String bookingId, bool fromListScreen = false,})async{
    if (bookingId.isEmpty || _isCancelling) return;
    _isCancelling = true;
    update();
    try {
      final Response response =
          await bookingDetailsRepo.bookingCancel(bookingID: bookingId);
      final body = response.body is Map ? response.body as Map : const {};
      final responseCode = body['response_code'];

      if (response.statusCode == 200 &&
          responseCode == 'status_update_success_200') {
        if (!fromListScreen) {
          await _reloadRegularBookingAfterCancel(bookingId);
        }
        await _refreshBookingList();
        customSnackBar(
          'booking_cancelled_successfully'.tr,
          type: ToasterMessageType.success,
        );
      } else if (response.statusCode == 1) {
        // A timeout does not tell us whether the server committed the cancel.
        // Re-fetch before reporting failure so a successful server-side cancel
        // is reflected in both the detail and booking list.
        final bool wasCancelled =
            await _reloadRegularBookingAfterCancel(bookingId);
        if (wasCancelled) {
          await _refreshBookingList();
          customSnackBar(
            'booking_cancelled_successfully'.tr,
            type: ToasterMessageType.success,
          );
        } else {
          ApiChecker.checkApi(response);
        }
      } else if (response.statusCode == 200 &&
          (responseCode == 'booking_already_accepted_200' ||
              responseCode == 'booking_already_ongoing_200' ||
              responseCode == 'booking_already_completed_200')) {
        if (!fromListScreen) {
          await _reloadRegularBookingAfterCancel(bookingId);
        }
        await _refreshBookingList();
        customSnackBar('${body['message'] ?? ''}');
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('booking cancellation failed: $e');
      }
      final bool wasCancelled =
          await _reloadRegularBookingAfterCancel(bookingId);
      if (wasCancelled) {
        await _refreshBookingList();
        customSnackBar(
          'booking_cancelled_successfully'.tr,
          type: ToasterMessageType.success,
        );
      } else {
        customSnackBar('error_loading'.tr);
      }
    } finally {
      _isCancelling = false;
      update();
    }
  }

  Future<void> subBookingCancel({required String subBookingId})async{
    if (subBookingId.isEmpty || _isCancelling) return;
    _isCancelling = true;
    update();
    try {
      final Response response =
          await bookingDetailsRepo.subBookingCancel(bookingID: subBookingId);
      if (response.statusCode == 200) {
        await _reloadSubBookingAfterCancel(subBookingId);
        final parentBookingId = _bookingDetailsContent?.id;
        if (parentBookingId != null && parentBookingId.isNotEmpty) {
          await getBookingDetails(bookingId: parentBookingId, reload: false);
        }
        await _refreshBookingList();
        customSnackBar(
          'booking_cancelled_successfully'.tr,
          type: ToasterMessageType.success,
        );
      } else if (response.statusCode == 1) {
        final bool wasCancelled =
            await _reloadSubBookingAfterCancel(subBookingId);
        if (wasCancelled) {
          await _refreshBookingList();
          customSnackBar(
            'booking_cancelled_successfully'.tr,
            type: ToasterMessageType.success,
          );
        } else {
          ApiChecker.checkApi(response);
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('sub-booking cancellation failed: $e');
      }
      final bool wasCancelled =
          await _reloadSubBookingAfterCancel(subBookingId);
      if (wasCancelled) {
        await _refreshBookingList();
        customSnackBar(
          'booking_cancelled_successfully'.tr,
          type: ToasterMessageType.success,
        );
      } else {
        customSnackBar('error_loading'.tr);
      }
    } finally {
      _isCancelling = false;
      update();
    }
  }

  Future<bool> _reloadRegularBookingAfterCancel(String bookingId) async {
    try {
      final Response response =
          await bookingDetailsRepo.getBookingDetails(bookingID: bookingId);
      final body = response.body;
      if (response.statusCode != 200 ||
          body is! Map ||
          body['content'] is! Map) {
        return false;
      }

      final latest = BookingDetailsContent.fromJson(
        Map<String, dynamic>.from(body['content'] as Map),
      );
      if (_bookingDetailsContent == null ||
          _bookingDetailsContent?.id == bookingId) {
        _bookingDetailsContent = latest;
        update();
      }
      final status = latest.bookingStatus?.trim().toLowerCase();
      return status == 'canceled' || status == 'cancelled';
    } catch (_) {
      return false;
    }
  }

  Future<bool> _reloadSubBookingAfterCancel(String subBookingId) async {
    try {
      final Response response =
          await bookingDetailsRepo.getSubBookingDetails(bookingID: subBookingId);
      final body = response.body;
      if (response.statusCode != 200 ||
          body is! Map ||
          body['content'] is! Map) {
        return false;
      }

      final latest = BookingDetailsContent.fromJson(
        Map<String, dynamic>.from(body['content'] as Map),
      );
      _subBookingDetailsContent = latest;
      update();
      final status = latest.bookingStatus?.trim().toLowerCase();
      return status == 'canceled' || status == 'cancelled';
    } catch (_) {
      return false;
    }
  }

  Future<void> _refreshBookingList() async {
    if (!Get.isRegistered<ServiceBookingController>()) return;
    final controller = Get.find<ServiceBookingController>();
    await controller.getAllBookingService(
      offset: 1,
      bookingStatus: controller.selectedBookingStatusApiValue,
      isFromPagination: false,
      serviceType: controller.selectedServiceType.name,
    );
  }

  Future<void> getBookingDetails({required String bookingId, bool reload = true})async{
    if(reload){
      _bookingDetailsContent = null;
    }
    Response response = await bookingDetailsRepo.getBookingDetails(bookingID: bookingId);
    if(response.statusCode == 200){
      _bookingDetailsContent = BookingDetailsContent.fromJson(response.body['content']);
      update();
      getRecheckStatus(bookingId: bookingId);
    } else {
      ApiChecker.checkApi(response);
    }
  }

  // --------------------- RECHECK (15 din ka window) ---------------------
  bool _isRequestingRecheck = false;
  bool get isRequestingRecheck => _isRequestingRecheck;

  bool _canRequestRecheck = false;
  bool get canRequestRecheck => _canRequestRecheck;

  int _recheckDaysLeft = 0;
  int get recheckDaysLeft => _recheckDaysLeft;

  Map<String, dynamic>? _recheckInfo;
  Map<String, dynamic>? get recheckInfo => _recheckInfo;

  String get recheckStatus {
    final dynamic status = _recheckInfo?['status'];
    return status is String ? status : '';
  }

  Future<void> getRecheckStatus({required String bookingId}) async {
    try {
      final Response response = await bookingDetailsRepo.getRecheckStatus(
        bookingID: bookingId,
      );
      if (response.statusCode == 200 &&
          response.body is Map &&
          response.body['content'] is Map) {
        final Map<String, dynamic> content = Map<String, dynamic>.from(
          response.body['content'] as Map,
        );
        _recheckInfo = content['recheck'] is Map
            ? Map<String, dynamic>.from(content['recheck'] as Map)
            : null;
        _canRequestRecheck = content['can_request'] == true;
        _recheckDaysLeft = (content['window_ends_in_days'] is num)
            ? (content['window_ends_in_days'] as num).toInt()
            : 0;
        update();
      }
    } catch (_) {
      // recheck status optional hai — ignore karo
    }
  }

  Future<void> requestRecheck({
    required String bookingId,
    String reason = '',
  }) async {
    if (bookingId.isEmpty || _isRequestingRecheck) return;
    _isRequestingRecheck = true;
    update();
    try {
      final Response response = await bookingDetailsRepo.requestRecheck(
        bookingID: bookingId,
        reason: reason,
      );
      final body = response.body is Map ? response.body as Map : const {};

      if (response.statusCode == 200 &&
          body['response_code'] == 'recheck_request_success_200') {
        customSnackBar('recheck_requested_successfully'.tr, type: ToasterMessageType.success);
        await getRecheckStatus(bookingId: bookingId);
      } else {
        customSnackBar(
          (body['message'] ?? 'error_loading').toString(),
          type: ToasterMessageType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('recheck request failed: $e');
      }
      customSnackBar('error_loading'.tr, type: ToasterMessageType.error);
    } finally {
      _isRequestingRecheck = false;
      update();
    }
  }
  // -------------------------------------------------------------------------

  Future<void> getSubBookingDetails({required String bookingId})async{

    _subBookingDetailsContent = null;
    Response response = await bookingDetailsRepo.getSubBookingDetails(bookingID: bookingId);
    if(response.statusCode == 200){
      _subBookingDetailsContent = BookingDetailsContent.fromJson(response.body['content']);

    } else {
      ApiChecker.checkApi(response);
    }
    update();

  }


  Future<void> trackBookingDetails(String bookingReadableId, String phone, {bool reload = false}) async {
    if(reload){
      _isLoading = true;
      update();
    }
    if( reload || _bookingDetailsContent == null){

      Response response = await bookingDetailsRepo.trackBookingDetails(bookingID: bookingReadableId, phoneNUmber: phone);
      if(response.statusCode == 200){
        _bookingDetailsContent = BookingDetailsContent.fromJson(response.body['content']);
        update();
      }else{
        _bookingDetailsContent = null;
        _isLoading = false;
        update();
      }
    }
    if(reload){
      _isLoading = false;
      update();
    }

  }

  void updateSelectedDigitalPayment({DigitalPaymentMethod? value, bool shouldUpdate = true}){
    _selectedDigitalPaymentMethod = value;
    if(shouldUpdate){
      update();
    }
  }

  void resetBookingDetailsValue({bool shouldUpdate = false, bool resetBookingDetails = false}){
    _selectedDetailsTabs = BookingDetailsTabs.bookingDetails;
    _subBookingDetailsContent = null;
    if(resetBookingDetails){
      _bookingDetailsContent = null;
    }
  }


  void resetTrackingData({bool shouldUpdate = true}){
    bookingIdController.clear();
    phoneController.clear();
    _bookingDetailsContent = null;

    if(shouldUpdate){
      update();
    }
  }

  void manageDialog(){

    var userData = Get.find<UserController>().userInfoModel;
    if(Get.find<AuthController>().isLoggedIn() && userData !=null && userData.lastIncompleteOfflineBooking != null && getLastIncompleteOfflineBookingId() != userData.lastIncompleteOfflineBooking?.id){
     if(Get.isDialogOpen == false){
       if(ResponsiveHelper.isDesktop(Get.context)){
         Get.dialog(Center(child: IncompleteOfflinePaymentDialog(booking: Get.find<UserController>().userInfoModel?.lastIncompleteOfflineBooking,))).then((value){
           setLastIncompleteOfflineBookingId(userData.lastIncompleteOfflineBooking?.id ?? "");
         });
       }else{
         showModalBottomSheet(context: Get.context!,
           builder: (_){
             return  IncompleteOfflinePaymentDialog(booking: Get.find<UserController>().userInfoModel?.lastIncompleteOfflineBooking,);
           },
           backgroundColor: Colors.transparent,
         ).then((value){
           setLastIncompleteOfflineBookingId(userData.lastIncompleteOfflineBooking?.id ?? "");
         });
       }
     }
    }

    if(Get.find<ServiceController>().allService !=null && Get.find<ServiceController>().allService!.isNotEmpty && (Get.currentRoute.contains(RouteHelper.home) || Get.currentRoute.contains("/?page=home"))){
      if(Get.find<UserController>().showReferWelcomeDialog() && Get.find<AuthController>().getIsShowReferralBottomSheet() == true){
        Future.delayed(const Duration(microseconds: 500), () {
          showModalBottomSheet(
            isDismissible: false,
            context: Get.context!,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) => const ReferWelcomeDialog(),
            backgroundColor: Colors.transparent,
          );
        });
      }
    }
  }

  Future<void>  setLastIncompleteOfflineBookingId(String bookingId) async {
    await  bookingDetailsRepo.setLastIncompleteOfflineBookingId(bookingId);
  }

  String getLastIncompleteOfflineBookingId() {
    return bookingDetailsRepo.getLastIncompleteOfflineBookingId();
  }

  List<PopupMenuModel> getPopupMenuList(String status) {
    if (status == "pending") {
      return [
        PopupMenuModel(title: "download_invoice", icon: Icons.file_download_outlined),
        PopupMenuModel(title: "cancel", icon: Icons.cancel_outlined),
      ];
    } else if(status == "completed"){
      return [
        PopupMenuModel(title: "download_invoice", icon: Icons.file_download_outlined),
        PopupMenuModel(title: "review", icon: Icons.reviews_outlined),
      ];
    }
    return [];
  }

  List<PopupMenuModel> getPServiceLogMenuList({required String status,  bool nextService = false}) {

    if (status == "pending") {
      return [
        PopupMenuModel(title: "download_invoice", icon: Icons.file_download_outlined),

      ];
    } else if (status == "accepted") {
      return [
        if(nextService) PopupMenuModel(title: "booking_details", icon: Icons.remove_red_eye),
        PopupMenuModel(title: "download_invoice", icon: Icons.file_download_outlined),
        if(!nextService) PopupMenuModel(title: "cancel", icon: Icons.cancel_outlined),
      ];
    }

    else if (status == "ongoing" || status == "completed" || status == "canceled") {
      return [
        PopupMenuModel(title: "booking_details", icon: Icons.remove_red_eye),
        PopupMenuModel(title: "download_invoice", icon: Icons.file_download_outlined),

      ];
    }
    return [];
  }

}


