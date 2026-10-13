import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:jassdbx_serviceman/feature/html/repository/html_repo.dart';
import 'package:jassdbx_serviceman/feature/notifications/repository/notification_repo.dart';
import 'package:get/get.dart';


Future<Map<String, Map<String, String>>> init() async{

  /// Core
  final sharedPreferences = await SharedPreferences.getInstance();

  // W3.18: token plaintext prefs → secure storage migration
  try {
    const secure = FlutterSecureStorage();
    String? token = await secure.read(key: AppConstants.token);
    token ??= sharedPreferences.getString(AppConstants.token);
    if (token != null && token.isNotEmpty) {
      await secure.write(key: AppConstants.token, value: token);
    }
    AuthRepo.tokenCache = (token != null && token.isNotEmpty) ? token : null;
    await sharedPreferences.remove(AppConstants.token);
  } catch (_) {
    AuthRepo.tokenCache = sharedPreferences.getString(AppConstants.token);
  }

  Get.lazyPut(() => sharedPreferences, fenix: true);
  Get.lazyPut(() => ApiClient(appBaseUrl: AppConstants.baseUrl, sharedPreferences: Get.find()), fenix: true);


  /// Repository
  Get.lazyPut(() => SplashRepo(sharedPreferences: Get.find(), apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => DashboardRepository(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ConversationRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => CallRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => NotificationRepo(apiClient:  Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => BookingRequestRepo(apiClient: Get.find()), fenix: true);
  // AUTO-ASSIGN popup FCM se kabhi bhi khulta hai (booking details screen
  // ke binding ke bina) — isliye repo globally chahiye, warna crash:
  // "BookingDetailsRepo" not found.
  Get.lazyPut(() => BookingDetailsRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => UserRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => HtmlRepository(apiClient: Get.find()), fenix: true);


  /// Controller
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => AuthController(authRepo: Get.find()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => DashboardController(dashboardRepository: Get.find()));
  Get.lazyPut(() => ConversationController(conversationRepo: Get.find()));
  Get.lazyPut(() => CallController(callRepo: Get.find()), fenix: true);
  Get.lazyPut(() => NotificationController(notificationRepo: Get.find()));
  Get.lazyPut(() => BookingRequestController(bookingRequestRepo: Get.find()));
  Get.lazyPut(() => RecheckController(bookingRequestRepo: Get.find()));
  Get.lazyPut(() => UserController(userRepo: Get.find()));
  Get.lazyPut(() => HtmlViewController(htmlRepository: Get.find()));
  Get.lazyPut(() => LocationService());


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
