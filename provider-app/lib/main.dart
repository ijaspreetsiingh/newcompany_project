
import 'package:jassdbx_provider/feature/tutorial/controller/tutorial_controller.dart';
import 'package:jassdbx_provider/feature/tutorial/widgets/tutorial_button_widget.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'feature/nav/widgets/cash_overflow_dialog.dart';
import 'helper/get_di.dart';


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

AndroidNotificationChannel? channel1;
AndroidNotificationChannel? channel2;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  try{
     if(Platform.isAndroid) {
      try {
        await Firebase.initializeApp(
          ///todo you need to configure that firebase Option with your own firebase to run your app
          ///Go to android/app/google-services.json and find those key and added in below
          options: const FirebaseOptions(
            apiKey: "AIzaSyD8PuTDJaGxlkl9vtZxzGHMpIbyGTXep7A", ///current_key here
            appId: "1:418974405325:android:5e9e61aefd909c213b0f84", ///mobilesdk_app_id here
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
  }catch(e) {
    if (kDebugMode) {
      print('Error initializing Flutter bindings: ${e.toString()}');
    }
  }

  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  // Android 13+ notification permission (wrna tray me kuch nahi dikhega)
  if (GetPlatform.isMobile) {
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (_) {}
  }

  Map<String, Map<String, String>> languages = await init();
  NotificationBody? body;

  try {
    // Pehle notification handlers register karo — pehle getInitialMessage ke
    // baad tha, uske throw karne par initialize/onBackgroundMessage kabhi
    // call hi nahi hote the (notification dead)
    if (GetPlatform.isMobile) {
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

      // FCM token rotate hone par turant backend update
      FirebaseMessaging.instance.onTokenRefresh.listen((_) {
        try {
          if (Get.find<AuthRepo>().isLoggedIn()) {
            Get.find<AuthRepo>().updateToken();
          }
        } catch (_) {}
      });

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
      InkColors.setDarkMode(themeController.darkTheme);
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetMaterialApp(
          routingCallback: (route){
            Get.find<TutorialController>().onChangeBottomSheetStatus((route?.isBottomSheet ?? false) || (route?.isDialog ?? false));
          },

          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: Get.key,
          theme: themeController.darkTheme ? dark : light,
          locale: localizeController.locale,
          translations: Messages(languages: languages),
          initialRoute: RouteHelper.getSplashRoute(body: body,),
          getPages: RouteHelper.routes,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 500),
          builder: (context, widget) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(MediaQuery.sizeOf(context).width < 380 ?  0.9 : 1)),
            child: _GlobalScrollListener(
              child: Material(
                child: SafeArea(
                  top: false,
                  bottom: GetPlatform.isAndroid,
                  child: Stack(children: [

                    widget!,

                    GetBuilder<UserProfileController>(builder: (userProfileController){

                      double receivableAmount = double.tryParse(userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountReceivable ?? "0" ) ?? 0;
                      double payableAmount = double.tryParse(userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountPayable ?? "0") ?? 0 ;

                      TransactionType transactionType =  userProfileController.getTransactionType(payableAmount, receivableAmount);
                      double transactionAmount =  userProfileController.getTransactionAmountAmount(payableAmount, receivableAmount);

                      double payablePercent =  userProfileController.providerModel != null ?
                      userProfileController.getOverflowPercent(payableAmount, receivableAmount, Get.find<SplashController>().configModel.content?.maxCashInHandLimit?? 0) : 0;

                      bool overFlowDialogStatus = userProfileController.showOverflowDialog && userProfileController.providerModel != null &&
                          Get.find<SplashController>().configModel.content?.suspendOnCashInHandLimit == 1 &&  Get.find<SplashController>().configModel.content?.digitalPayment == 1;

                      return  SafeArea(
                        child: Align(alignment: Alignment.bottomRight,
                          child: Padding(padding: const EdgeInsets.only(bottom: 90),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                (transactionType == TransactionType.payable || transactionType == TransactionType.adjustAndPayable ||  transactionType == TransactionType.adjust)
                                    && ( payablePercent >= 80  && overFlowDialogStatus) && !userProfileController.trialWidgetNotShow
                                    ?  CashOverflowDialog(payablePercent: payablePercent,amount: transactionAmount,) : const SizedBox()
                              ],
                            ),
                          ),
                        ),
                      );
                    }),


                    TutorialButtonWidget(),



                  ]),
                ),
              ),
            ),
          ),
        );
      },
      );
    },
    );
  }
}




class _GlobalScrollListener extends StatelessWidget {
  final Widget child;

  const _GlobalScrollListener({required this.child});

  @override
  Widget build(BuildContext context) {
    bool isUserScrolling = false;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final tutorialController = Get.find<TutorialController>();

        if (notification is ScrollStartNotification) {
          tutorialController.setVisibility(false);

        }else if (notification is ScrollEndNotification) {
          tutorialController.setVisibility(true);
        }

        if (notification is UserScrollNotification) {
          isUserScrolling = notification.direction != ScrollDirection.idle;
        }

        if(notification.metrics.pixels >= notification.metrics.maxScrollExtent && isUserScrolling) {
          tutorialController.setVisibility(false);
        }

        return false;
      },
      child: child,
    );
  }
}