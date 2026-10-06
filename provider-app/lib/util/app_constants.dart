import 'package:demandium_provider/common/model/language_model.dart';
import 'package:demandium_provider/util/images.dart';

class AppConstants {

  static const String appName = 'JS Admin';
  static const String shortAppName = 'JS Admin';
  static const String appUser = 'Provider';
  static const String appVersion = '3.8'; /// Flutter SDK: 3.41.5
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const bool avoidMaintenanceMode = false;
  static const String configUri = '/api/v1/partner/setup';
  static const String registerUri = '/api/v1/partner/access/signup';
  static const String loginUri = '/api/v1/partner/access/signin';
  static const String dashboardUri = '/api/v1/partner/overview';
  static const String earningDataUrl = '/api/v1/partner/overview/income';
  static const String servicemanListUri = '/api/v1/partner/technician';
  static const String servicemanDetailsUri = '/api/v1/partner/technician';
  static const String servicemanDeleteUri = '/api/v1/partner/technician/erase';
  static const String addNewServicemanUri = '/api/v1/partner/technician';
  static const String servicemanUpdateUri = '/api/v1/partner/technician';
  static const String servicemanAssignUri = '/api/v1/partner/order/assign-technician';
  static const String recheckSummaryUri = '/api/v1/partner/order/recheck-summary';
  static const String servicemanUpdateStatus = '/api/v1/partner/technician/state/modify';
  static const String providerProfileUri = '/api/v1/partner/identity/summary';
  static const String providerProfileUpdateUrl = '/api/v1/partner/modify/account';
  static const String bookingListUrl = '/api/v1/partner/order';
  static const String bookingCalenderList = '/api/v1/partner/order/scheduler/preview';
  static const String bookingDetailsUrl = '/api/v1/partner/order/';
  static const String subBookingDetailsUrl = '/api/v1/partner/order/individual/';
  static const String acceptBookingRequestUrl = '/api/v1/partner/order/submission-approve';

  // ----- AUTO-ASSIGN -----
  static const String autoAssignToggleUrl = '/api/v1/partner/order/auto-assign-switch';
  static const String autoAssignWaitTimeUrl = '/api/v1/partner/order/auto-assign-delay-window';
  static const String autoAssignStatusUrl = '/api/v1/partner/order/auto-assign-state';
  static const String assignSuggestionsUrl = '/api/v1/partner/order/assign-suggestions';
  static const String assignServicemenUrl = '/api/v1/partner/order/assign-servicemen';
  static const String checkAuthCredentials = '/api/v1/partner/access/credential-probe';

  static const String ignoreBookingRequestUrl = '/api/v1/partner/order/submission-dismiss';
  static const String cancelSubBookingUrl = '/api/v1/partner/order/individual-recurring-abort/';
  static const String changeBookingStatus = '/api/v1/partner/order/state-change';
  static const String changeSubBookingStatus = '/api/v1/partner/order/individual-recurring-state-change';
  static const String bookingOTPNotificationUri = '/api/v1/partner/order/one-time-pin/alert-dispatch';
  static const String bankDetailsUrl = '/api/v1/partner/fetch-bank-facts';
  static const String updateBankDetailsUrl = '/api/v1/partner/modify-bank-facts';
  static const String serviceCategoryUrl = '/api/v1/partner/group';
  static const String serviceSubcategoryUrl = '/api/v1/partner/group/subgroups';
  static const String serviceListBasedOnSubCategory = '/api/v1/partner/task/records/child-group-wise';
  static const String serviceDetailsUrl = '/api/v1/partner/task';
  static const String serviceFaqUrl = '/api/v1/partner/questions';
  static const String changeSubscriptionStatusUrl = '/api/v1/partner/task/modify-membership';
  static const String myServiceManageUrl = '/api/v1/partner/services/manage';
  static const String categoryAssignmentUrl = '/api/v1/partner/category-assignment';
  static const String categoryAssignmentRequestUrl = '/api/v1/partner/category-assignment/request';
  static const String changeScheduleUrl = '/api/v1/partner/order/timetable-modify';
  static const String subscriptionListUrl = '/api/v1/partner/enrolled/child-groups';
  static const String notificationUrl = '/api/v1/partner/alert-feed';
  static const String zoneUrl = '/api/v1/zones';
  static const String tokenUrl = '/api/v1/partner/modify/push-key';
  static const String withdrawRequestUrl = '/api/v1/partner/payout';
  static const String withdrawMethodRequest = '/api/v1/partner/payout/options';
  static const String createChannel = '/api/v1/partner/inbox/open-thread';
  static const String getChannelListUrl = '/api/v1/partner/inbox/thread-index';
  static const String searchChannelListUrl = '/api/v1/partner/inbox/thread-lookup';
  static const String getConversationUrl = '/api/v1/partner/inbox/thread';
  static const String sendMessageUrl = '/api/v1/partner/inbox/transmit-note';
  static const String getServiceReviewList = '/api/v1/partner/task/feedback';
  static const String getProviderReviewList = '/api/v1/partner/feedback';
  static const String reviewReply = '/api/v1/partner/feedback-response';
  static const String pagesDetailsApi = '/api/v1/client/setup/page-facts';
  static const String getTransactionReportList = '/api/v1/partner/statement/ledger-entry';
  static const String getBookingReportList = '/api/v1/partner/statement/order';
  static const String getBusinessExpenseList = '/api/v1/partner/statement/company/cost-track';
  static const String getBusinessEarningList = '/api/v1/partner/statement/company/income';
  static const String getBusinessOverviewList = '/api/v1/partner/statement/company/summary';
  static const String submitNewServiceRequest = '/api/v1/partner/task-submission';
  static const String getSuggestedServiceList = '/api/v1/partner/task-submission';
  static const String getBookingPriceList = '/api/v1/partner/order/task/dossier';
  static const String removeCartServiceFromServer = '/api/v1/partner/order/task/revise/task-detach';
  static const String updateRegularBooking = '/api/v1/partner/order/task/revise/modify-order';
  static const String updateRepeatBooking = '/api/v1/partner/order/recurring/task/revise/modify-order';
  static const String updateBusinessBookingSettings = '/api/v1/partner/company-preferences/set-company-preferences';
  static const String getBusinessBookingSettings = '/api/v1/partner/company-preferences/fetch-company-preferences';

  static const String getServiceAvailabilitySettings = '/api/v1/partner/work-window-plan';
  static const String updateServiceAvailabilitySettings = '/api/v1/partner/work-window-plan';

  static const String geocodeUri = '/api/v1/client/setup/geo-coder';
  static const String searchLocationUri = '/api/v1/client/setup/geo-suggest';
  static const String placeDetailsUri = '/api/v1/client/setup/geo-spot-facts';

  static const String getCustomerPostList = '/api/v1/partner/listing';
  static const String bidCustomerPost = '/api/v1/partner/listing/offer';
  static const String declineCustomerPost = '/api/v1/partner/listing';
  static const String withdrawBidRequest = '/api/v1/partner/listing/offer/payout';
  static const String getProviderOfferList = '/api/v1/partner/listing/offer';
  static const String getPostDetails = '/api/v1/partner/listing/breakdown';

  static const String sendOtpForVerification = '/api/v1/member/validation/transmit-pin';
  static const String sendOtpForForgetPassword = '/api/v1/member/lost-secret/transmit-pin';
  static const String verifyOtpForForgetPasswordScreen = '/api/v1/member/lost-secret/check-pin';
  static const String verifyOtpForVerificationScreen = '/api/v1/member/validation/check-pin';
  static const String firebaseOtpVerify = '/api/v1/member/validation/firebase-access-check';
  static const String resetPasswordUri = '/api/v1/member/lost-secret/restore';
  static const String providerRemove = '/api/v1/partner/erase';
  static const String adjustTransaction = '/api/v1/partner/reconcile';
  static const String paymentUri = '/api/v1/client/setup';
  static const String changeLanguage = '/api/v1/partner/locale-switch';

  static const String packageSubscriptionUri = '/api/v1/partner/membership/plan/index';
  static const String subscriptionDetailsUri = '/api/v1/partner/membership/plan/subscriber-facts';
  static const String changeSubscriptionStatus = '/api/v1/partner/membership/plan/';
  static const String subscriptionTransactionListUri = '/api/v1/partner/membership/ledger';


  static const String submitNewAdvertisement = '/api/v1/partner/showcases/showcase-save';
  static const String editAdvertisement = '/api/v1/partner/showcases/modify';
  static const String getAdvertisementList = '/api/v1/partner/showcases/showcase-feed';
  static const String getAdvertisementDetails = '/api/v1/partner/showcases/breakdown';
  static const String deleteAdvertisement = '/api/v1/partner/showcases/erase';
  static const String changeAdvertisementStatus ='/api/v1/partner/showcases/state-change';
  static const String reSubmitAdvertisement = '/api/v1/partner/showcases/save-resubmit';
  static const String getNotificationSettingList = '/api/v1/partner/preferences/fetch-alert-settings';
  static const String updateNotificationSetting = '/api/v1/partner/preferences/modify-alert-state';
  static const String regularBookingInvoiceUrl = "/admin/booking/provider-invoice/";
  static const String fullRepeatBookingInvoiceUrl = "/admin/booking/provider-fullbooking-invoice/";
  static const String singleRepeatBookingInvoiceUrl = "/admin/booking/provider-fullbooking-single-invoice/";
  static const String subscriptionTransactionInvoice = '/admin/subscription/package/invoice/';
  static const String changeServiceLocation = '/api/v1/partner/order/change-task-position';
  static const String updateTutorialUrl = '/api/v1/partner/modify/guide';
  static const String updatePasswordUrl = '/api/v1/partner/modify/secret';



  static const String storePaymentMethod = '/api/v1/partner/pay-mode-record/save';
  static const String statusUpdatePaymentMethod = '/api/v1/partner/pay-mode-record/state-change';
  static const String markAsDefaultPaymentMethod = '/api/v1/partner/pay-mode-record/default-state-change';
  static const String updatePaymentMethod = '/api/v1/partner/pay-mode-record/modify';
  static const String deletePaymentMethod = '/api/v1/partner/pay-mode-record/erase';
  static const String getPaymentMethodList = '/api/v1/partner/pay-mode-record/browse';



  static const String theme = 'demand_theme';
  static const String token = 'demand_token';
  static const String countryCode = 'demand_country_code';
  static const String languageCode = 'demand_language_code';
  static const String userPassword = 'demand_user_password';
  static const String userAddress = 'demand_user_address';
  static const String userNumber = 'demand_user_number';
  static const String notification = 'demand_notification';
  static const String isRememberActive = 'is_remember_active';
  static const String notificationCount = 'notification_count';
  static const String initialLanguage = 'initial-language';
  static const String topic = 'provider-admin';
  static const String localizationKey = 'X-localization';

  static List<LanguageModel> languages = [

    LanguageModel(imageUrl: Images.us, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    LanguageModel(imageUrl: Images.ar, languageName: 'عربى', countryCode: 'SA', languageCode: 'ar'),
    LanguageModel(imageUrl: Images.bn, languageName: 'বাংলা', countryCode: 'BD', languageCode: 'bn'),
    LanguageModel(imageUrl: Images.india, languageName: 'Hindi', countryCode: 'IN', languageCode: 'hi'),

  ];

  static final List<Map<String, String>> walletTransactionSortingList = [
    {
      'title' : 'all',
      'value' : 'all'
    },
    {
      'title' : 'withdrawn_amount',
      'value' : 'paid_commission'
    },

    {
      'title' : 'paid_amount',
      'value' : 'paid_amount'
    },
  ];

  static Map<String, String> configHeader = {
    'Content-Type': 'application/json; charset=UTF-8',
    'zoneId': 'configuration',
  };

  static const  List<String> identityTypeList = [
    "passport",
    "nid",
    "trade_license",
    "driving_license"

  ];
  static const int limitOfPickedIdentityImageNumber = 5;
  static const double balanceInputLength = 10;
  static const double maxLimitOfTotalFileSent = 5;

  static const String businessInfoTutorialKey = 'business_information';
  static const String serviceSubscriptionTutorialKey = 'service_subscription';
  static const String serviceAvailabilityTutorialKey = 'service_availability';
  static const String paymentInfoTutorialKey = 'payment_information';

  /// Allowed image file extensions for upload
  static const List<String> allowedImageExtensions = [
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
  ];

  /// Allowed video file extensions for upload
  static const List<String> allowedVideoExtensions = [
    'mp4',
    'mkv',
    'avi',
    'mov',
    'wmv',
    'flv',
    'webm',
    'mpeg',
    'mpg',
    'm4v',
    '3gp',
    'ogv',
  ];

  

  /// Allowed document file extensions for upload
  static const List<String> _allowedDocumentExtensions = [
    'pdf',
    'csv',
    'txt',
    'xls',
    'xlsx',
    'doc',
    'docx',
  ];

  /// All allowed file extensions (images + documents)
  static const List<String> allowedFileExtensions = [
    ...allowedImageExtensions,
    ..._allowedDocumentExtensions,
  ];

  /// Default image quality for image picker (0-100)
  static const int defaultImageQuality = 80;

}
