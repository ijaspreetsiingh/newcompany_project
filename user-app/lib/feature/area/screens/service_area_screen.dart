import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:jdds/feature/area/widget/area_map_view.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceAreaScreen extends StatefulWidget {
  const ServiceAreaScreen({super.key});

  @override
  State<ServiceAreaScreen> createState() => _ServiceAreaScreenState();
}

class _ServiceAreaScreenState extends State<ServiceAreaScreen> {
  bool _isInteractingWithMap = false;
  ZoneModel? _selectedZone;

  @override
  void initState() {
    super.initState();
    Get.find<ServiceAreaController>().getZoneList(reload: false);
  }

  void _handleInteractingWithMap(bool value) {
    setState(() {
      _isInteractingWithMap = value;
    });
  }

  void _selectZone(ZoneModel zone) {
    setState(() {
      _selectedZone = zone;
    });
  }

  void _confirmSelection() {
    if (_selectedZone != null) {
      Get.toNamed(
        RouteHelper.getPickMapRoute(
          "",
          true,
          'false',
          _selectedZone!,
          Get.find<LocationController>().getUserAddress(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

    return CustomPopWidget(
      isExit: true,
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer:
            ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        appBar: CustomAppBar(
          centerTitle: false,
          title: 'our_services_areas'.tr,
          showCart: false,
        ),
        body: GetBuilder<ServiceAreaController>(
          builder: (serviceAreaController) {
            return serviceAreaController.zoneList == null
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      /// Full height map
                      SizedBox.expand(
                        child: AreaMapViewScreen(
                          zoneList:
                              serviceAreaController.zoneList ?? [],
                          onValueChanged: _handleInteractingWithMap,
                          onZoneSelected: _selectZone,
                        ),
                      ),

                      /// Top header with info
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor
                                .withValues(alpha: 0.98),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'we_are_available_in_these_areas'.tr,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'get_you_destred_service'.tr,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// Bottom Select Zone Button
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor
                                .withValues(alpha: 0.98),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              if (_selectedZone != null)
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected Zone',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: mutedColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        _selectedZone!.name ?? '',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                )
                              else
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    'Click on a zone on the map to select',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: mutedColor,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _selectedZone != null
                                          ? _confirmSelection
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context)
                                            .primaryColor,
                                    disabledBackgroundColor:
                                        mutedColor
                                            .withValues(
                                              alpha: 0.3,
                                            ),
                                    padding: const EdgeInsets
                                        .symmetric(
                                      vertical: 14,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                            12,
                                          ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons
                                            .check_circle_outline_rounded,
                                        color: _selectedZone !=
                                                null
                                            ? Colors.white
                                            : mutedColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Confirm Selection',
                                        style: GoogleFonts
                                            .dmSans(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.w700,
                                          color:
                                              _selectedZone !=
                                                      null
                                                  ? Colors
                                                      .white
                                                  : mutedColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
