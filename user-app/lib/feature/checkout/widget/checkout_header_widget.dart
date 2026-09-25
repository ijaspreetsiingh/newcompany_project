import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class CheckoutHeaderWidget extends StatelessWidget {
  final String pageState;
  const CheckoutHeaderWidget({super.key, required this.pageState});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckOutController>(builder: (controller) {
      final int currentStep = controller.currentPageState == PageState.orderDetails
          ? 0
          : controller.currentPageState == PageState.payment
              ? 1
              : 2;

      final Color activeColor = Theme.of(context).colorScheme.primary;
      final Color completedColor = const Color(0xFF4CAF50);
      final Color inactiveColor = Theme.of(context).hintColor.withValues(alpha: 0.3);

      final List<String> steps = [
        "booking_details".tr,
        "payment".tr,
        "complete".tr,
      ];

      Widget _buildCircle(int index) {
        bool isCompleted = index < currentStep;
        bool isActive = index == currentStep;

        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? completedColor
                : isActive
                    ? activeColor
                    : Colors.transparent,
            border: Border.all(
              color: isCompleted
                  ? completedColor
                  : isActive
                      ? activeColor
                      : inactiveColor,
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : Text(
                    "${index + 1}",
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isActive ? Colors.white : inactiveColor,
                    ),
                  ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 40,
              child: Row(
                children: List.generate(steps.length * 2 - 1, (index) {
                  if (index.isOdd) {
                    int lineIndex = index ~/ 2;
                    return Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: lineIndex < currentStep ? completedColor : inactiveColor,
                        ),
                      ),
                    );
                  } else {
                    return _buildCircle(index ~/ 2);
                  }
                }),
              ),
            ),
            const SizedBox(height: 8),
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
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: isCompleted
                              ? completedColor
                              : isActive
                                  ? activeColor
                                  : Theme.of(context).hintColor,
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
