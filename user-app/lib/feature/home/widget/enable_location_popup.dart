import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class EnableLocationPopup extends StatefulWidget {
  const EnableLocationPopup({super.key});

  @override
  State<EnableLocationPopup> createState() => _EnableLocationPopupState();
}

class _EnableLocationPopupState extends State<EnableLocationPopup>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFFF26B22);
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    try {
      if (mounted) {
        setState(fn);
      }
    } catch (_) {}
  }

  void _enableCurrentLocation() async {
    if (_isLoading) return;
    _safeSetState(() => _isLoading = true);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (!mounted) return;
    if (permission == LocationPermission.denied) {
      _safeSetState(() => _isLoading = false);
      customSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
      return;
    }
    if (permission == LocationPermission.deniedForever) {
      _safeSetState(() => _isLoading = false);
      Get.dialog(const PermissionDialog());
      return;
    }

    _safeSetState(() => _isLoading = true);

    try {
      LocationController locationController = Get.find<LocationController>();
      AddressModel address = await locationController.getCurrentLocation(true, deviceCurrentLocation: true);
      if (!mounted) return;

      ZoneResponseModel response = await locationController.getZone(address.latitude!, address.longitude!, false);
      if (!mounted) return;

      if (response.isSuccess) {
        await locationController.saveUserAddress(address);
        HomeScreen.loadData(true);
        Get.offAllNamed(RouteHelper.getMainRoute('home'));
      } else {
        _safeSetState(() => _isLoading = false);
        customSnackBar(response.message);
      }
    } catch (e) {
      if (!mounted) return;
      _safeSetState(() => _isLoading = false);
      customSnackBar('failed_to_get_location'.tr);
    }
  }


  /// Centered modal sheet - top rounded corners, compact, floats above content
  Widget _buildModalSheet(double maxWidth) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 28, 24, 28 + MediaQuery.of(Get.context!).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Drag handle
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE4E4E7),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            /// Title
            Text(
              'enable_location'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: const Color(0xff1A1A2E),
              ),
            ),
            const SizedBox(height: 14),

            /// Illustration - soft blob + location pin
            SizedBox(
              height: 84,
              width: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 76,
                    width: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primary.withValues(alpha: 0.35),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 14,
                    child: Container(
                      height: 18,
                      width: 18,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF9A825),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 18,
                    child: Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 42,
                      color: _primary,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            /// Description
            Text(
              'enable_location_description'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                height: 1.5,
                color: const Color(0xff667085),
              ),
            ),
            const SizedBox(height: 18),

            /// Enable button
            SizedBox(
              width: maxWidth,
              height: 46,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _enableCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoading
                      ? _primary.withValues(alpha: 0.6)
                      : _primary,
                  disabledBackgroundColor: _primary.withValues(alpha: 0.6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'enable'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),

            /// Set location manually → open map screen with search
            SizedBox(
              width: maxWidth,
              height: 46,
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Get.toNamed(RouteHelper.getPickMapRoute(
                          RouteHelper.accessLocation,
                          false,
                          'false',
                          null,
                          Get.find<LocationController>().getUserAddress(),
                        ));
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: BorderSide(
                    color: _primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'set_location_manually'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: _primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: Colors.black.withValues(alpha: 0.2),
        width: double.infinity,
        height: double.infinity,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildModalSheet(screenWidth),
          ),
        ),
      ),
    );
  }
}
