import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

class LanguageScreen extends StatefulWidget {
  final String? fromPage;
  const LanguageScreen({super.key, this.fromPage});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> with TickerProviderStateMixin {
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    Get.find<LocalizationController>().filterLanguage(shouldUpdate: false, isChooseLanguage: true, fromPage: widget.fromPage);
    _blobController = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      isExit: true,
      child: Scaffold(
        backgroundColor: const Color(0xffFFF5EE),
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
        endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        body: GetBuilder<LocalizationController>(
          builder: (localizationController) {
            return AnimatedBuilder(
              animation: _blobController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LiquidBlobPainter(animation: _blobController),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                if (widget.fromPage != "fromSettingsPage")
                                  Center(
                                    child: Container(
                                      height: 45,
                                      width: 160,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('assets/images/logo.png'),
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 40),
                                Text(
                                  'Select Language',
                                  style: robotoBold.copyWith(fontSize: 26, color: const Color(0xff101828)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Choose your preferred language to continue',
                                  style: robotoRegular.copyWith(fontSize: 14, color: const Color(0xff98A2B3)),
                                ),
                                const SizedBox(height: 30),
                                GridView.builder(
                                  padding: EdgeInsets.zero,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.1,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                  ),
                                  itemCount: localizationController.languages.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    bool isSelected = localizationController.selectedIndex == index;
                                    return GestureDetector(
                                      onTap: () => localizationController.setSelectIndex(index),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xffFF6B2C).withValues(alpha: 0.12)
                                              : Colors.white.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xffFF6B2C)
                                                : Colors.white.withValues(alpha: 0.5),
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.04),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: BackdropFilter(
                                            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.white.withValues(alpha: 0.7),
                                                          border: Border.all(
                                                            color: isSelected
                                                                ? const Color(0xffFF6B2C).withValues(alpha: 0.3)
                                                                : const Color(0xffE4E7EC),
                                                          ),
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(50),
                                                          child: Image.asset(
                                                            localizationController.languages[index].imageUrl!,
                                                            width: 34,
                                                            height: 34,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Text(
                                                        localizationController.languages[index].languageName!,
                                                        style: robotoMedium.copyWith(
                                                          fontSize: 14,
                                                          color: const Color(0xff101828),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Positioned(
                                                    top: 10,
                                                    right: 10,
                                                    child: Container(
                                                      height: 24,
                                                      width: 24,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xffFF6B2C),
                                                      ),
                                                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'You can change language later from settings',
                                  style: robotoRegular.copyWith(
                                    fontSize: 12,
                                    color: const Color(0xff98A2B3),
                                  ),
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: GetBuilder<LocalizationController>(
          builder: (localizationController) {
            return Container(
              padding: const EdgeInsets.fromLTRB(25, 12, 25, 25),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.0),
              ),
              child: CustomButton(
                onPressed: () {
                  Get.find<SplashController>().disableShowInitialLanguageScreen();
                  localizationController.setLanguage(
                    Locale(
                      localizationController.languages[localizationController.selectedIndex].languageCode!,
                      localizationController.languages[localizationController.selectedIndex].countryCode,
                    ),
                    isInitial: true,
                  );
                  if (Get.find<SplashController>().isShowOnboardingScreen() && !kIsWeb) {
                    Get.offNamed(RouteHelper.onBoardScreen);
                  } else {
                    Get.find<SplashController>().getConfigData();
                    HomeScreen.loadData(true);
                    Get.offAllNamed(RouteHelper.getMainRoute("home"));
                  }
                },
                buttonText: 'Continue',
                backgroundColor: const Color(0xffFF6B2C),
                textColor: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LiquidBlobPainter extends CustomPainter {
  final Animation<double> animation;
  _LiquidBlobPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final time = animation.value * 2 * math.pi;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xffFFF5EE));

    _drawBlob(canvas, paint, time, 0, size.width * 0.8, size.height * 0.05, size.width * 0.5, const Color(0xffFF6B2C).withValues(alpha: 0.13));
    _drawBlob(canvas, paint, time, 1, -size.width * 0.1, size.height * 0.45, size.width * 0.45, const Color(0xffFF8F5C).withValues(alpha: 0.10));
    _drawBlob(canvas, paint, time, 2, size.width * 0.85, size.height * 0.8, size.width * 0.35, const Color(0xffFF6B2C).withValues(alpha: 0.08));
    _drawBlob(canvas, paint, time, 3, size.width * 0.35, size.height * 0.95, size.width * 0.3, const Color(0xffFFB88C).withValues(alpha: 0.07));
  }

  void _drawBlob(Canvas canvas, Paint paint, double time, int index, double baseX, double baseY, double radius, Color color) {
    final offset = index * 1.3;
    final dx = baseX + math.sin(time * 0.5 + offset) * radius * 0.3;
    final dy = baseY + math.cos(time * 0.4 + offset) * radius * 0.25;
    final r = radius + math.sin(time * 0.6 + offset) * radius * 0.15;

    paint.shader = RadialGradient(
      colors: [color, color.withValues(alpha: 0.0)],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: r));

    final path = ui.Path();
    final segments = 8;
    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * math.pi;
      final wobble = 1.0 + 0.2 * math.sin(time * 0.7 + angle * 3 + offset);
      final px = dx + r * wobble * math.cos(angle);
      final py = dy + r * wobble * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        final prevAngle = ((i - 1) / segments) * 2 * math.pi;
        final prevWobble = 1.0 + 0.2 * math.sin(time * 0.7 + prevAngle * 3 + offset);
        final cp1x = dx + r * (wobble + prevWobble) * 0.5 * math.cos((angle + prevAngle) / 2) * 1.1;
        final cp1y = dy + r * (wobble + prevWobble) * 0.5 * math.sin((angle + prevAngle) / 2) * 1.1;
        path.quadraticBezierTo(cp1x, cp1y, px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LiquidBlobPainter oldDelegate) => true;
}
