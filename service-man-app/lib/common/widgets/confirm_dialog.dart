import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class ConfirmationDialog extends StatelessWidget {
  final String? icon;
  final String? title;
  final String? description;
  final Color? yesButtonColor;
  final Function()? onYesPressed;
  final bool? isLogOut;
  final Color? imageBackgroundColor;
  final Function? onNoPressed;
  final bool isLoading;
  const ConfirmationDialog({
    super.key,
    required this.icon,
    this.title,
    required this.description,
    required this.onYesPressed,
    this.isLogOut = false,
    this.onNoPressed,
    this.yesButtonColor = const Color(0xFFEF4444),
    this.imageBackgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (yesButtonColor ?? const Color(0xFFEF4444)).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLogOut == true ? Icons.logout_rounded : Icons.info_outline_rounded,
                size: 30,
                color: yesButtonColor ?? const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),
            if (title != null)
              Text(
                title!,
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            if (title != null) const SizedBox(height: 8),
            Text(
              description ?? '',
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => isLogOut == true ? onYesPressed?.call() : onNoPressed != null ? onNoPressed!() : Get.back(),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isLogOut == true ? 'yes'.tr : 'no'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: isLogOut == true ? () => Get.back() : onYesPressed,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isLogOut == true
                            ? Theme.of(context).primaryColor
                            : yesButtonColor ?? const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                isLogOut == true ? 'no'.tr : 'yes'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Colors.white,
                                ),
                              ),
                      ),
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
