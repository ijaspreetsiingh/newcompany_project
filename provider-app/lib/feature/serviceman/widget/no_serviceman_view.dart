import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class NoServicemanView extends StatelessWidget {
  const NoServicemanView({super.key});

  void _addServiceman() {
    Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial){
      if(isTrial){
        Get.find<ServicemanSetupController>().controller!.index = 0;
        Get.find<ServicemanSetupController>().getSingleServicemanData(index: -1, fromPage: "others");
        Get.find<ServicemanSetupController>().clearAllData();
        Get.find<ServicemanSetupController>().resetOtherValidationData();
        Get.to(()=>const AddNewServicemanScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Image.asset(Images.noServicemanIcon, height: 64, width: 64),

            const SizedBox(height: 20),

            Text("no_serviceman_title".tr, textAlign: TextAlign.center,
              style:  TextStyle(fontSize: 17, height: 1.3, fontWeight: FontWeight.w700, color: InkColors.foreground),
            ),

            const SizedBox(height: 8),

            Text("no_serviceman_subtitle".tr, textAlign: TextAlign.center,
              style:  TextStyle(fontSize: 13, height: 1.5, color: InkColors.mutedForeground),
            ),

            const SizedBox(height: 24),

            InkPrimaryButton(label: "add_serviceman".tr, onTap: _addServiceman),

          ],
        ),
      ),
    );
  }
}
