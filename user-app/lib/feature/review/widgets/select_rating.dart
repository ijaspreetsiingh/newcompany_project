import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/feature/review/controller/submit_review_controller.dart';

class SelectRating extends StatelessWidget {
  final String revivedId;
  final bool clickable;
  const SelectRating({super.key, required this.revivedId, this.clickable = true});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubmitReviewController>(builder: (submitReviewController) {
      final int selected =
          int.tryParse(submitReviewController.selectedRating[revivedId].toString()) ?? 0;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final filled = index < selected;
          return GestureDetector(
            onTap: clickable
                ? () => submitReviewController.selectReview(index + 1, revivedId)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 28,
                color: filled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).disabledColor,
              ),
            ),
          );
        }),
      );
    });
  }
}
