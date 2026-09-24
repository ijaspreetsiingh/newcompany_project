import 'package:get/get.dart';
import 'package:jdds/feature/service/controller/service_details_tab_controller.dart';
import 'package:jdds/feature/service/repository/service_details_repo.dart';

class ServiceDetailsBinding extends Bindings{
  @override
  void dependencies() async {
    Get.lazyPut(() => ServiceTabController(serviceDetailsRepo: ServiceDetailsRepo(apiClient: Get.find())));
  }
}