import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/util/core_export.dart';

class EnableLocationPopup extends StatefulWidget {
  const EnableLocationPopup({super.key});

  /// Opens the location selector over the current screen. New users use a
  /// non-dismissible version so they can choose a service area before browsing.
  static Future<T?> show<T>(
    BuildContext context, {
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'location_picker'.tr,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, __) => PopScope(
        canPop: barrierDismissible,
        child: const EnableLocationPopup(),
      ),
    );
  }

  @override
  State<EnableLocationPopup> createState() => _EnableLocationPopupState();
}

class _EnableLocationPopupState extends State<EnableLocationPopup>
    with SingleTickerProviderStateMixin {
  /// nest. style : primary ab theme se aata hai (black & white palette)
  Color get _primary => NestInk.primary;

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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
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

    try {
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

      LocationController locationController = Get.find<LocationController>();
      AddressModel address = await locationController.getCurrentLocation(
        true,
        deviceCurrentLocation: true,
      );
      if (!mounted) return;

      if (address.zoneId?.isNotEmpty ?? false) {
        await locationController.saveUserAddress(address);
        HomeScreen.loadData(true);
        Get.offAllNamed(RouteHelper.getMainRoute('home'));
      } else {
        _safeSetState(() => _isLoading = false);
        customSnackBar('service_not_available_in_this_area'.tr);
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
        color: NestInk.card,
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
        padding: EdgeInsets.fromLTRB(
          24,
          28,
          24,
          28 + MediaQuery.of(Get.context!).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Drag handle
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: NestInk.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            /// Title
            Text(
              'enable_location'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: NestInk.primary,
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _primary.withValues(alpha: 0.25),
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
                color: NestInk.mutedText,
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
                  foregroundColor: NestInk.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: NestInk.background,
                        ),
                      )
                    : Text(
                        'enable'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: NestInk.background,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),

            /// Set location manually â†’ open map screen with search
            SizedBox(
              width: maxWidth,
              height: 46,
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Get.toNamed(
                          RouteHelper.getPickMapRoute(
                            RouteHelper.accessLocation,
                            false,
                            'false',
                            null,
                            Get.find<LocationController>().getUserAddress(),
                          ),
                        );
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
    Theme.of(context);

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
