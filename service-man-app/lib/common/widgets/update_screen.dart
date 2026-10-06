import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class UpdateScreen extends StatefulWidget {
  final bool? isUpdate;

  const UpdateScreen({super.key, required this.isUpdate});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {

  bool _canExit = GetPlatform.isWeb ? true : false;

  void _onBackInvoked() {
    if(_canExit) {
      SystemNavigator.pop();
    }else {
      showCustomSnackBar('back_press_again_to_exit'.tr, type : ToasterMessageType.info);
      _canExit = true;
      Timer(const Duration(seconds: 2), () {
        _canExit = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      onPopInvoked: (){
        _onBackInvoked();
      },
      child: Scaffold(
        backgroundColor: context.kBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                Container(
                  width: 112,
                  height: 112,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.isUpdate! ? context.kPrimary : context.kMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isUpdate! ? Icons.download_outlined : Icons.build_outlined,
                    size: 46,
                    color: widget.isUpdate! ? context.kPrimaryForeground : context.kMutedForeground,
                  ),
                ),
                const SizedBox(height: 28),

                Text(widget.isUpdate! ? 'update_is_available'.tr : 'we_are_under_maintenance'.tr,
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(
                    fontSize: 30,
                    color: context.kForeground,
                  ),
                ),
                const SizedBox(height: 12),

                Text(widget.isUpdate! ? 'your_app_needs_to_update'.tr : 'we_will_be_right_back'.tr,
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                    fontSize: 14,
                    height: 1.7,
                    color: context.kMutedForeground,
                  ),
                ),

                if(widget.isUpdate!) ...[

                  const SizedBox(height: 28),

                  KButton(
                    label: 'update_now'.tr,
                    onTap: () async {
                      String appUrl = 'https://google.com';
                      if (GetPlatform.isAndroid) {
                        appUrl = Get.find<SplashController>().configModel?.content?.appUrlAndroid ?? "https://play.google.com/store/apps";
                      }
                      else if (GetPlatform.isIOS) {
                        appUrl = Get.find<SplashController>().configModel?.content?.appUrlIos ?? "https://www.apple.com/app-store/";
                      }
                      _launchUrl(Uri.parse(appUrl));
                    },
                  ),

                  const SizedBox(height: 8),

                  InkWell(
                    onTap: _onBackInvoked,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text('maybe_later'.tr,
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          fontSize: 14,
                          color: context.kMutedForeground,
                        ),
                      ),
                    ),
                  ),
                ],

              ]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}
