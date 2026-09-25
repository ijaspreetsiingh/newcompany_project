import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class SocialLoginScreen extends StatefulWidget {
  const SocialLoginScreen({super.key});

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> with TickerProviderStateMixin {
  late AnimationController _blobController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blobController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5EE),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, _) {
              return CustomPaint(
                painter: _LiquidBlobPainter(animation: _blobController),
                size: MediaQuery.of(context).size,
              );
            },
          ),
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, _) {
              return CustomPaint(
                painter: _ParticlePainter(animation: _floatController),
                size: MediaQuery.of(context).size,
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff101828), size: 20),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -5 + _floatController.value * 10),
                              child: Container(
                                height: 220,
                                width: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xffFF6B2C).withValues(alpha: 0.08),
                                      blurRadius: 40,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                                        color: Colors.white.withValues(alpha: 0.3),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(110),
                                        child: Image.asset(
                                          Images.intro1,
                                          fit: BoxFit.cover,
                                          height: 200,
                                          width: 200,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.person_outline, size: 80, color: Color(0xffFF6B2C));
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Let's you in",
                          style: robotoBold.copyWith(fontSize: 28, color: const Color(0xff101828)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Welcome back! Sign in to continue.",
                          style: robotoRegular.copyWith(fontSize: 15, color: const Color(0xff98A2B3)),
                        ),
                        const SizedBox(height: 45),

                        _buildSocialButton(
                          icon: Icons.facebook,
                          iconColor: const Color(0xff1877F2),
                          label: 'Continue with Facebook',
                          onPressed: () {
                            Get.toNamed(RouteHelper.getSignInRoute());
                          },
                        ),
                        const SizedBox(height: 14),

                        _buildSocialButton(
                          assetIcon: 'assets/images/qixer_google.png',
                          label: 'Continue with Google',
                          onPressed: () {
                            Get.toNamed(RouteHelper.getSignInRoute());
                          },
                        ),
                        const SizedBox(height: 14),

                        _buildSocialButton(
                          icon: Icons.apple,
                          iconColor: const Color(0xff101828),
                          label: 'Continue with Apple',
                          onPressed: () {
                            Get.toNamed(RouteHelper.getSignInRoute());
                          },
                        ),

                        const SizedBox(height: 28),

                        Row(
                          children: [
                            Expanded(child: Container(height: 1, color: const Color(0xffD0D5DD))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text('or', style: robotoSemiBold.copyWith(color: const Color(0xff98A2B3), fontSize: 14)),
                            ),
                            Expanded(child: Container(height: 1, color: const Color(0xffD0D5DD))),
                          ],
                        ),

                        const SizedBox(height: 28),

                        Container(
                          height: 55,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xffFF6B2C),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xffFF6B2C).withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed(RouteHelper.getSignInRoute());
                            },
                            child: Text(
                              'Sign in with password',
                              style: robotoSemiBold.copyWith(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?  ",
                              style: robotoRegular.copyWith(color: const Color(0xff646464), fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed(RouteHelper.getSignUpRoute()),
                              child: Text(
                                'Sign up',
                                style: robotoSemiBold.copyWith(fontSize: 14, color: const Color(0xffFF6B2C)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    IconData? icon,
    Color? iconColor,
    String? assetIcon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
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
          child: TextButton.icon(
            onPressed: onPressed,
            icon: assetIcon != null
                ? Image.asset(assetIcon, height: 22, width: 22)
                : Icon(icon, color: iconColor, size: 22),
            label: Text(
              label,
              style: robotoMedium.copyWith(fontSize: 15, color: const Color(0xff101828)),
            ),
          ),
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

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..shader = ui.Gradient.linear(
      Offset(0, 0), Offset(size.width * 0.5, size.height),
      [const Color(0xffFFF8F3), const Color(0xffFFF0E5), const Color(0xffFFE8D9)],
    ));

    _drawBlob(canvas, paint, time, 0, size.width * 0.75, size.height * 0.03, size.width * 0.55, const Color(0xffFF6B2C).withValues(alpha: 0.18));
    _drawBlob(canvas, paint, time, 1, -size.width * 0.15, size.height * 0.42, size.width * 0.5, const Color(0xffFF8F5C).withValues(alpha: 0.14));
    _drawBlob(canvas, paint, time, 2, size.width * 0.88, size.height * 0.78, size.width * 0.4, const Color(0xffFF5722).withValues(alpha: 0.11));
    _drawBlob(canvas, paint, time, 3, size.width * 0.35, size.height * 0.92, size.width * 0.35, const Color(0xffFFB88C).withValues(alpha: 0.09));
    _drawBlob(canvas, paint, time, 4, size.width * 0.6, -size.height * 0.06, size.width * 0.3, const Color(0xffFF7043).withValues(alpha: 0.07));
    _drawBlob(canvas, paint, time, 5, size.width * 0.15, size.height * 0.25, size.width * 0.25, const Color(0xffFFAB91).withValues(alpha: 0.06));
  }

  void _drawBlob(Canvas canvas, Paint paint, double time, int index, double baseX, double baseY, double radius, Color color) {
    final offset = index * 1.5;
    final dx = baseX + math.sin(time * 0.38 + offset) * radius * 0.38;
    final dy = baseY + math.cos(time * 0.3 + offset) * radius * 0.32;
    final r = radius + math.sin(time * 0.48 + offset) * radius * 0.2;

    paint.shader = RadialGradient(
      colors: [color, color.withValues(alpha: 0.0)],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: r));

    final path = ui.Path();
    final segments = 10;
    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * math.pi;
      final wobble = 1.0 + 0.22 * math.sin(time * 0.55 + angle * 2.8 + offset) + 0.1 * math.cos(time * 0.35 + angle * 4.5 + offset);
      final px = dx + r * wobble * math.cos(angle);
      final py = dy + r * wobble * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        final prevAngle = ((i - 1) / segments) * 2 * math.pi;
        final prevWobble = 1.0 + 0.22 * math.sin(time * 0.55 + prevAngle * 2.8 + offset) + 0.1 * math.cos(time * 0.35 + prevAngle * 4.5 + offset);
        final midAngle = (angle + prevAngle) / 2;
        final cp1x = dx + r * (wobble + prevWobble) * 0.5 * math.cos(midAngle) * 1.13;
        final cp1y = dy + r * (wobble + prevWobble) * 0.5 * math.sin(midAngle) * 1.13;
        path.quadraticBezierTo(cp1x, cp1y, px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LiquidBlobPainter oldDelegate) => true;
}

class _ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  static final List<_Particle> _particles = List.generate(15, (i) => _Particle());
  _ParticlePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final time = animation.value * math.pi;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      final x = (p.x * size.width + math.sin(time * p.speedX + p.phase) * p.rangeX) % size.width;
      final adjustedX = x < 0 ? x + size.width : x;
      final y = (p.y * size.height - time * p.speedY * 20) % size.height;
      final adjustedY = y < 0 ? y + size.height : y;
      final opacity = (0.12 + 0.12 * math.sin(time * 0.6 + p.phase)).clamp(0.05, 0.25);

      paint.color = const Color(0xffFF6B2C).withValues(alpha: opacity);
      canvas.drawCircle(Offset(adjustedX, adjustedY), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

class _Particle {
  final double x, y, size, speedX, speedY, rangeX, phase;
  _Particle()
      : x = math.Random().nextDouble(),
        y = math.Random().nextDouble(),
        size = 2.5 + math.Random().nextDouble() * 3.5,
        speedX = 0.4 + math.Random().nextDouble() * 0.7,
        speedY = 0.5 + math.Random().nextDouble() * 0.9,
        rangeX = 12 + math.Random().nextDouble() * 25,
        phase = math.Random().nextDouble() * 2 * math.pi;
}
