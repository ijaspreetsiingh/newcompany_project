import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with WidgetsBindingObserver {

  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkConfigAgain() {
    final SplashController splashController = Get.find<SplashController>();
    splashController.getConfigData().then((bool isSuccess) {
      if(isSuccess){
        final config = splashController.configModel!;
        if(config.content?.maintenanceMode?.maintenanceStatus == 0) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConfigAgain();
    }
  }

  @override
  Widget build(BuildContext context) {

    var configModel = Get.find<SplashController>().configModel?.content;

    return CustomPopScopeWidget(
      onPopInvoked: (){
        if(_canExit) {
          SystemNavigator.pop();
        }else {
          showCustomSnackBar('back_press_again_to_exit'.tr, type:  ToasterMessageType.info);
          _canExit = true;
          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: context.kBackground,
        body: SafeArea(
          child: Center(
            child: Container(
              width: Dimensions.webMaxWidth,
              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.03),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                Container(
                  width: 112,
                  height: 112,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.kMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.build_outlined,
                    size: 46,
                    color: context.kMutedForeground,
                  ),
                ),
                const SizedBox(height: 28),

                if(configModel != null) ... [

                  Text(configModel.maintenanceMode?.maintenanceMessages?.maintenanceMessage ?? "maintenance_title".tr,
                    textAlign: TextAlign.center,
                    style: robotoBold.copyWith(
                      fontSize: 30,
                      color: context.kForeground,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(configModel.maintenanceMode?.maintenanceMessages?.messageBody ?? "maintenance_subtitle".tr,
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        fontSize: 14,
                        height: 1.7,
                        color: context.kMutedForeground,
                      ),
                    ),
                  ),

                  if(configModel.maintenanceMode?.maintenanceMessages?.businessEmail == 1 ||
                      configModel.maintenanceMode?.maintenanceMessages?.businessNumber == 1) ...[

                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: context.kBorder,
                    ),
                    const SizedBox(height: 16),

                    Text(configModel.maintenanceMode?.maintenanceMessages?.businessEmail == 1 && configModel.maintenanceMode?.maintenanceMessages?.businessNumber == 1
                        ? 'any_query_feel_free_to_call_or_email'.tr : configModel.maintenanceMode?.maintenanceMessages?.businessEmail == 1
                        ? "any_query_feel_free_to_email".tr : "any_query_feel_free_to_call".tr,
                      textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(
                        fontSize: 13,
                        color: context.kMutedForeground,
                      ),
                    ),

                    if(configModel.maintenanceMode?.maintenanceMessages?.businessNumber == 1) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: (){
                          launchUrl(Uri.parse(
                            'tel:${configModel.businessPhone ?? ""}',
                          ), mode: LaunchMode.externalApplication);
                        },
                        child: Text(configModel.businessPhone ?? "",
                          textAlign: TextAlign.center,
                          style: robotoMedium.copyWith(
                            color: context.kPrimary,
                            fontSize: Dimensions.fontSizeDefault,
                            decoration: TextDecoration.underline,
                            decorationColor: context.kPrimary,
                          ),
                        ),
                      ),
                    ],

                    if(configModel.maintenanceMode?.maintenanceMessages?.businessEmail == 1) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: (){
                          launchUrl(Uri.parse(
                            'mailto :${configModel.businessEmail ?? ""}',
                          ), mode: LaunchMode.externalApplication);
                        },
                        child: Text(configModel.businessEmail ?? "",
                          textAlign: TextAlign.center,
                          style: robotoMedium.copyWith(
                            color: context.kPrimary,
                            fontSize: Dimensions.fontSizeDefault,
                            decoration: TextDecoration.underline,
                            decorationColor: context.kPrimary,
                          ),
                        ),
                      ),
                    ],
                  ]
                ],

                const SizedBox(height: 28),

                Center(
                  child: KButton(
                    label: 'check_again'.tr,
                    icon: Icons.refresh_rounded,
                    expanded: false,
                    onTap: _checkConfigAgain,
                  ),
                ),

              ]),
            ),
          ),
        ),
      ),
    );
  }
}
