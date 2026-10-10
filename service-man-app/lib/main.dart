import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:jassdbx_serviceman/theme/ios27_theme.dart';
import 'helper/get_di.dart' as di;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(GetPlatform.isAndroid) {
    try {
      await Firebase.initializeApp(
        ///todo you need to configure that firebase Option with your own firebase to run your app
        ///Go to android/app/google-services.json and find those key and added in below
        options: const FirebaseOptions(
          apiKey: "AIzaSyD8PuTDJaGxlkl9vtZxzGHMpIbyGTXep7A", ///current_key here
          appId: "1:418974405325:android:80ab96be5f0fed743b0f84", ///mobilesdk_app_id here
          messagingSenderId: "418974405325", ///project_number here
          projectId: "newcompany-ebf01", ///project_id her
        ),
      );
    }catch(e) {
      await Firebase.initializeApp();

    }
  } else {
    await Firebase.initializeApp();
  }

  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  // Android 13+ par notification permission warna tray me kuch nahi dikhega
  if (GetPlatform.isMobile) {
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (_) {}
  }


  Map<String, Map<String, String>> languages = await di.init();
  await WorkStatusService.init();
  NotificationBody? body;

  try {
    await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

    // FCM token rotate hone par turant backend me update (warna push band)
    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      try {
        if (Get.find<AuthRepo>().isLoggedIn()) {
          Get.find<AuthRepo>().updateToken();
        }
      } catch (_) {}
    });

    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
        final Map<String, dynamic> initialPushData = Map<String, dynamic>.from(remoteMessage.data);
        Future.delayed(const Duration(milliseconds: 3000), () {
          try {
            if ((initialPushData['type'] ?? '').toString().startsWith('call')) {
              NotificationHelper.handleCallNotificationTap(initialPushData);
            }
          } catch (_) {}
        });
      }
    }
  }catch(e) {
    if (kDebugMode) {
      print("");
    }
  }

  runApp(MyApp(languages: languages, body: body));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBody? body;
  const MyApp({super.key, required this.languages, required this.body});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: Get.key,
          theme: themeController.darkTheme ? Ios27Theme.dark() : Ios27Theme.light(),
          locale: localizeController.locale,
          translations: Messages(languages: languages),
          fallbackLocale: Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode),
          initialRoute: RouteHelper.getSplashRoute(body : body),
          getPages: RouteHelper.routes,
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 350),
          builder: (context, widget) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(MediaQuery.sizeOf(context).width < 380 ?  0.9 : 1)),
            child: Material(
              child: SafeArea(
                top: false,
                bottom: GetPlatform.isAndroid,
                child: Stack(children: [
                  widget!,
                ]),
              ),
            ),
          ),
        );
      });
    });
  }
}
