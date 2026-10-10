import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class BankInfoBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => BankInfoController(bankInfoRepo: BankInfoRepo(apiClient: Get.find(), sharedPreferences: Get.find())));
  }
}