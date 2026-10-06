import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

class AccessLocationScreen extends StatefulWidget {
  final bool? fromSignUp;
  final bool fromHome;
  final String? route;
  const AccessLocationScreen({
    super.key,
    required this.fromSignUp,
    required this.route,
    this.fromHome = false,
  });

  @override
  State<AccessLocationScreen> createState() => _AccessLocationScreenState();
}

class _AccessLocationScreenState extends State<AccessLocationScreen>
    with TickerProviderStateMixin {
  bool isLoggedIn = false;
  late AnimationController _blobController;
  late AnimationController _iconController;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    Get.find<LocalizationController>().filterLanguage(shouldUpdate: false);
    isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if (isLoggedIn) {
      Get.find<LocationController>().getAddressList();
    }

    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _blobController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  final shakeKey = GlobalKey<CustomShakingWidgetState>();

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return CustomPopWidget(
      isExit: true,
      child: Scaffold(
        backgroundColor: NestInk.background,
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _blobController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LiquidBlobPainter(
                    animation: _blobController,
                    background: NestInk.background,
                    foreground: NestInk.primary,
                  ),
                  size: MediaQuery.of(context).size,
                );
              },
            ),
            SafeArea(
              child: GetBuilder<LocationController>(
                builder: (locationController) {
                  return (ResponsiveHelper.isDesktop(context)) &&
                          !widget.fromHome
                      ? WebLandingPage(
                          fromSignUp: widget.fromSignUp,
                          route: widget.route,
                          shakeKey: shakeKey,
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: NestInk.card,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: NestInk.border),
                                    ),
                                    child: IconButton(
                                      onPressed: () =>
                                          Navigator.maybePop(context),
                                      icon: Icon(
                                        Icons.arrow_back_rounded,
                                        size: 18,
                                        color: NestInk.primary,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Set Location',
                                    style: NestInk.display(
                                      size: 17,
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                  const Spacer(),
                                  const SizedBox(width: 40),
                                ],
                              ),
                            ),
                            Expanded(
                              child:
                                  isLoggedIn &&
                                      locationController.addressList != null &&
                                      locationController.addressList!.isNotEmpty
                                  ? _buildAddressList(locationController)
                                  : _buildLocationPrompt(
                                      context,
                                      locationController,
                                    ),
                            ),
                            if (!ResponsiveHelper.isDesktop(context))
                              _buildBottomButtons(context, locationController),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(LocationController locationController) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: locationController.addressList!.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AddressWidget(
            address: locationController.addressList![index],
            fromAddress: false,
            onTap: () async {
              Get.dialog(const CustomLoader(), barrierDismissible: false);
              AddressModel address = locationController.addressList![index];
              await locationController.setAddressIndex(
                address,
                fromAddressScreen: false,
              );
              locationController.saveAddressAndNavigate(
                address,
                widget.fromSignUp!,
                widget.route,
                widget.route != null,
                true,
              );
            },
            selectedUserAddressId: locationController.getUserAddress()?.id,
          ),
        );
      },
    );
  }

  Widget _buildLocationPrompt(
    BuildContext context,
    LocationController locationController,
  ) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _iconScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _iconScale.value,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: NestInk.card,
                      border: Border.all(color: NestInk.border),
                      boxShadow: [
                        BoxShadow(
                          color: NestInk.primary.withValues(alpha: 0.08),
                          blurRadius: 40,
                          spreadRadius: 5,
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              Images.mapLocation,
                              fit: BoxFit.cover,
                              height: 180,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 35),
            Text(
              'Find Services Near You',
              textAlign: TextAlign.center,
              style: NestInk.display(size: 22, weight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Please select your location to start\nexploring available services near you',
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: 14,
                height: 1.5,
                color: NestInk.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(
    BuildContext context,
    LocationController locationController,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 25),
      child: Column(
        children: [
          Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () {
                if (isRedundentClick(DateTime.now())) return;
                _checkPermission(_useCurrentLocation);
              },
              icon: Icon(
                Icons.my_location,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              label: Text(
                'Use Current Location',
                style: robotoSemiBold.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: NestInk.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: NestInk.border, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: TextButton.icon(
                  onPressed: () async {
                    if (isRedundentClick(DateTime.now())) return;
                    Get.toNamed(
                      RouteHelper.getPickMapRoute(
                        widget.route == null
                            ? (widget.fromSignUp ?? false)
                                  ? RouteHelper.signUp
                                  : RouteHelper.accessLocation
                            : widget.route!,
                        widget.route != null,
                        'false',
                        null,
                        Get.find<LocationController>().getUserAddress(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.location_pin,
                    color: NestInk.primary,
                    size: 20,
                  ),
                  label: Text(
                    'Set From Map',
                    style: robotoSemiBold.copyWith(
                      color: NestInk.primary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      customSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    } else {
      onTap();
    }
  }

  Future<void> _useCurrentLocation() async {
    Get.dialog(const CustomLoader(), barrierDismissible: false);
    try {
      final LocationController locationController =
          Get.find<LocationController>();
      final AddressModel address = await locationController.getCurrentLocation(
        true,
        deviceCurrentLocation: true,
      );
      if (address.zoneId?.isNotEmpty ?? false) {
        await locationController.saveAddressAndNavigate(
          address,
          widget.fromSignUp ?? false,
          widget.route ?? '',
          widget.route != null,
          true,
          zoneAlreadyValidated: true,
        );
      } else {
        Get.back();
        customSnackBar('service_not_available_in_this_area'.tr);
      }
    } catch (_) {
      if (Get.isDialogOpen ?? false) Get.back();
      customSnackBar('failed_to_get_location'.tr);
    }
  }
}

class _LiquidBlobPainter extends CustomPainter {
  final Animation<double> animation;
  final Color background;
  final Color foreground;
  _LiquidBlobPainter({
    required this.animation,
    required this.background,
    required this.foreground,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final time = animation.value * 2 * math.pi;

    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width * 0.5, size.height),
        [background, background],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    _drawBlob(
      canvas,
      paint,
      time,
      0,
      size.width * 0.78,
      size.height * 0.04,
      size.width * 0.5,
      foreground.withValues(alpha: 0.035),
    );
    _drawBlob(
      canvas,
      paint,
      time,
      1,
      -size.width * 0.12,
      size.height * 0.35,
      size.width * 0.45,
      foreground.withValues(alpha: 0.025),
    );
    _drawBlob(
      canvas,
      paint,
      time,
      2,
      size.width * 0.9,
      size.height * 0.8,
      size.width * 0.35,
      foreground.withValues(alpha: 0.02),
    );
    _drawBlob(
      canvas,
      paint,
      time,
      3,
      size.width * 0.35,
      size.height * 0.95,
      size.width * 0.3,
      foreground.withValues(alpha: 0.018),
    );
    _drawBlob(
      canvas,
      paint,
      time,
      4,
      size.width * 0.5,
      -size.height * 0.06,
      size.width * 0.28,
      foreground.withValues(alpha: 0.015),
    );
  }

  void _drawBlob(
    Canvas canvas,
    Paint paint,
    double time,
    int index,
    double baseX,
    double baseY,
    double radius,
    Color color,
  ) {
    final offset = index * 1.5;
    final dx = baseX + math.sin(time * 0.4 + offset) * radius * 0.35;
    final dy = baseY + math.cos(time * 0.3 + offset) * radius * 0.3;
    final r = radius + math.sin(time * 0.5 + offset) * radius * 0.18;

    paint.shader = RadialGradient(
      colors: [color, color.withValues(alpha: 0.0)],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: r));

    final path = ui.Path();
    final segments = 10;
    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * math.pi;
      final wobble =
          1.0 +
          0.2 * math.sin(time * 0.6 + angle * 3 + offset) +
          0.1 * math.cos(time * 0.4 + angle * 5 + offset);
      final px = dx + r * wobble * math.cos(angle);
      final py = dy + r * wobble * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        final prevAngle = ((i - 1) / segments) * 2 * math.pi;
        final prevWobble =
            1.0 +
            0.2 * math.sin(time * 0.6 + prevAngle * 3 + offset) +
            0.1 * math.cos(time * 0.4 + prevAngle * 5 + offset);
        final midAngle = (angle + prevAngle) / 2;
        final cp1x =
            dx + r * (wobble + prevWobble) * 0.5 * math.cos(midAngle) * 1.12;
        final cp1y =
            dy + r * (wobble + prevWobble) * 0.5 * math.sin(midAngle) * 1.12;
        path.quadraticBezierTo(cp1x, cp1y, px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LiquidBlobPainter oldDelegate) => true;
}
