import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class SignupBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpController(authRepo: AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find())));
  }
}