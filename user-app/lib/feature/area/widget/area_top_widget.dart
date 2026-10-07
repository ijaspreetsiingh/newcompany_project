import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AreaTopWidget extends StatelessWidget {
  const AreaTopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);

    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          
          /// Icon with animated background
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context)
                  .primaryColor
                  .withValues(alpha: 0.1),
              border: Border.all(
                color: Theme.of(context)
                    .primaryColor
                    .withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.location_on_rounded,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 28),

          /// Main heading
          Text(
            "we_are_available_in_these_areas".tr,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          /// Subtitle
          Text(
            "get_you_destred_service".tr,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: mutedColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
