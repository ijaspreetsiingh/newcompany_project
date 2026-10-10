import 'package:jassdbx_serviceman/utils/core_export.dart';

class AppConstants {
  static const String appName = 'JS Partner';
  static const String shortAppName = 'JS Partner';
  static const String appUser = 'Partner App';
  static const String appVersion = '3.6'; /// Flutter SDK: 3.38.5
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const bool avoidMaintenanceMode = false;
  static const String loginUrl = '/api/v1/technician/access/signin';
  static const String configUrl = '/api/v1/technician/setup';
  static const String bookingRequestUrl = '/api/v1/technician/order/index';
  static const String recheckListUrl = '/api/v1/technician/order/recheck-list';
  static const String recheckUpdateUrl = '/api/v1/technician/order/recheck';
  static const String dashboardUrl = '/api/v1/technician/overview';
  static const String profileInfoUrl = '/api/v1/technician/dossier';
  static const String updatePasswordUrl = '/api/v1/technician/account/alter-secret';
  static const String updateProfileUrl = '/api/v1/technician/modify/account';
  static const String notificationUrl = '/api/v1/technician/push-alerts';
  static const String bookingDetailsUrl = '/api/v1/technician/order/info/';
  static const String subBookingDetailsUrl = '/api/v1/technician/order/individual/info/';
  static const String bookingStatusUpdateUrl = '/api/v1/technician/order/state-change';

  // ----- SERVICEMAN ACCEPT / REJECT (auto-assign flow) -----
  static const String acceptBookingUrl = '/api/v1/technician/order/approve';
  static const String rejectBookingUrl = '/api/v1/technician/order/decline';
  static const String subBookingStatusUpdateUrl = '/api/v1/technician/order/individual-recurring-state-change';
  static const String bookingOTPNotificationUri = '/api/v1/technician/order/one-time-pin/alert-dispatch';
  static const String forgetPasswordUrl = '/api/v1/technician/secret-recovery';
  static const String otpVerificationUrl = '/api/v1/technician/pin-validation';
  static const String resetPasswordUrl = '/api/v1/technician/secret-restore';
  static const String createChannel = '/api/v1/technician/inbox/open-thread';
  static const String getChannelListUrl = '/api/v1/technician/inbox/thread-index';
  static const String searchChannelListUrl = '/api/v1/technician/inbox/thread-lookup';
  static const String getConversationUrl = '/api/v1/technician/inbox/thread';
  static const String sendMessageUrl = '/api/v1/technician/inbox/transmit-note';
  static const String callInitiateUrl = '/api/v1/technician/inbox/call/initiate';
  static const String callRespondUrl = '/api/v1/technician/inbox/call/respond';
  static const String callEndUrl = '/api/v1/technician/inbox/call/end';
  static const String callActiveUrl = '/api/v1/technician/inbox/call/active';
  static const String callStatusUrl = '/api/v1/technician/inbox/call/status';
  static const String callTokenUrl = '/api/v1/technician/inbox/call/token';
  static const String callHistoryUrl = '/api/v1/technician/inbox/call/history';
  static const String paymentStatusUpdate = '/api/v1/technician/order/pay-state-change';
  static const String verifyTokenUri = '/api/v1/access/token-probe';
  static const String tokenUri = '/api/v1/technician/modify/push-key';
  static const String workStatusUri = '/api/v1/technician/work-status';

  static const String pagesDetailsApi = '/api/v1/technician/setup/page-facts';
  static const String serviceListBasedOnSubCategory = '/api/v1/technician/task/records/child-group-wise';
  static const String getBookingPriceList = '/api/v1/technician/order/task/dossier';
  static const String removeCartServiceFromServer = '/api/v1/technician/order/task/revise/task-detach';
  static const String updateRegularBooking = '/api/v1/technician/order/task/revise/modify-order';
  static const String updateSubBooking = '/api/v1/technician/order/recurring/task/revise/modify-order';
  static const String firebaseOtpVerify = '/api/v1/member/validation/firebase-access-check';
  static const String regularBookingInvoiceUrl = '/admin/booking/serviceman-invoice/';
  static const String singleRepeatBookingInvoiceUrl = "/admin/booking/serviceman-fullbooking-single-invoice/";

  static const String sendOtpForForgetPassword = '/api/v1/member/lost-secret/transmit-pin';
  static const String verifyOtpForForgetPasswordScreen = '/api/v1/member/lost-secret/check-pin';
  static const String resetPasswordUri = '/api/v1/member/lost-secret/restore';
  static const String changeLanguage = '/api/v1/technician/locale-switch';
  static const String bookingStatisticDataUrl = '/api/v1/technician/overview/order-metrics';
  static const String updateLocationUrl = '/api/v1/technician/modify/position';


  // Shared Key
  static const String theme = 'demand_theme';
  static const String token = 'demand_token';
  static const String countryCode = 'demand_country_code';
  static const String languageCode = 'demand_language_code';
  static const String userPassword = 'demand_user_password';
  static const String userNumber = 'demand_user_number';
  static const String userCountryCode = 'demand_user_country_code';
  static const String notificationCount = 'demand_notification_count';
  static const String topic = 'provider-serviceman';
  static const String localizationKey = 'X-localization';
  static const String intro = 'intro';

  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.usa, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    LanguageModel(imageUrl: Images.arabic, languageName: 'عربى', countryCode: 'SA', languageCode: 'ar'),
    LanguageModel(imageUrl: Images.bn, languageName: 'বাংলা', countryCode: 'BD', languageCode: 'bn'),
    LanguageModel(imageUrl: Images.india, languageName: 'Hindi', countryCode: 'IN', languageCode: 'hi'),
  ];

  static const double maxLimitOfTotalFileSent = 5;

  /// Allowed image file extensions for upload
  static const List<String> allowedImageExtensions = [
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
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
