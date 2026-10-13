import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

/// New checkout flow ka shared 3-step progress indicator.
/// Step 1 = Schedule, 2 = Payment, 3 = Confirmed.
/// Design: filled accent circles (done/current), grey outline (upcoming),
/// accent connector for completed segments + subtle glow on current step.
class CheckoutProgressIndicator extends StatelessWidget {
  final int currentStep;
  const CheckoutProgressIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final List<_StepData> steps = [
      _StepData(label: 'schedule'.tr, icon: Icons.event_note_outlined, activeIcon: Icons.event),
      _StepData(label: 'payment'.tr, icon: Icons.payments_outlined, activeIcon: Icons.payments),
      _StepData(label: 'confirmed'.tr, icon: Icons.check_outlined, activeIcon: Icons.check_circle),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // crossAxisAlignment.start + line ko circle-centre (15.5px) tak pad —
      // warna Row ki default center-alignment line ko label ke level (neeche)
      // rakhti thi.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.5, left: 6, right: 6),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i < currentStep ? primaryAccent : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            _buildStep(context, steps[i], i + 1),
          ],
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, _StepData step, int stepNo) {
    final bool isDone = currentStep > stepNo;
    final bool isCurrent = currentStep == stepNo;
    final bool isActive = isDone || isCurrent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? primaryAccent : Colors.grey[200],
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: primaryAccent.withValues(alpha: 0.35),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isDone ? Icons.check : (isCurrent ? step.activeIcon : step.icon),
            color: isActive ? Colors.white : Colors.grey[500],
            size: 17,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step.label,
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(
            fontSize: 10.5,
            color: isActive ? primaryAccent : Colors.grey[500],
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StepData {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _StepData({required this.label, required this.icon, required this.activeIcon});
}
