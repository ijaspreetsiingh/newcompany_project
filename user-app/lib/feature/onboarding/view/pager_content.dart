import 'package:jdds/feature/onboarding/controller/on_board_pager_controller.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class PagerContent extends StatelessWidget {
  const PagerContent({super.key, required this.image, required this.text, required this.subText});
  final String image;
  final String text;
  final String subText;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnBoardController>(builder: (onBoardingController) {
      bool isLastPage = onBoardingController.pageIndex == 2;
      final currentData = onBoardingController.onBoardPagerData[onBoardingController.pageIndex];
      final primaryColor = currentData["primaryColor"] as Color;
      final gradientColors = currentData["gradientColors"] as List<Color>;
      final orbColors = currentData["orbColors"] as List<Color>;

      // Image 60% / sheet 40% — white sheet + black text on all pages
      final double sheetHeight = Get.height * 0.40;
      final double imageHeight = Get.height - sheetHeight;
      final Color sheetColor = Colors.white;

      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
          ),

          Positioned(top: -80, left: -60, child: _buildOrb(280, orbColors[0], 0.4)),
          Positioned(top: 100, right: -70, child: _buildOrb(220, orbColors[1], 0.35)),
          Positioned(bottom: 250, left: -30, child: _buildOrb(160, orbColors[2], 0.3)),
          Positioned(top: 60, left: 100, child: _buildOrb(120, orbColors[3], 0.25)),
          Positioned(top: 200, left: 40, child: _buildOrb(80, orbColors[4], 0.3)),

          // Image: centered subject
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: imageHeight,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              width: Get.width,
              alignment: Alignment.center,
            ),
          ),

          // Fade: white-based gradient (avoid Colors.transparent → dark band artifact)
          Positioned(
            left: 0,
            right: 0,
            bottom: sheetHeight,
            height: 72,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.75),
                      Colors.white,
                    ],
                    stops: const [0.0, 0.4, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Badge/Skip already baked into image assets (1.png/2.png/3.png) — no overlay needed

          // Bottom sheet: FULL theme color + contrasting light text
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: sheetHeight,
            child: Container(
              decoration: BoxDecoration(
                color: sheetColor,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeDefault,
                    0,
                    Dimensions.paddingSizeDefault,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          "0${onBoardingController.pageIndex + 1} / 03",
                          style: robotoMedium.copyWith(fontSize: 12, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        text,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeOverLarge + 12,
                          color: Colors.black,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        subText,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeLarge + 1,
                          color: Colors.black.withValues(alpha: 0.55),
                          height: 1.5,
                        ),
                      ),

                      const Spacer(),

                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            onBoardingController.onBoardPagerData.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.only(
                                right: index < onBoardingController.onBoardPagerData.length - 1 ? 6 : 0,
                              ),
                              height: 7,
                              width: onBoardingController.pageIndex == index ? 24 : 7,
                              decoration: BoxDecoration(
                                color: onBoardingController.pageIndex == index
                                    ? primaryColor
                                    : Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              buttonText: "skip".tr,
                              fontSize: Dimensions.fontSizeLarge,
                              height: 54,
                              radius: 14,
                              backgroundColor: Colors.transparent,
                              transparent: false,
                              showBorder: true,
                              borderColor: Colors.black.withValues(alpha: 0.15),
                              textColor: Colors.black,
                              onPressed: () => _checkPermissionAndNavigate(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: CustomButton(
                              buttonText: isLastPage ? "${"get_started".tr} →" : "Continue →",
                              fontSize: Dimensions.fontSizeLarge,
                              height: 54,
                              radius: 14,
                              backgroundColor: primaryColor,
                              textColor: Colors.white,
                              onPressed: () {
                                if (isLastPage) {
                                  _checkPermissionAndNavigate();
                                } else {
                                  onBoardingController.pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildOrb(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

void _checkPermissionAndNavigate() async {
  Get.find<SplashController>().disableShowOnboardingScreen();
  Get.offAllNamed(RouteHelper.getMainRoute('home'));
}
