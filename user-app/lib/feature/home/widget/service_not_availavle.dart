import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceNotAvailableScreen extends StatelessWidget {
  final String fromPage;
  const ServiceNotAvailableScreen({super.key, this.fromPage = ""});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F8F8);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Icon container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
                color: bgColor,
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 60,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 32),

            /// Main heading
            Text(
              fromPage == "search_page"
                  ? "there_are_no_services_related_to_your_search".tr
                  : "Services are not available\nin this area",
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            /// Subtitle
            if (fromPage != "search_page")
              Text(
                "Please select among locations where we\nprovide services",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: mutedColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 40),

            /// Buttons - Two options
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Set on Map Button (Primary)
                InkWell(
                  onTap: () {
                    Get.toNamed(RouteHelper.getServiceArea());
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).primaryColor,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Choose Location on Map",
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                /// View Available Areas Button (Secondary)
                InkWell(
                  onTap: () {
                    Get.toNamed(RouteHelper.getServiceArea());
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      ),
                      color: isDark
                          ? const Color(0xFF1A1A1A)
                          : Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "view_available_areas".tr,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
