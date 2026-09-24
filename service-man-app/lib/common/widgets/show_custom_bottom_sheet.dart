import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

Future<void> showCustomBottomSheet({required Widget child}) async {
  await Get.bottomSheet(
    ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(Get.context!).size.height * 0.8),
      child: child,
    ),
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha:Get.isDarkMode ? 0.8 : 0.45 ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Ios27Tokens.radiusLg),
        topRight: Radius.circular(Ios27Tokens.radiusLg),
      ),
    ),
  );
}
