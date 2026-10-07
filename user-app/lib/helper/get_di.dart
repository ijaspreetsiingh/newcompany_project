import 'dart:convert';
import 'package:jdds/api/local/cache_response.dart';
import 'package:jdds/common/repo/data_sync_repo.dart';
import 'package:jdds/feature/auth/controller/facebook_login_controller.dart';
import 'package:jdds/feature/booking/controller/new_booking_controller.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

final database = AppDatabase();

Future<Map<String, Map<String, String>>> intt() async {

  final sharedPreferences = await SharedPreferences.getInstance();

  Get.lazyPut(() => sharedPreferences, fenix: true);

  /// Repository
  Get.lazyPut(() => DataSyncRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => CategoryRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => BannerRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => WebLandingRepo(apiClient: Get.find(), sharedPreferences:  Get.find()), fenix: true);
  Get.lazyPut(() => AdvertisementRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceRepo(apiClient:Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => CampaignRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => ProviderBookingRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => SplashRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => AuthRepo(sharedPreferences:Get.find(),apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => DataSyncRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => UserRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => CouponRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => CreatePostRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => CheckoutRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ConversationRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => CallRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => HtmlRepository(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => MyFavoriteRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => SearchRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => NotificationRepo(apiClient:Get.find() , sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceBookingRepo(sharedPreferences:Get.find(),apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => BookingDetailsRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);




  /// Controller
  Get.lazyPut(() => BannerController(bannerRepo: Get.find()));
  Get.lazyPut(() => CategoryController(categoryRepo: Get.find()));
  Get.lazyPut(() => WebLandingController(webLandingRepo: Get.find()));
  Get.lazyPut(() => AdvertisementController(advertisementRepo: Get.find()));
  Get.lazyPut(() => ServiceController(serviceRepo: Get.find()));
  Get.lazyPut(() => CampaignController( campaignRepo: Get.find()));
  Get.lazyPut(() => NearbyProviderController(providerBookingRepo: Get.find()));
  Get.lazyPut(() => ProviderBookingController(providerBookingRepo: Get.find()));
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(() => AuthController(authRepo: Get.find()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => UserController(userRepo: Get.find()));
  Get.lazyPut(() => BottomNavController());
  Get.lazyPut(() => LanguageController());
  Get.lazyPut(() => CouponController(couponRepo: Get.find()));
  Get.lazyPut(() => CreatePostController(createPostRepo: Get.find()));
  Get.lazyPut(() => CheckOutController(checkoutRepo: Get.find()));
  Get.lazyPut(() => ConversationController(conversationRepo: Get.find()));
  Get.lazyPut(() => CallController(callRepo: Get.find()), fenix: true);
  Get.lazyPut(() => HtmlViewController(htmlRepository: Get.find()));
  Get.lazyPut(() => MyFavoriteController(myFavoriteRepo: Get.find()));
  Get.lazyPut(() => AllSearchController(searchRepo: Get.find()));
  Get.lazyPut(() => NotificationController( notificationRepo: Get.find()));
  Get.lazyPut(() => ServiceBookingController(serviceBookingRepo: Get.find()), fenix: true);
  Get.lazyPut(() => BookingDetailsController(bookingDetailsRepo: Get.find()));
  Get.lazyPut(() => FacebookLoginController());
  Get.lazyPut(() => NewBookingController());


  Get.lazyPut(() => ApiClient(appBaseUrl: AppConstants.baseUrl, sharedPreferences: Get.find()), fenix: true);






  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => LocationController(locationRepo: LocationRepo(apiClient: Get.find(), sharedPreferences: Get.find())));
  Get.lazyPut(() => RadiusSearchController(locationRepo: LocationRepo(apiClient: Get.find(), sharedPreferences: Get.find())), fenix: true);
  Get.lazyPut(() => CartController(cartRepo: CartRepo(sharedPreferences:Get.find(),apiClient: Get.find())));
  Get.lazyPut(() => FriendLocationController(
        sharedPreferences: Get.find(),
        locationRepo: LocationRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
        cartRepo: CartRepo(sharedPreferences: Get.find(), apiClient: Get.find()),
      ), fenix: true);




  Get.lazyPut(() => ScheduleController(scheduleRepo: ScheduleRepo(apiClient: Get.find())));
  Get.lazyPut(() => ServiceAreaController(serviceAreaRepo: ServiceAreaRepo(apiClient: Get.find(), sharedPreferences: Get.find())));
  Get.lazyPut(() => ServiceDetailsController(serviceDetailsRepo: ServiceDetailsRepo(apiClient: Get.find())));


  Map<String, Map<String, String>> languages = {};
  for(LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues =  await rootBundle.loadString('assets/language/${languageModel.languageCode}.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    Map<String, String> jsonValue = {};
    mappedJson.forEach((key, value) {
      jsonValue[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] = jsonValue;
  }
  return languages;
}
