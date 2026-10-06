import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class RecheckController extends GetxController implements GetxService {
  final RecheckRepo recheckRepo;
  RecheckController({required this.recheckRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic> _summary = {};
  Map<String, dynamic> get summary => _summary;

  List<dynamic> _servicemen = [];
  List<dynamic> get servicemen => _servicemen;

  List<dynamic> _rechecks = [];
  List<dynamic> get rechecks => _rechecks;

  int _offset = 1;
  int _pageSize = 1;
  int get offset => _offset;

  String _selectedStatus = 'all';
  String get selectedStatus => _selectedStatus;

  Future<void> getRecheckSummary({bool reload = false, String status = 'all'}) async {
    if (reload) {
      _offset = 1;
      _selectedStatus = status;
      _isLoading = true;
      update();
    }

    Response response = await recheckRepo.getRecheckSummary(_offset, status: _selectedStatus);

    if (response.statusCode == 200 && response.body is Map && response.body['content'] is Map) {
      final Map<String, dynamic> content = Map<String, dynamic>.from(response.body['content'] as Map);

      _summary = content['summary'] is Map ? Map<String, dynamic>.from(content['summary'] as Map) : {};
      _servicemen = content['servicemen'] is List ? content['servicemen'] as List : [];

      final dynamic rechecksData = content['rechecks'];
      if (rechecksData is Map && rechecksData['data'] is List) {
        final List<dynamic> page = List<dynamic>.from(rechecksData['data'] as List);
        _rechecks = _offset == 1 ? page : [..._rechecks, ...page];
        _pageSize = rechecksData['last_page'] is int ? rechecksData['last_page'] as int : 1;
      } else if (rechecksData is List && _offset == 1) {
        _rechecks = rechecksData;
        _pageSize = 1;
      }
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<void> loadMore() async {
    if (_offset < _pageSize) {
      _offset++;
      await getRecheckSummary();
    }
  }
}
