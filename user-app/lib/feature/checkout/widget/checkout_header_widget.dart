import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutHeaderWidget extends StatelessWidget {
  final String pageState;
  const CheckoutHeaderWidget({super.key, required this.pageState});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF1F1F1) : const Color(0xFF141414);
    final mutedColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFF7D7D7D);
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;

    return GetBuilder<CheckOutController>(builder: (controller) {
      final int currentStep = controller.currentPageState == PageState.orderDetails
          ? 0
          : controller.currentPageState == PageState.payment
              ? 1
              : 2;

      final List<String> steps = [
        "booking_details".tr,
        "payment".tr,
        "complete".tr,
      ];

      Widget _buildCircle(int index) {
        bool isCompleted = index < currentStep;
        bool isActive = index == currentStep;

        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? primaryColor
                : Colors.transparent,
            border: Border.all(
              color: isCompleted || isActive
                  ? primaryColor
                  : mutedColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check_rounded, size: 14, color: bgColor)
                : Text(
                    "${index + 1}",
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive ? bgColor : mutedColor,
                    ),
                  ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 36,
              child: Row(
                children: List.generate(steps.length * 2 - 1, (index) {
                  if (index.isOdd) {
                    int lineIndex = index ~/ 2;
                    return Expanded(
                      child: Container(
                        height: 1.5,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: lineIndex < currentStep ? primaryColor : mutedColor.withValues(alpha: 0.2),
                        ),
                      ),
                    );
                  } else {
                    return _buildCircle(index ~/ 2);
                  }
                }),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(steps.length * 2 - 1, (index) {
                if (index.isOdd) {
                  return const Expanded(child: SizedBox.shrink());
                } else {
                  int stepIndex = index ~/ 2;
                  bool isCompleted = stepIndex < currentStep;
                  bool isActive = stepIndex == currentStep;
                  return Expanded(
                    child: Center(
                      child: Text(
                        steps[stepIndex],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isCompleted || isActive ? primaryColor : mutedColor,
                        ),
                      ),
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      );
    });
  }
}


