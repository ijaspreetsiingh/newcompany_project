import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class ServiceDetailsController extends GetxController implements GetxService {
  final ServiceDetailsRepo serviceDetailsRepo;
  ServiceDetailsController({required this.serviceDetailsRepo});

  Service? _service;
  bool _isLoading = true;
  Service? get service => _service;
  bool get isLoading => _isLoading;

  double _serviceDiscount = 0.0;
  double get serviceDiscount => _serviceDiscount;

  String _discountType = 'amount';
  String get discountType => _discountType;

  Future<void> getServiceDetails(String serviceID, {String fromPage = ""}) async {
    _service = null;
    _isLoading = true;
    update();

    try {
      Response response = await serviceDetailsRepo.getServiceDetails(serviceID, fromPage);
      if (response.body['response_code'] == 'default_200') {
        _service = Service.fromJson(response.body['content']);

        int length = _service!.faqs != null && _service!.faqs!.isNotEmpty ? 3 : 2;
        Get.find<ServiceTabController>().initTabController(length: length);
      } else {
        _service = Service();
        if (response.statusCode != 200) {
          ApiChecker.checkApi(response);
        }
      }
    } catch (e) {
      debugPrint('getServiceDetails error: $e');
      _service = Service();
    }
    _isLoading = false;
    update();
  }

  Future<void> getServiceDiscount() async {
    try {
      Service service = _service!;
      if (service.campaignDiscount != null && service.campaignDiscount!.isNotEmpty) {
        _serviceDiscount = service.campaignDiscount!.elementAt(0).discount?.discountAmount?.toDouble() ?? 0.0;
        _discountType = service.campaignDiscount!.elementAt(0).discount?.discountType ?? 'amount';
      } else if (service.category?.campaignDiscount != null && service.category!.campaignDiscount!.isNotEmpty) {
        _serviceDiscount = service.category!.campaignDiscount!.elementAt(0).discount?.discountAmount?.toDouble() ?? 0.0;
        _discountType = service.category!.campaignDiscount!.elementAt(0).discount?.discountAmountType ?? 'amount';
      } else if (service.serviceDiscount != null && service.serviceDiscount!.isNotEmpty) {
        _serviceDiscount = service.serviceDiscount!.elementAt(0).discount?.discountAmount?.toDouble() ?? 0.0;
        _discountType = service.serviceDiscount!.elementAt(0).discount?.discountType ?? 'amount';
      } else if (service.category?.categoryDiscount != null && service.category!.categoryDiscount!.isNotEmpty) {
        _serviceDiscount = service.category!.categoryDiscount!.elementAt(0).discount?.discountAmount?.toDouble() ?? 0.0;
        _discountType = service.category!.categoryDiscount!.elementAt(0).discount?.discountAmountType ?? 'amount';
      }
    } catch (e) {
      debugPrint('getServiceDiscount error: $e');
      _serviceDiscount = 0.0;
      _discountType = 'amount';
    }
    update();
  }
}
