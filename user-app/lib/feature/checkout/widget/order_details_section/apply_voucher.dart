import 'package:jdds/feature/checkout/widget/coupon_bottom_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:google_fonts/google_fonts.dart';

class ApplyVoucher extends StatelessWidget {
  const ApplyVoucher({super.key}) ;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF171717) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: bgColor,
        border: Border.all(color: borderColor),
      ),
      child: Center( child: GestureDetector(
        onTap: () async {
          if (ResponsiveHelper.isDesktop(context)) {
            Get.dialog(
              const Center(child: CouponBottomSheetWidget(orderAmount: 100))
            );
          } else {
            showModalBottomSheet(context: context,
              isScrollControlled: true, backgroundColor: Colors.transparent,
              builder: (c) => const CouponBottomSheetWidget(orderAmount: 100)
            );
          }
        },

        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('add_coupon'.tr, style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: primaryColor,
          )),

          Text('add_plus'.tr,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          ]
        )
      )),
    );
  }
}

