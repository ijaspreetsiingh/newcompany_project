import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';

class NewPassScreen extends StatefulWidget {
  final ForgetPasswordBody? forgetPasswordBody;
  final String? redtrectUrl;
  const NewPassScreen({super.key, this.forgetPasswordBody, this.redtrectUrl});

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> newPassKey = GlobalKey<FormState>();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  String _identity = '';
  late AnimationController _blobController;

  @override
  void initState() {
    AuthController authController = Get.find();
    authController.newPasswordController.clear();
    authController.confirmNewPasswordController.clear();
    super.initState();
    _identity = widget.forgetPasswordBody?.identity ?? "";
    _blobController = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();

    if (widget.forgetPasswordBody?.fromUrl == 1) {
      authController.verifyOtpForForgetPasswordScreen(widget.forgetPasswordBody?.identity ?? "", widget.forgetPasswordBody?.identityType ?? "", widget.forgetPasswordBody?.otp ?? "", fromOutsideUrl: true, shouldUpdate: false).then((status) async {
        if (status.isSuccess!) {
          if (kDebugMode) print("Session Available");
        } else {
          if (kDebugMode) print("Session Exptred");
        }
      });
    }
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        backgroundColor: NestInk.background,
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
        endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        body: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: NestInk.primary,
              onPrimary: NestInk.background,
            ),
          ),
          child: GetBuilder<AuthController>(builder: (controller) {
          return Stack(
            children: [
              AnimatedBuilder(
                animation: _blobController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _LiquidBlobPainter(
                      animation: _blobController,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),
                    size: MediaQuery.of(context).size,
                  );
                },
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Get.find<AuthController>().updateVerificationCode('');
                              Get.back();
                            },
                            icon: Icon(Icons.arrow_back_ios_new_rounded, color: NestInk.primary, size: 20),
                          ),
                          const Spacer(),
                          Text(
                            'Change Password',
                            style: robotoBold.copyWith(fontSize: 17, color: NestInk.primary),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Expanded(
                      child: controller.forgetPasswordUrlSessionExptred && controller.isLoading
                          ? Center(child: CircularProgressIndicator(color: NestInk.primary))
                          : controller.forgetPasswordUrlSessionExptred && !controller.isLoading
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("url_session_exptred".tr, style: robotoMedium.copyWith(color: NestInk.mutedText)),
                                      const SizedBox(height: 20),
                                      CustomButton(
                                        width: 200,
                                        buttonText: "go_back".tr,
                                        backgroundColor: NestInk.primary,
                                        textColor: NestInk.background,
                                        onPressed: () {
                                          Get.offAllNamed(RouteHelper.getSignInRoute());
                                        },
                                      )
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                  child: Form(
                                    key: newPassKey,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 30),
                                        Container(
                                          height: 80.0,
                                          width: 80.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: NestInk.card.withValues(alpha: 0.75),
                                            boxShadow: [
                                              BoxShadow(
                                                color: NestInk.primary.withValues(alpha: 0.08),
                                                blurRadius: 25,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: BackdropFilter(
                                              filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: NestInk.border, width: 2),
                                                ),
                                                child: Icon(Icons.lock_outline, color: NestInk.primary, size: 36),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 25),
                                        Text(
                                          'Set new password',
                                          style: robotoBold.copyWith(fontSize: 20, color: NestInk.primary),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Create strong and secured\nnew password.',
                                          textAlign: TextAlign.center,
                                          style: robotoRegular.copyWith(fontSize: 14, height: 1.5, color: NestInk.mutedText),
                                        ),
                                        const SizedBox(height: 35),
                                        _buildFieldLabel('new_password'.tr),
                                        CustomTextField(
                                          hintText: '**************',
                                          controller: controller.newPasswordController,
                                          focusNode: _passwordFocus,
                                          nextFocus: _confirmPasswordFocus,
                                          inputType: TextInputType.visiblePassword,
                                          isPassword: true,
                                          onValidate: (String? value) {
                                            return FormValidation().isValidPassword(value!);
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        _buildFieldLabel('confirm_new_password'.tr),
                                        CustomTextField(
                                          hintText: '**************',
                                          controller: controller.confirmNewPasswordController,
                                          inputAction: TextInputAction.done,
                                          focusNode: _confirmPasswordFocus,
                                          inputType: TextInputType.visiblePassword,
                                          isPassword: true,
                                          onValidate: (String? value) {
                                            if (value == null || value.isEmpty) {
                                              return 'this_field_can_not_empty'.tr;
                                            } else {
                                              return FormValidation().isValidConfirmPassword(
                                                controller.newPasswordController.text,
                                                value,
                                              );
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 35),
                                        Container(
                                          height: 52,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: NestInk.primary,
                                            borderRadius: BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: NestInk.primary.withValues(alpha: 0.12),
                                                blurRadius: 15,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              if (isRedundentClick(DateTime.now())) return;
                                              _resetPassword(
                                                newPassword: controller.newPasswordController.value.text,
                                                confirmNewPassword: controller.confirmNewPasswordController.value.text,
                                              );
                                            },
                                            child: controller.isLoading
                                                ? SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: NestInk.background, strokeWidth: 2.5))
                                                : Text(
                                                    'Save Password',
                                                    style: robotoSemiBold.copyWith(fontSize: 16, color: NestInk.background),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                      ],
                                    ),
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ],
          );
          }),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: robotoSemiBold.copyWith(color: NestInk.primary, fontSize: 14),
      ),
    );
  }

  void _resetPassword({required String newPassword, required String confirmNewPassword}) {
    if (newPassKey.currentState!.validate()) {
      if (newPassword != confirmNewPassword) {
        customSnackBar('confirm_password_not_matched'.tr);
      } else {
        Get.find<AuthController>().resetPassword(
          identity: _identity,
          identityType: widget.forgetPasswordBody?.identityType ?? "",
          otp: widget.forgetPasswordBody?.otp ?? "",
          password: newPassword,
          confirmPassword: confirmNewPassword,
          isFirebaseOtp: widget.forgetPasswordBody?.isFirebaseOtp ?? 0,
          redtrectUrl: widget.redtrectUrl,
        );
      }
    }
  }
}

class _LiquidBlobPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;
  _LiquidBlobPainter({required this.animation, required this.isDark}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final time = animation.value * 2 * math.pi;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..shader = ui.Gradient.linear(
      Offset(0, 0), Offset(size.width * 0.5, size.height),
      isDark
          ? const [Color(0xFF0D0D0D), Color(0xFF171717)]
          : const [Colors.white, Color(0xFFF6F6F6)],
    ));

    final Color accent = isDark ? Colors.white : const Color(0xFF141414);
    _drawBlob(canvas, paint, time, 0, size.width * 0.78, size.height * 0.04, size.width * 0.45, accent.withValues(alpha: 0.045));
    _drawBlob(canvas, paint, time, 1, -size.width * 0.12, size.height * 0.4, size.width * 0.4, accent.withValues(alpha: 0.035));
    _drawBlob(canvas, paint, time, 2, size.width * 0.88, size.height * 0.85, size.width * 0.35, accent.withValues(alpha: 0.03));
    _drawBlob(canvas, paint, time, 3, size.width * 0.35, size.height * 0.92, size.width * 0.3, accent.withValues(alpha: 0.025));
  }

  void _drawBlob(Canvas canvas, Paint paint, double time, int index, double baseX, double baseY, double radius, Color color) {
    final offset = index * 1.5;
    final dx = baseX + math.sin(time * 0.38 + offset) * radius * 0.35;
    final dy = baseY + math.cos(time * 0.3 + offset) * radius * 0.3;
    final r = radius + math.sin(time * 0.48 + offset) * radius * 0.18;
    paint.shader = RadialGradient(
      colors: [color, color.withValues(alpha: 0.0)],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: r));
    final path = ui.Path();
    final segments = 10;
    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * math.pi;
      final wobble = 1.0 + 0.2 * math.sin(time * 0.6 + angle * 3 + offset) + 0.1 * math.cos(time * 0.4 + angle * 5 + offset);
      final px = dx + r * wobble * math.cos(angle);
      final py = dy + r * wobble * math.sin(angle);
      if (i == 0) { path.moveTo(px, py); } else {
        final prevAngle = ((i - 1) / segments) * 2 * math.pi;
        final prevWobble = 1.0 + 0.2 * math.sin(time * 0.6 + prevAngle * 3 + offset) + 0.1 * math.cos(time * 0.4 + prevAngle * 5 + offset);
        final midAngle = (angle + prevAngle) / 2;
        final cp1x = dx + r * (wobble + prevWobble) * 0.5 * math.cos(midAngle) * 1.12;
        final cp1y = dy + r * (wobble + prevWobble) * 0.5 * math.sin(midAngle) * 1.12;
        path.quadraticBezierTo(cp1x, cp1y, px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LiquidBlobPainter oldDelegate) => true;
}



