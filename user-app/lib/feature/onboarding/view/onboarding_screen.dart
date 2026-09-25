import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/feature/onboarding/controller/on_board_pager_controller.dart';

class OnBoardingScreen extends GetView<OnBoardController> {
  const OnBoardingScreen({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GetBuilder<OnBoardController>(builder: (onBoardingController){
          return PageView.builder(
            onPageChanged: (value) {
              controller.onPageChanged(value);
            },
            controller: onBoardingController.pageController,
            itemCount: onBoardingController.onBoardPagerData.length,
            itemBuilder: (context, index) => PagerContent(
              image: onBoardingController.onBoardPagerData[index]["image"]!,
              text: onBoardingController.onBoardPagerData[index]["text"]!,
              subText: onBoardingController.onBoardPagerData[index]["subTitle"]!,
            ),
          );
        }),
      ),
    );
  }
}
