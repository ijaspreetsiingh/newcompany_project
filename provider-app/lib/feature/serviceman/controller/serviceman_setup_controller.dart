import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class ServicemanSetupController extends GetxController
    with GetSingleTickerProviderStateMixin
    implements GetxService {
  final ServicemanRepo servicemanRepo;
  ServicemanSetupController({required this.servicemanRepo});

  // ── Image state ───────────────────────────────────────────────────────────
  XFile? _pickedProfileImage;
  XFile? get pickedProfileImage => _pickedProfileImage;

  List<MultipartBody> _selectedIdentityImageList = [];
  List<MultipartBody> get selectedIdentityImageList => _selectedIdentityImageList;

  // ── General state ─────────────────────────────────────────────────────────
  int selectedIndex = -1;
  int? currentServicemanIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isProfilePicValid = true;
  bool get isProfilePicValid => _isProfilePicValid;

  bool _isServicemanIdentityImageValid = true;
  bool get isServicemanIdentityImageValid => _isServicemanIdentityImageValid;

  bool _isIdentityTypeValid = true;
  bool get isIdentityTypeValid => _isIdentityTypeValid;

  final bool _loading = false;
  bool get loading => _loading;

  String selectedIdentityType = '';

  String _profileImage = '';
  String get profileImage => _profileImage;

  List<String> _identificationImage = [];
  List<String> get identificationImage => _identificationImage;

  List<ServicemanModel>? _servicemanList;
  List<ServicemanModel>? get servicemanList => _servicemanList;

  bool _isFromBookingDetailsPage = false;
  bool get isFromBookingDetailsPage => _isFromBookingDetailsPage;

  final GlobalKey<FormState> addServiceManAccountInfoValidation = GlobalKey<FormState>();
  final GlobalKey<FormState> addServiceManGeneralInfoValidation  = GlobalKey<FormState>();

  int _offset   = 1;
  int get offset => _offset;

  int _pageSize = 1;
  int get pageSize => _pageSize;

  int _totalServiceman = 0;
  int get totalServiceman => _totalServiceman;

  bool _isGeneralInfoValid = false;
  bool get isGeneralInfoValid => _isGeneralInfoValid;

  var firstNameController       = TextEditingController();
  var lastNameController        = TextEditingController();
  var phoneController           = TextEditingController();
  var identityNumberController  = TextEditingController();
  var emailController           = TextEditingController();
  var passController            = TextEditingController();
  var confirmPasswordController = TextEditingController();
  String? countryDialCode = '+880';

  var servicemanPageCurrentState = ServicemanTabControllerState.generalInfo;
  ScrollController scrollController = ScrollController();
  TabController? controller;

  List<Widget> servicemanDetailsTabs = [
    SizedBox(width: Get.width * .45, child: Tab(text: 'general_info'.tr)),
    SizedBox(width: Get.width * .45, child: Tab(text: 'account_info'.tr)),
  ];

  // ── Category assignment state ──────────────────────────────────────────────
  /// Provider ki subscribed sub-categories (jo admin ne assign ki hain)
  List<SubscriptionModelData> _subscribedSubCategories = [];
  List<SubscriptionModelData> get subscribedSubCategories => _subscribedSubCategories;
  bool _isCategoryLoading = false;
  bool get isCategoryLoading => _isCategoryLoading;

  /// Provider ne select kiye sub_category_ids
  List<String> _selectedSubCategoryIds = [];
  List<String> get selectedSubCategoryIds => _selectedSubCategoryIds;

  /// Toggle: agar already selected hai to remove, warna add
  void toggleSubCategory(String subCategoryId) {
    if (_selectedSubCategoryIds.contains(subCategoryId)) {
      _selectedSubCategoryIds.remove(subCategoryId);
    } else {
      _selectedSubCategoryIds.add(subCategoryId);
    }
    update();
  }

  /// Provider ki subscribed sub-categories backend se load karo
  Future<void> loadSubscribedSubCategories() async {
    if (_subscribedSubCategories.isNotEmpty) return; // already loaded
    _isCategoryLoading = true;
    update();
    try {
      final Response response = await servicemanRepo.getProviderSubscribedSubCategories();
      if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
        final List<dynamic> list = response.body['content']['data'] ?? [];
        _subscribedSubCategories = list
            .where((e) => e['sub_category'] != null)
            .map((e) => SubscriptionModelData.fromJson(e))
            .toList();
      }
    } catch (_) {}
    _isCategoryLoading = false;
    update();
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (_offset < _pageSize) {
          getAllServicemanList(_offset + 1, reload: false);
        }
      }
    });
    controller = TabController(
        vsync: this, length: servicemanDetailsTabs.length, initialIndex: 0);
    selectedIndex  = -1;
    countryDialCode = CountryCode
        .fromCountryCode(Get.find<SplashController>().configModel.content!.countryCode!)
        .dialCode ?? '+880';
    loadSubscribedSubCategories();
  }

  // ── Assign serviceman to booking ──────────────────────────────────────────

  Future<void> assignServiceman({
    String? bookingId,
    String? subBookingId,
    required String servicemanId,
    bool reAssignServiceman = false,
  }) async {
    _isLoading = true;
    update();
    final Response response = await servicemanRepo.assignServiceman(
        bookingId: bookingId, subBookingId: subBookingId, servicemanId: servicemanId);

    if (response.statusCode == 200 &&
        response.body['response_code'] == 'serviceman_assign_success_200') {
      if (bookingId != null) {
        Get.find<BookingDetailsController>().getBookingDetails(bookingId, reload: false);
      } else if (subBookingId != null) {
        Get.find<BookingDetailsController>().getBookingSubDetails(subBookingId, reload: false);
      }
      Get.find<BookingDetailsController>().showHideExpandView(0);
      showCustomSnackBar(
        _isFromBookingDetailsPage && reAssignServiceman
            ? 'service_man_re_assigned_successfully'.tr
            : 'service_man_assigned_successfully'.tr,
        type: ToasterMessageType.success,
      );
    } else {
      Get.find<BookingDetailsController>().showHideExpandView(0);
      if (bookingId != null) {
        Get.find<BookingDetailsController>().getBookingDetails(bookingId, reload: false);
      } else if (subBookingId != null) {
        Get.find<BookingDetailsController>().getBookingSubDetails(subBookingId, reload: false);
      }
      showCustomSnackBar(response.body['message'].toString().capitalizeFirst);
    }
    _isLoading = false;
    update();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> addNewServiceman(ServicemanBody servicemanBody) async {
    _isLoading = true;
    update();
    // Inject selected categories into body
    servicemanBody = ServicemanBody(
      firstName:         servicemanBody.firstName,
      lastName:          servicemanBody.lastName,
      email:             servicemanBody.email,
      phone:             servicemanBody.phone,
      password:          servicemanBody.password,
      confirmedPassword: servicemanBody.confirmedPassword,
      identityType:      servicemanBody.identityType,
      identityNumber:    servicemanBody.identityNumber,
      subCategoryIds:    List.from(_selectedSubCategoryIds),
    );

    final Response? response = await servicemanRepo.addNewServiceman(
        servicemanBody, pickedProfileImage, _selectedIdentityImageList);

    if (response!.statusCode == 200) {
      _selectedIdentityImageList = [];
      showCustomSnackBar('serviceman_added_successfully'.tr, type: ToasterMessageType.success);
      if (_isFromBookingDetailsPage) {
        await getAllServicemanList(1, reload: true, status: 'active');
      } else {
        await getAllServicemanList(1, reload: true);
      }
      Get.find<DashboardController>().getDashboardData();
      clearAllData();
      Get.back();
    } else if (response.statusCode == 400) {
      showCustomSnackBar(response.body['errors'][0]['message']);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> editServicemanInfoWithPassword(
      ServicemanBody servicemanBody, String servicemanId) async {
    _isLoading = true;
    update();
    final Response? response = await servicemanRepo.editServicemanInfoWithPassword(
        servicemanBody, pickedProfileImage, null, servicemanId);
    confirmPasswordController.text = '';
    passController.text = '';
    if (response!.statusCode == 200) {
      selectedIndex = -1;
      Get.back();
      showCustomSnackBar('serviceman_password_updated'.tr, type: ToasterMessageType.success);
      getAllServicemanList(1, reload: true);
    } else {
      showCustomSnackBar('something_went_wrong'.tr);
    }
    _isLoading = false;
    update();
  }

  Future<void> editServicemanInfoWithoutPassword(
      ServicemanBody servicemanBody, String servicemanId) async {
    _isLoading = true;
    update();

    // Inject selected categories
    final ServicemanBody bodyWithCats = ServicemanBody(
      firstName:         servicemanBody.firstName,
      lastName:          servicemanBody.lastName,
      email:             servicemanBody.email,
      phone:             servicemanBody.phone,
      identityType:      servicemanBody.identityType,
      identityNumber:    servicemanBody.identityNumber,
      subCategoryIds:    List.from(_selectedSubCategoryIds),
    );

    final Response? response = await servicemanRepo.editServicemanInfoWithoutPassword(
        bodyWithCats, pickedProfileImage, _selectedIdentityImageList, servicemanId);

    if (response!.statusCode == 200) {
      _selectedIdentityImageList = [];
      selectedIndex = -1;
      getAllServicemanList(1, reload: true);
      Get.find<ServicemanDetailsController>().getServicemanDetails(servicemanId);
      Get.back();
      showCustomSnackBar('serviceman_info_updated'.tr, type: ToasterMessageType.success);
    } else if (response.statusCode == 400) {
      final errors = response.body is Map ? response.body['errors'] : null;
      final firstError = errors is List && errors.isNotEmpty && errors.first is Map
          ? errors.first
          : null;
      final errorCode = firstError?['error_code'] ?? firstError?['code'];
      if (errorCode == 'email') {
        showCustomSnackBar('the_account_email_has_already_been_taken'.tr);
      } else if (errorCode == 'phone') {
        showCustomSnackBar('the_account_phone_has_already_been_taken'.tr);
      } else {
        final messages = errors is List
            ? errors
                .whereType<Map>()
                .map((error) => error['message']?.toString())
                .whereType<String>()
                .where((message) => message.trim().isNotEmpty)
                .toSet()
                .toList()
            : <String>[];
        showCustomSnackBar(
          messages.isNotEmpty ? messages.join('\n') : 'something_went_wrong'.tr,
        );
      }
    } else {
      showCustomSnackBar('something_went_wrong'.tr);
    }
    _isLoading = false;
    update();
  }

  Future<void> getAllServicemanList(int offset,
      {bool reload = false, String status = 'all'}) async {
    _offset = offset;
    if (reload || _servicemanList == null) {
      final Response response = await servicemanRepo.getAllServicemanData(offset, status);
      if (response.statusCode == 200) {
        final List<dynamic> list = response.body['content']['data'];
        if (_offset == 1) {
          _servicemanList = list.map((e) => ServicemanModel.fromJson(e)).toList();
        } else {
          _servicemanList!.addAll(list.map((e) => ServicemanModel.fromJson(e)));
        }
        _pageSize        = response.body['content']['last_page'];
        _totalServiceman = response.body['content']['total'];
      } else {
        ApiChecker.checkApi(response);
      }
    }
    update();
  }

  Future<void> getSingleServicemanData({int? index, String? fromPage}) async {
    if (fromPage == 'editPage') {
      final sm = servicemanList![index!];
      countryDialCode = ValidationHelper.getValidCountryCode(sm.phone ?? '').isNotEmpty
          ? ValidationHelper.getValidCountryCode(sm.phone ?? '')
          : CountryCode.fromCountryCode(
                  Get.find<SplashController>().configModel.content!.countryCode!)
              .dialCode ?? '+880';
      firstNameController.text      = sm.firstName ?? '';
      lastNameController.text       = sm.lastName ?? '';
      phoneController.text          = ValidationHelper.getValidPhone(sm.phone ?? '').isNotEmpty
          ? ValidationHelper.getValidPhone(sm.phone ?? '')
          : sm.phone ?? '';
      identityNumberController.text = sm.identificationNumber ?? '';
      selectedIdentityType          = sm.identificationType ?? '';
      emailController.text          = sm.email ?? '';
      _profileImage                 = sm.profileImageFullPath ?? '';
      _identificationImage          = [...?sm.identificationImageFullPath];
      passController.text           = '';
      confirmPasswordController.text = '';
      // Pre-fill category selection from existing serviceman assignments
      _selectedSubCategoryIds = List<String>.from(
          sm.serviceman?.subCategoryIds ?? []);
      updateIndex(-1);
      currentServicemanIndex = index;
    } else if (fromPage == 'detailsPage') {
      final details = Get.find<ServicemanDetailsController>();
      final user = details.servicemanModel!.user!;
      countryDialCode = ValidationHelper.getValidCountryCode(user.phone ?? '').isNotEmpty
          ? ValidationHelper.getValidCountryCode(user.phone ?? '')
          : CountryCode.fromCountryCode(
                  Get.find<SplashController>().configModel.content!.countryCode!)
              .dialCode ?? '+880';
      firstNameController.text       = user.firstName ?? '';
      lastNameController.text        = user.lastName ?? '';
      phoneController.text           = ValidationHelper.getValidPhone(user.phone ?? '').isNotEmpty
          ? ValidationHelper.getValidPhone(user.phone ?? '')
          : user.phone ?? '';
      identityNumberController.text  = user.identificationNumber ?? '';
      selectedIdentityType           = user.identificationType ?? '';
      emailController.text           = user.email ?? '';
      passController.text            = '';
      confirmPasswordController.text = '';
      _profileImage        = details.servicemanModel?.user?.profileImageFullPath ?? '';
      _identificationImage = details.servicemanModel?.user?.identificationImageFullPath ?? [];
      // Pre-fill categories from DashboardServicemanModel
      _selectedSubCategoryIds = List<String>.from(
          details.servicemanModel?.subCategoryIds ?? []);
    } else {
      firstNameController.clear();
      lastNameController.clear();
      phoneController.clear();
      identityNumberController.clear();
      emailController.clear();
      _profileImage            = '';
      _pickedProfileImage      = null;
      currentServicemanIndex   = -1;
      _identificationImage     = [];
      _selectedIdentityImageList = [];
      passController.clear();
      confirmPasswordController.clear();
      updateIndex(-1);
      selectedIdentityType    = '';
      _selectedSubCategoryIds = [];
      countryDialCode = CountryCode.fromCountryCode(
              Get.find<SplashController>().configModel.content!.countryCode!)
          .dialCode ?? '+880';
    }
    update();
  }

  Future<void> deleteServiceman(String id, {bool fromDetails = false}) async {
    final Response response = await servicemanRepo.deleteServiceman(id);
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_delete_200') {
      updateIndex(-1);
      Get.back();
      if (fromDetails) Get.back();
      showCustomSnackBar('serviceman_delete'.tr, type: ToasterMessageType.success);
      _servicemanList?.removeWhere((e) => e.serviceman?.id == id);
      _totalServiceman--;
      Get.find<DashboardController>().removeServiceman(id);
    } else {
      updateIndex(-1);
      Get.back();
      showCustomSnackBar(response.body['message']);
    }
    update();
  }

  Future<void> changeServicemanStatus(int index, String servicemanId,
      {bool fromDetailsPage = false}) async {
    if (fromDetailsPage) {
      Get.find<ServicemanDetailsController>().updateActiveStatus();
    } else {
      servicemanList?[index].isActive = servicemanList?[index].isActive == 1 ? 0 : 1;
      update();
    }
    final Response response = await servicemanRepo.changeServicemanStatus(servicemanId);
    if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
      updateIndex(-1);
      showCustomSnackBar('serviceman_status_updated_successfully'.tr,
          type: ToasterMessageType.success);
    } else {
      showCustomSnackBar('${response.body['message']}');
    }
    update();
  }

  // ── Image helpers ─────────────────────────────────────────────────────────

  void pickProfileImage(bool isRemove) async {
    if (isRemove) {
      _pickedProfileImage = null;
    } else {
      _pickedProfileImage =
          await FileValidationHelper.validateAndPickImage(source: ImageSource.gallery);
    }
    update();
  }

  void pickIdentityImage(bool isRemove, {int? index}) async {
    if (isRemove) {
      if (index != null) _selectedIdentityImageList.removeAt(index);
    } else {
      final XFile? pickedImage =
          await FileValidationHelper.validateAndPickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        _selectedIdentityImageList.add(MultipartBody('identity_images[]', pickedImage));
      }
    }
    update();
  }

  // ── Tab / validation helpers ──────────────────────────────────────────────

  void updateTabControllerValue(ServicemanTabControllerState value) {
    servicemanPageCurrentState = value;
    update();
  }

  void setValue(String value) {
    selectedIdentityType = value;
    update();
  }

  void updateIndex(int index) {
    selectedIndex = index;
    update();
  }

  void clearAllData() {
    _pickedProfileImage       = null;
    passController.clear();
    confirmPasswordController.clear();
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    identityNumberController.clear();
    phoneController.clear();
    _selectedIdentityImageList = [];
    _selectedSubCategoryIds    = [];
  }

  void resetOtherValidationData() {
    _isProfilePicValid                 = true;
    _isServicemanIdentityImageValid    = true;
    _isIdentityTypeValid               = true;
    _isGeneralInfoValid                = false;
  }

  void clearImageData() {
    _pickedProfileImage        = null;
    _selectedIdentityImageList = [];
  }

  void fromBookingDetailsPage(bool fromBookingPage) {
    _isFromBookingDetailsPage = fromBookingPage;
    update();
  }

  void checkOtherValidationField({bool isUpdate = true}) {
    _isProfilePicValid = !(pickedProfileImage == null && profileImage == '');
    _isServicemanIdentityImageValid =
        !(selectedIdentityImageList.isEmpty && identificationImage.isEmpty);
    _isIdentityTypeValid = selectedIdentityType != '';
    if (isUpdate) update();
  }

  void setValidGeneralInfo() {
    _isGeneralInfoValid = true;
    update();
  }
}
