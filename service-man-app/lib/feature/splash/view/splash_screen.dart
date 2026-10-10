import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';


class SplashScreen extends StatefulWidget {
  final NotificationBody? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  double opacity = 0.5;

  late final AnimationController _entranceController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final AnimationController _loaderController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();
    _logoScale = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    ).drive(Tween<double>(begin: 0.88, end: 1));
    _logoFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if(!firstTime) {
        bool isNotConnected = result.first != ConnectivityResult.wifi && result.first != ConnectivityResult.mobile;
        isNotConnected ? const SizedBox() : ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection'.tr : 'connected'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if(!isNotConnected) {
          _route();
        }
      }
      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    _route();
  }

  @override
  void dispose() {
    _onConnectivityChanged?.cancel();
    _entranceController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  void _route() {
    Future.delayed(const Duration(milliseconds: 500),(){
      setState(() {
        opacity = 1;
      });
    });

    Get.find<SplashController>().getConfigData().then((isSuccess) {
      if(isSuccess){

        PriceConverter.getCurrency(Get.context!);

        Timer(const Duration(seconds: 1), () async {
          if(_checkAvailableUpdate()) {
            Get.offNamed(RouteHelper.getUpdateRoute(true));
          }
          else if(_checkMaintenanceModeActive() && !AppConstants.avoidMaintenanceMode){
            Get.offAllNamed(RouteHelper.getMaintenanceRoute());
            Get.find<AuthController>().unsubscribeToken();
          }
          else if(widget.body != null){
            _notificationRoute();
          }
          else{

            if( await _checkLanguageScreen() == true) {
              Get.offNamed(RouteHelper.getLanguageRoute());
            } else if(Get.find<AuthController>().isLoggedIn()){
              Get.offNamed(RouteHelper.getInitialRoute());
            }else{
              Get.offAllNamed(RouteHelper.getSignInRoute("LogIn"));
            }

          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kPrimary,
      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 500),
          child: splashController.hasConnection
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: context.kPrimary,
                  child: SafeArea(
                    child: Center(
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoFade,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: context.kPrimaryForeground,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.build_outlined,
                                  size: 38,
                                  color: context.kPrimary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                AppConstants.appName,
                                textAlign: TextAlign.center,
                                style: robotoBold.copyWith(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: context.kPrimaryForeground,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Service Partner',
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  fontSize: 14,
                                  color: context.kPrimaryForeground
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 40),
                              _loaderBar(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : NoInternetScreen(child: SplashScreen(body: widget.body)),
        );
      }),
    );
  }

  Widget _loaderBar(BuildContext context) {
    return Container(
      width: 80,
      height: 4,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.kPrimaryForeground.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedBuilder(
          animation: _loaderController,
          builder: (context, _) {
            final double t = Curves.easeInOut.transform(_loaderController.value);
            return Transform.translate(
              offset: Offset(-32 + 96 * t, 0),
              child: Container(
                width: 32,
                height: 4,
                color: context.kPrimaryForeground,
              ),
            );
          },
        ),
      ),
    );
  }

  bool _checkAvailableUpdate (){
    ConfigModel? configModel = Get.find<SplashController>().configModel;
    final localVersion = Version.parse(AppConstants.appVersion);
    final serverVersion = Version.parse(GetPlatform.isAndroid
        ? configModel?.content?.minimumVersion?.minVersionForAndroid ?? ""
        :  configModel?.content?.minimumVersion?.minVersionForIos ?? ""
    );
    return localVersion.compareTo(serverVersion) == -1;
  }

  bool _checkMaintenanceModeActive(){
    final ConfigModel? configModel = Get.find<SplashController>().configModel;
    return (configModel?.content?.maintenanceMode?.maintenanceStatus == 1 && configModel?.content?.maintenanceMode?.selectedMaintenanceSystem?.servicemanApp == 1);
  }

  void _notificationRoute(){

    String notificationType = widget.body?.notificationType ?? "";

    switch(notificationType) {
      case "chatting": {
        Get.offAllNamed(RouteHelper.getInboxScreenRoute(fromNotification: "fromNotification"));
      } break;

      case "booking": {
        if( widget.body!.bookingId!=null&& widget.body!.bookingId!=""){
          Get.offAllNamed(RouteHelper.getBookingDetailsRoute( bookingId : widget.body!.bookingId!, fromPage :'fromNotification', isSubBooking: widget.body?.bookingType == "repeat"));
        }else{
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      } break;

      case "privacy_policy": {
        Get.offAllNamed(RouteHelper.getHtmlRoute(HtmlType.privacyPolicy.value));
      } break;

      case "terms_and_conditions": {
        Get.offAllNamed(RouteHelper.getHtmlRoute(HtmlType.termsAndCondition.value));
      } break;

      default: {
        Get.offAllNamed(RouteHelper.getNotificationRoute());
      } break;
    }
  }

  Future<bool?> _checkLanguageScreen() async {

    bool? status;

    if( Get.find<SplashController>().showIntro()!){
      List<Language>  adminLanguageList = Get.find<SplashController>().configModel?.content?.languageList ?? [];

      List<String> localLanguageCode = [];
      for (var element in AppConstants.languages) {
        localLanguageCode.add(element.languageCode!);
      }
      if( adminLanguageList.length == 1 && localLanguageCode.contains(adminLanguageList[0].languageCode)){

        int index = AppConstants.languages.indexWhere((element) => element.languageCode == adminLanguageList[0].languageCode);

        if(index != -1){
          Locale locale = Locale( AppConstants.languages[index].languageCode!,AppConstants.languages[index].countryCode);

          Future.delayed(const Duration(milliseconds: 100), (){
            Get.find<LocalizationController>().setLanguage(locale, isInitial: true);
            status = false;
          });
        }

      }else{
        status = true;
      }
    }else{
      status = false;
    }

    return status;
  }
}
