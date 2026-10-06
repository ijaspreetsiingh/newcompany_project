import 'package:jdds/util/core_export.dart';

class AppConstants {


  static const String appName = 'Jass Booking';
  static const String shortAppName = 'JS';
  static const String appVersion = '3.7'; /// Flutter SDK : 3.38.9
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String websiteUrl =  'http://localhost:5000'; // Local web development
  static const String googleServerClientId = 'YOUR_CLIENT_ID_HERE'; /// find that in android/app/google-services.json || use client_type 3
  static const bool avoidMaintenanceMode = false;
  static const LocalCachesTypeEnum cachesType = LocalCachesTypeEnum.all;
  static const String categoryUrl = '/api/v1/client/group?limit=20';
  static const String webLandingContents = '/api/v1/client/frontpage/blocks';
  static const String bannerUri = '/api/v1/client/carousel?limit=10&offset=1';
  static const String bonusUri = '/api/v1/client/incentive-list?limit=100&offset=1';
  static const String allServiceUri = '/api/v1/client/task';
  static const String popularServiceUri = '/api/v1/client/task/hot';
  static const String trendingServiceUri = '/api/v1/client/task/rising';
  static const String recentlyViewedServiceUri = '/api/v1/client/task/last-seen';
  static const String recommendedServiceUri = '/api/v1/client/task/suggested';
  static const String recommendedSearchUri = '/api/v1/client/task/lookup/suggested';
  static const String offerListUri = '/api/v1/client/task/deals';
  static const String serviceBasedOnSubcategory = '/api/v1/client/task/child-group/';
  static const String itemsBasedOnCampaignId = '/api/v1/client/drive/records/entries?campaign_id=';
  static const String serviceDetailsUri = '/api/v1/client/task/info';
  static const String getServiceReviewList = '/api/v1/client/task/feedback/';
  static const String subcategoryUri = '/api/v1/client/group/subgroups?limit=20&offset=1&slug=';
  static const String categoryServiceUri = '/api/v1/groups/task/';
  static const String configUri = '/api/v1/client/setup';
  static const String providerPaymentConfigUri = '/api/v1/client/setup/payment-config';
  static const String customerRemove = '/api/v1/client/account-delete';
  static const String registerUri = '/api/v1/client/access/signup';
  static const String loginUri = '/api/v1/client/access/signin';
  static const String loginOut = '/api/v1/client/access/signout';
  static const String addToCart = '/api/v1/client/basket/insert';
  static const String getCartList = '/api/v1/client/basket/index?limit=100&offset=1';
  static const String removeCartItem = '/api/v1/client/basket/delete/';
  static const String removeAllCartItem = '/api/v1/client/basket/records/wipe';
  static const String updateCartQuantity = '/api/v1/client/basket/modify-count/';
  static const String updateCartProvider = '/api/v1/client/basket/modify/partner';
  static const String tokenUri = '/api/v1/client/modify/push-key';
  static const String bookingList = '/api/v1/client/order';
  static const String bookingDetails = '/api/v1/client/order';
  static const String subBookingDetails = '/api/v1/client/order/individual';
  static const String repeatBookingDetails = '/api/v1/client/order/recurring';
  static const String trackBooking = '/api/v1/client/order/trace';
  static const String bookingCancel = '/api/v1/client/order/state-change';
  static const String recheckRequest = '/api/v1/client/order/recheck';
  static const String recheckStatus = '/api/v1/client/order/recheck-status';
  static const String subBookingCancel = '/api/v1/client/order/individual-recurring-abort';
  static const String serviceReview = '/api/v1/client/feedback/dispatch';
  static const String bookingReviewList = '/api/v1/client/feedback';
  static const String otherInfo = '/api/v1/client/basket/extra-notes';
  static const String placeRequest = '/api/v1/client/order/submission/transmit';
  static const String addressUri = '/api/v1/client/place';
  static const String zoneUri = '/api/v1/client/setup/fetch-region-id';
  static const String customerInfoUri = '/api/v1/client/dossier';
  static const String couponUri = '/api/v1/client/promo?limit=100&offset=1';
  static const String applyCoupon = '/api/v1/client/promo/redeem';
  static const String removeCoupon = '/api/v1/client/promo/delete';
  static const String orderCancelUri = '/api/v1/client/purchase/abort';
  static const String codSwitchUri = '/api/v1/client/purchase/pay-mode';
  static const String orderDetailsUri = '/api/v1/client/purchase/breakdown?order_id=';
  static const String notificationUri = '/api/v1/client/alerts';
  static const String updateProfileUri = '/api/v1/client/modify/account';
  static const String searchUri = '/api/v1/client/task/lookup';
  static const String searchSuggestion = '/api/v1/client/task/lookup-hints';
  static const String suggestedSearchUri = '/api/v1/client/latest-query-terms';
  static const String removeSuggestedServiceUri = '/api/v1/client/drop-query-terms';
  static const String campaignUri = '/api/v1/client/drive?limit=10&offset=1';
  static const String searchLocationUri = '/api/v1/client/setup/geo-suggest';
  static const String placeDetailsUri = '/api/v1/client/setup/geo-spot-facts';
  static const String geocodeUri = '/api/v1/client/setup/geo-coder';
  static const String socialLoginUri = '/api/v1/client/access/signin-via-social';
  static const String updateZoneUri = '/api/v1/client/modify-region';
  static const String createChannel = '/api/v1/client/inbox/open-thread';
  static const String getChannelListUrl = '/api/v1/client/inbox/thread-index';
  static const String searchChannelListUrl = '/api/v1/client/inbox/thread-lookup';
  static const String getConversation = '/api/v1/client/inbox/thread';
  static const String sendMessage = '/api/v1/client/inbox/transmit-note';
  static const String pagesDetailsApi = '/api/v1/client/setup/page-facts';
  static const String submitNewServiceRequest = '/api/v1/client/task/submission/raise';
  static const String getSuggestedServiceList = '/api/v1/client/task/submission/index';
  static const String convertLoyaltyPointUri = '/api/v1/client/reward-points/purse-move';
  static const String loyaltyPointTransactionData = '/api/v1/client/reward-points-ledger';
  static const String walletTransactionData = '/api/v1/client/purse-ledger';
  static const String getProviderList = '/api/v1/client/partner/index';
  static const String searchRadiusUri = '/api/v1/client/partner/search-radius';
  static const String getProviderDetails = '/api/v1/client/partner-facts';
  static const String getProviderBasedOnSubcategory = '/api/v1/client/partner/index-by-childgroup';
  static const String getFeaturedCategoryService = '/api/v1/client/spotlight-groups?limit=100&offset=1';

  static const String createCustomizedPost = '/api/v1/client/listing';
  static const String getMyPostList = '/api/v1/client/listing';
  static const String getInterestedProviderList = '/api/v1/client/listing/offer';
  static const String updatePostStatus = '/api/v1/client/listing/offer/modify-state';
  static const String getPostDetails = '/api/v1/client/listing/breakdown';
  static const String updatePostInfo = '/api/v1/client/listing/modify-facts';
  static const String getProviderBidDetails = '/api/v1/client/listing/offer/breakdown';

  static const String sendOtpForVerification = '/api/v1/member/validation/transmit-pin';
  static const String sendOtpForForgetPassword = '/api/v1/member/lost-secret/transmit-pin';
  static const String verifyOtpForForgetPasswordScreen = '/api/v1/member/lost-secret/check-pin';
  static const String verifyOtpForVerificationScreen = '/api/v1/member/validation/check-pin';
  static const String phoneOtpVerification= '/api/v1/member/validation/signin-pin-check';
  static const String firebaseOtpVerify = '/api/v1/member/validation/firebase-access-check';
  static const String registerWithOtp = '/api/v1/member/validation/signup-with-pin';
  static const String resetPasswordUri = '/api/v1/member/lost-secret/restore';

  static const String offlinePaymentUri = '/api/v1/client/cash-settlement/options?limit=100&offset=1';
  static const String getZoneListApi = '/api/v1/client/task/zone-availability?offset=1&limit=200';
  static const String rebookApi = '/api/v1/client/reorder/basket-attach';
  static const String rebookAvailabilityApi = '/api/v1/client/reorder-facts?limit=100&offset=1';
  static const String changeLanguage = '/api/v1/client/locale-switch';

  static const String getFavoriteServiceList = '/api/v1/client/saved/task-index';
  static const String removeFavoriteService = "/api/v1/client/saved/task-remove";
  static const String updateFavoriteServiceStatus = "/api/v1/client/saved/task";
  static const String getFavoriteProviderList = '/api/v1/client/saved/partner-index';
  static const String removeFavoriteProvider = "/api/v1/client/saved/partner-remove";
  static const String updateFavoriteProviderStatus = "/api/v1/client/saved/partner";

  static const String advertisementList = '/api/v1/client/showcases/showcase-feed?limit=50&offset=1';
  static const String registerWithSocialMedia = '/api/v1/client/access/signup-via-social';
  static const String existingAccountCheck = '/api/v1/client/access/account-probe';
  static const String regularBookingInvoiceUrl = '/admin/booking/customer-invoice/';
  static const String repeatBookingInvoiceUrl = '/admin/booking/customer-fullbooking-invoice/';
  static const String singleRepeatBookingInvoiceUrl = '/admin/booking/customer-fullbooking-single-invoice/';
  static const String addError404Url = '/api/v1/client/broken-link';
  static const String checkExistingUser = '/api/v1/member/verify-member-exists';
  static const String offlinePaymentDataStore = '/api/v1/client/order/persist-cash-record';
  static const String switchPaymentMethod = '/api/v1/client/order/change-pay-mode';
  static const String digitalPaymentResponse = '/api/v1/gateway-booking-reply';
  static const String newsLetterSubscription = '/api/v1/client/join-bulletin';
  static const String subscribeToTopic = '/api/v1/client/alert-enroll-topic';



  /// Shared Key
  static const String theme = 'demand_theme';
  static const String token = 'demand_token';
  static const String guestId = 'guest_id';
  static const String countryCode = 'demand_country_code';
  static const String languageCode = 'demand_language_code';
  static const String acceptCookies = 'demand_accept_cookies';
  static const String userPassword = 'demand_user_password';
  static const String userAddress = 'demand_user_address';
  static const String userNumber = 'demand_user_number';
  static const String userCountryCode = 'demand_user_country_code';
  static const String notification = 'demand_notification';
  static const String searchHistory = 'demand_search_history';
  static const String notificationCount = 'demand_notification_count';
  static const String inttialLanguage = 'inttial-language';
  static const String onboardingScreen = 'onboarding_screen';
  static const String cookiesManagement = 'cookies_management';
  static const String topic = 'customer';
  static const String zoneId = 'zoneId';
  static const String localizationKey = 'X-localization';
  static const String walletAccessToken = 'wallet_access_token';
  static const String isContinueZone = 'isContinue';
  static const String referredBottomSheet = 'referred_bottom_sheet';
  static const String lastIncompleteOfflineBookingId = 'last_incomplete_offline_booking_id';


  static Map<String, String> configHeader = {
    'Content-Type': 'application/json; charset=UTF-8',
    AppConstants.zoneId : 'configuration',
  };

  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.us, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    LanguageModel(imageUrl: Images.ar, languageName: 'Ø¹Ø±Ø¨Ù‰', countryCode: 'SA', languageCode: 'ar'),
    LanguageModel(imageUrl: Images.bn, languageName: 'à¦¬à¦¾à¦‚à¦²à¦¾', countryCode: 'BD', languageCode: 'bn'),
    LanguageModel(imageUrl: Images.india, languageName: 'Hindi', countryCode: 'IN', languageCode: 'hi'),
  ];


  static const int limitOfPickedIdentityImageNumber = 2;
  static const double balanceInputLength = 10;

  static const double maxLimitOfTotalFileSent = 5;

  static final List<Map<String, String>> walletTransactionSortingList = [
    {
      'title' : 'all_transactions',
      'value' : ''
    },
    {
      'title' : 'booking_transaction',
      'value' : 'wallet_payment'
    },
    {
      'title' : 'converted_from_loyalty_point',
      'value' : 'loyalty_point_earning'
    },
    {
      'title' : 'added_via_payment_method',
      'value' : 'add_fund'
    },
    {
      'title' : 'earned_by_bonus',
      'value' : 'add_fund_bonus'
    },
    {
      'title' : 'earned_by_referral',
      'value' : 'referral_earning'
    },
    {
      'title' : 'admin_fund',
      'value' : 'fund_by_admin'
    },
    {
      'title' : 'refund',
      'value' : 'booking_refund'
    },
  ];

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


