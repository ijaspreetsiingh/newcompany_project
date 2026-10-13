import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';


class BookingDetailsController extends GetxController implements GetxService {
  final BookingDetailsRepo bookingDetailsRepo;
  BookingDetailsController({required this.bookingDetailsRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _otp = '';
  String get otp => _otp;

  bool _isUpdate = false;
  bool get isUpdate => _isUpdate;

  String _dropDownValue= "";
  String get dropDownValue => _dropDownValue;

  bool _isWrongOtpSubmitted = false;
  bool get isWrongOtpSubmitted => _isWrongOtpSubmitted;

  ScrollController scrollController  = ScrollController();
  ScrollController completedServiceImagesScrollController  = ScrollController();

  BookingDetailsModel? _bookingDetails;
  BookingDetailsModel? get bookingDetails => _bookingDetails;

  bool _showPhotoEvidenceField = false;
  bool get showPhotoEvidenceField => _showPhotoEvidenceField;

  List<XFile> _photoEvidence = [];
  List<XFile> get pickedPhotoEvidence => _photoEvidence;

  bool _hideResendButton = false;
  bool get hideResendButton => _hideResendButton;

  final List<MultipartBody> _selectedIdentityImageList = [];
  List<MultipartBody> get selectedIdentityImageList => _selectedIdentityImageList;

  var bookingPageCurrentState = BookingDetailsTabControllerState.bookingDetails;

  // ----- PROVIDER SERVICES (extra work ke liye existing service select) -----
  List<Map<String, dynamic>> _providerServices = [];
  List<Map<String, dynamic>> get providerServices => _providerServices;
  bool _providerServicesLoading = false;
  bool get providerServicesLoading => _providerServicesLoading;

  Future<void> loadProviderServices() async {
    if (_providerServices.isNotEmpty || _providerServicesLoading) return;
    _providerServicesLoading = true;
    update();
    try {
      Response response = await bookingDetailsRepo.getProviderServices();
      if (response.statusCode == 200 && response.body['content'] is List) {
        _providerServices = (response.body['content'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {
      _providerServices = [];
    }
    _providerServicesLoading = false;
    update();
  }



  final List<Tab> myTabs = <Tab>[
    Tab(text: 'booking_details'.tr),
    Tab(text: 'status'.tr),
  ];

  final List<String> statusTypeList = [ "ongoing", "completed" , "canceled"];
  

  void _manageLocationTracking(String status) {
    final locationService = Get.find<LocationService>();
    if (status == 'ongoing') {
      if (!locationService.isActive) {
        locationService.startLocationTracking();
      }
    } else if (status == 'completed' || status == 'canceled') {
      if (locationService.isActive) {
        locationService.stopLocationTracking();
      }
    }
  }

  Future<void> getBookingDetails({required String bookingID, required bool isSubBooking}) async {

    Response response = await bookingDetailsRepo.getBookingDetails(bookingID: bookingID, isSubBooking: isSubBooking);

    if(response.statusCode == 200 ){

      _bookingDetails = BookingDetailsModel.fromJson(response.body);

      Get.find<BookingEditController>().getServiceListBasedOnSubcategory(
        subCategoryId : bookingDetails?.bookingContent?.bookingDetailsContent?.subCategoryId ??   bookingDetails?.bookingContent?.bookingDetailsContent?.subBooking?.subCategoryId ?? "",
      );

      _dropDownValue = _bookingDetails?.bookingContent?.bookingDetailsContent?.bookingStatus ?? "";

      _manageLocationTracking(_dropDownValue);

      _hideCanceledOption();

    }
    else{
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<bool> sendBookingOTPNotification(String? bookingId, {bool shouldUpdate = true}) async {
    if(shouldUpdate){
      _hideResendButton = true;
      update();
    }
    Response response = await bookingDetailsRepo.sendBookingOTPNotification(bookingId);
    bool isSuccess;
    if(response.statusCode == 200) {
      isSuccess = true;
    }else {
      ApiChecker.checkApi(response);
      isSuccess = false;
    }
    _hideResendButton = false;
    update();
    return isSuccess;
  }


  void changeBookingStatus({required String bookingId, required String bookingStatus, required isSubBooking,bool isBack = false, String? startOtp} ) async{
    _isUpdate = true;
    update();

    List<MultipartBody> multiParts = [];
    for(XFile file in _photoEvidence) {
      multiParts.add(MultipartBody('evidence_photos[]', file));
    }

    // NOTE: target status ab caller ke bookingStatus param se aata hai
    // (dropdown hataya — sirf explicit buttons: Reached/OTP/Complete/Cancel).
    Response response = await bookingDetailsRepo.changeBookingStatus(bookingID: bookingId, status: bookingStatus, otp: otp , isSubBooking: isSubBooking, photoEvidence: multiParts, startOtp: startOtp);
    if(response.statusCode==200 && response.body["response_code"]=="status_update_success_200"){

      getBookingDetails(bookingID: bookingId, isSubBooking: isSubBooking);
      _manageLocationTracking(bookingStatus);

      if(isBack){
        Get.back();
      }
      showCustomSnackBar(response.body['message'], type : ToasterMessageType.success);
      Get.find<BookingRequestController>().getBookingList(
        Get.find<BookingRequestController>().bookingStatusState.name.toLowerCase(),1,
      );
      Get.find<BookingRequestController>().getBookingHistory(
        Get.find<BookingRequestController>().bookingHistoryStatus[ Get.find<BookingRequestController>().bookingHistorySelectedIndex],1,
      );
    }else if(response.statusCode==200 && response.body["response_code"] == "default_403"){
      if((bookingStatus == "completed" && otp.isNotEmpty) || (bookingStatus == "ongoing" && startOtp != null && startOtp.isNotEmpty)){
        _isWrongOtpSubmitted  = true;
      }
    }
    else{
      showCustomSnackBar(_errorMessage(response));
    }
    _isUpdate = false;
    update();
  }

  /// SPEC: serviceman customer ke ghar (300m radius) pahuncha -> "Reached"
  /// mark karo -> backend start OTP generate karega (customer app me dikhega).
  Future<bool> markReached(String bookingId, {bool isSubBooking = false}) async {
    _isUpdate = true;
    update();
    bool isSuccess = false;

    // Backend ko FRESH location chahiye (5-min freshness + 300m radius check).
    // Background stream ka wait mat karo — turant GPS lo aur upload karo.
    final LocationService locationService = Get.find<LocationService>();
    unawaited(locationService.startLocationTracking());
    final bool locationUploaded = await locationService.forceUploadCurrentLocation();
    if (!locationUploaded) {
      _isUpdate = false;
      update();
      showCustomSnackBar('enable_gps_for_reached'.tr, type: ToasterMessageType.error);
      return false;
    }

    Response response = await bookingDetailsRepo.markReached(bookingId);
    if (response.statusCode == 200 && response.body['response_code'] == 'status_update_success_200') {
      isSuccess = true;
      getBookingDetails(bookingID: bookingId, isSubBooking: isSubBooking);
      showCustomSnackBar('otp_generated_share_customer'.tr, type: ToasterMessageType.success);
    } else {
      ApiChecker.checkApi(response);
      if (response.statusCode != 401) {
        showCustomSnackBar(_errorMessage(response));
      }
    }
    _isUpdate = false;
    update();
    return isSuccess;
  }

  /// Extra service (custom/external work) add karo — total bill update hoga
  Future<bool> addExtraService({required String bookingId, required String name, required String price, required String quantity, String type = 'custom', bool isSubBooking = false}) async {
    _isUpdate = true;
    update();
    bool isSuccess = false;
    Response response = await bookingDetailsRepo.addExtraService(
      bookingID: bookingId, name: name, price: price, quantity: quantity, type: type,
    );
    if (response.statusCode == 200 && (response.body['response_code'] == 'default_store_200' || response.body['response_code'] == 'default_200')) {
      isSuccess = true;
      getBookingDetails(bookingID: bookingId, isSubBooking: isSubBooking);
      showCustomSnackBar('extra_service_added'.tr, type: ToasterMessageType.success);
    } else {
      ApiChecker.checkApi(response);
      if (response.statusCode != 401) {
        showCustomSnackBar(_errorMessage(response));
      }
    }
    _isUpdate = false;
    update();
    return isSuccess;
  }

  /// Extra service remove — total bill se minus hoga
  Future<bool> removeExtraService({required String bookingId, required String extraServiceId, bool isSubBooking = false}) async {
    _isUpdate = true;
    update();
    bool isSuccess = false;
    Response response = await bookingDetailsRepo.removeExtraService(bookingID: bookingId, extraServiceId: extraServiceId);
    if (response.statusCode == 200 && response.body['response_code'] != 'default_204') {
      isSuccess = true;
      getBookingDetails(bookingID: bookingId, isSubBooking: isSubBooking);
      showCustomSnackBar('extra_service_removed'.tr, type: ToasterMessageType.success);
    } else {
      showCustomSnackBar(_errorMessage(response));
    }
    _isUpdate = false;
    update();
    return isSuccess;
  }

  String _errorMessage(Response response) {
    final dynamic data = response.body;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return response.statusText?.isNotEmpty == true ? response.statusText! : 'something_went_wrong'.tr;
  }

  void changePaymentStatus(String bookingId,String paymentStatus) async {
    Response response = await bookingDetailsRepo.changePaymentStatus(bookingId,paymentStatus);
    if(response.statusCode == 200){
      showCustomSnackBar('successfully_paid'.tr,type : ToasterMessageType.success);
    } else {
      showCustomSnackBar(_errorMessage(response));
    }
    update();
  }

  void changePhotoEvidenceStatus({bool isUpdate = true , bool status = false}){
    _showPhotoEvidenceField = status;
    scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(seconds: 1), curve: Curves.ease);
    if(isUpdate) {
      update();
    }
  }

  void updateServicePageCurrentState(BookingDetailsTabControllerState bookingDetaisTabControllerState){
    bookingPageCurrentState = bookingDetaisTabControllerState;
    update();
  }

  void setSelectedValue(String value){
    _dropDownValue=value;
    update();
  }


  Future<void> pickPhotoEvidence({required bool isRemove, required bool isCamera}) async {
    if(isRemove) {
      _photoEvidence = [];
      _showPhotoEvidenceField = false;
    }else {
      // Note: FileValidationHelper uses default image quality of 80, 
      // but this booking feature previously used quality 50 for smaller file sizes
      final xFile = await FileValidationHelper.validateAndPickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: isCamera ? 50 : AppConstants.defaultImageQuality,
      );
      
      if(xFile != null) {
        _photoEvidence.add(xFile);
        if(Get.isDialogOpen!){
          Get.back();
        }
        changePhotoEvidenceStatus(isUpdate: false, status: true);
      }
      update();
    }
  }

  void removePhotoEvidence(int index) {
    _photoEvidence.removeAt(index);
    update();
  }

  void setOtp(String otp) {
    _otp = otp;
    resetWrongOtpValue(shouldUpdate: false);
    if(otp != '') {
      update();
    }
  }

  void resetWrongOtpValue({bool shouldUpdate = true}){
    _isWrongOtpSubmitted = false;

    if(shouldUpdate){
      update();
    }
  }

  void _hideCanceledOption(){
    if(Get.find<SplashController>().configModel?.content?.serviceManCanCancelBooking == 0 || _bookingDetails?.bookingContent?.providerServicemanCanCancelBooking == 0){
      statusTypeList.remove('canceled');
    }
  }

  bool isShowChattingButton(BookingDetailsContent? bookingDetails){
    return ((bookingDetails != null) && (bookingDetails.bookingStatus == "pending"
        || bookingDetails.bookingStatus == "accepted" || bookingDetails.bookingStatus == "ongoing" )
        && (bookingPageCurrentState == BookingDetailsTabControllerState.bookingDetails)
        && (bookingDetails.serviceman !=null || bookingDetails.customer != null));
  }

  void resetBookingDetailsValue(){
    _photoEvidence = [];
    _showPhotoEvidenceField = false;
    bookingPageCurrentState = BookingDetailsTabControllerState.bookingDetails;
    _bookingDetails = null;
  }
}