import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class RecheckController extends GetxController implements GetxService {
  final BookingRequestRepo bookingRequestRepo;
  RecheckController({required this.bookingRequestRepo});

  List<dynamic> _recheckList = [];
  List<dynamic> get recheckList => _recheckList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  int _offset = 1;
  int _pageSize = 1;
  int get offset => _offset;

  String _selectedStatus = 'all';
  String get selectedStatus => _selectedStatus;

  Future<void> getRecheckList({bool reload = false, String status = 'all'}) async {
    if (reload) {
      _offset = 1;
      _selectedStatus = status;
      _isLoading = true;
      update();
    }

    Response response = await bookingRequestRepo.getRecheckList(_offset, status: _selectedStatus);

    if (response.statusCode == 200) {
      final List data = response.body['content'] is Map && response.body['content']['data'] is List
          ? response.body['content']['data'] as List
          : (response.body['content'] is List ? response.body['content'] as List : []);

      if (_offset == 1) {
        _recheckList = data;
      } else {
        _recheckList = [..._recheckList, ...data];
      }
      _pageSize = response.body['content'] is Map && response.body['content']['last_page'] is int
          ? response.body['content']['last_page']
          : 1;
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<void> loadMore() async {
    if (_offset < _pageSize) {
      _offset++;
      await getRecheckList();
    }
  }

  Future<void> updateRecheckStatus(String recheckId, String status, {String note = ''}) async {
    if (_isUpdating) return;
    _isUpdating = true;
    update();

    Response response = await bookingRequestRepo.updateRecheck(recheckId, status, note: note);

    if (response.statusCode == 200) {
      showCustomSnackBar(
        status == 'completed' ? 'recheck_completed_successfully'.tr : 'recheck_started'.tr,
        type: ToasterMessageType.success,
      );
      await getRecheckList(reload: true, status: _selectedStatus);
    } else {
      ApiChecker.checkApi(response);
    }

    _isUpdating = false;
    update();
  }
}
