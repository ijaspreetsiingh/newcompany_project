import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class UnsatisfiedController extends GetxController implements GetxService {
  final UnsatisfiedRepo unsatisfiedRepo;
  UnsatisfiedController({required this.unsatisfiedRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic> _summary = {};
  Map<String, dynamic> get summary => _summary;

  List<dynamic> _servicemen = [];
  List<dynamic> get servicemen => _servicemen;

  List<dynamic> _services = [];
  List<dynamic> get services => _services;

  List<dynamic> _requests = [];
  List<dynamic> get requests => _requests;

  int _offset = 1;
  int _pageSize = 1;
  int get offset => _offset;

  String _selectedStatus = 'all';
  String get selectedStatus => _selectedStatus;

  Future<void> getUnsatisfiedSummary({bool reload = false, String status = 'all'}) async {
    if (reload) {
      _offset = 1;
      _selectedStatus = status;
      _isLoading = true;
      update();
    }

    Response response = await unsatisfiedRepo.getUnsatisfiedSummary(_offset, status: _selectedStatus);

    if (response.statusCode == 200 && response.body is Map && response.body['content'] is Map) {
      final Map<String, dynamic> content = Map<String, dynamic>.from(response.body['content'] as Map);

      _summary = content['summary'] is Map ? Map<String, dynamic>.from(content['summary'] as Map) : {};
      _servicemen = content['servicemen'] is List ? content['servicemen'] as List : [];
      _services = content['services'] is List ? content['services'] as List : [];

      final dynamic requestsData = content['requests'];
      if (requestsData is Map && requestsData['data'] is List) {
        final List<dynamic> page = List<dynamic>.from(requestsData['data'] as List);
        _requests = _offset == 1 ? page : [..._requests, ...page];
        _pageSize = requestsData['last_page'] is int ? requestsData['last_page'] as int : 1;
      } else if (requestsData is List && _offset == 1) {
        _requests = requestsData;
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
      await getUnsatisfiedSummary();
    }
  }
}
