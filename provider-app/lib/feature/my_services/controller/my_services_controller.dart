import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class MyServicesController extends GetxController implements GetxService {
  final MyServicesRepo myServicesRepo;

  MyServicesController({required this.myServicesRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  int _selectedCategoryIndex = 0;
  int get selectedCategoryIndex => _selectedCategoryIndex;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'all'; // all | mine | admin | pending | edited
  String get statusFilter => _statusFilter;

  List<MyServiceCategory> categories = [];
  List<AssignableSubCategory> assignableSubCategories = [];
  bool _hasFetchedOnce = false;
  bool get hasFetchedOnce => _hasFetchedOnce;

  // Admin wizard Step 6 ke toggle (missing permission = allow, taaki purana
  // backend break na ho).
  bool _canCreate = true;
  bool get canCreate => _canCreate;

  bool _canEdit = true;
  bool get canEdit => _canEdit;

  bool get isReadOnly => !_canCreate && !_canEdit;

  /// Apni service = create toggle, admin service (clone) = edit toggle.
  bool canEditService(MyServiceItem service) =>
      service.parentServiceId == null ? _canCreate : _canEdit;

  bool get canAddService => _canCreate;

  bool get isFiltering =>
      _searchQuery.trim().isNotEmpty || _statusFilter != 'all';

  int get totalServices => categories.fold(
      0,
      (sum, category) =>
          sum + category.subCategories.fold(0, (s, sc) => s + sc.services.length));

  int get totalSubCategories => categories.fold(
      0, (sum, category) => sum + category.subCategories.length);

  void selectCategory(int index) {
    if (index < 0 || index >= categories.length) return;
    _selectedCategoryIndex = index;
    update();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    update();
  }

  void clearSearch() {
    _searchQuery = '';
    update();
  }

  void setStatusFilter(String status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    update();
  }

  bool _matchesStatus(MyServiceItem service) {
    switch (_statusFilter) {
      case 'mine':
        return service.isOwned && !service.isPending;
      case 'admin':
        return !service.isOwned;
      case 'pending':
        return service.isPending;
      case 'edited':
        return service.isEdited;
      default:
        return true;
    }
  }

  bool _matchesQuery(MyServiceItem service) {
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    return service.name.toLowerCase().contains(query) ||
        (service.shortDescription ?? '').toLowerCase().contains(query);
  }

  /// Flat list — used when search or status filter is on (all categories).
  List<MyServiceItem> get filteredServices {
    final List<MyServiceItem> result = [];
    for (final MyServiceCategory category in categories) {
      for (final MyServiceSubCategory subCategory in category.subCategories) {
        for (final MyServiceItem service in subCategory.services) {
          if (_matchesStatus(service) && _matchesQuery(service)) {
            result.add(service);
          }
        }
      }
    }
    return result;
  }

  /// Selected category + status filter (tree view).
  List<MyServiceSubCategory> get visibleSubCategories {
    if (categories.isEmpty || _selectedCategoryIndex >= categories.length) {
      return [];
    }
    return categories[_selectedCategoryIndex]
        .subCategories
        .map((subCategory) => MyServiceSubCategory(
              id: subCategory.id,
              name: subCategory.name,
              image: subCategory.image,
              services: subCategory.services
                  .where((service) => _matchesStatus(service))
                  .toList(),
            ))
        .toList();
  }

  /// Dashboard section ke liye — ek hi call, dobara mat maaro.
  bool _initialFetchStarted = false;

  Future<void> ensureLoaded() async {
    if (_hasFetchedOnce || _initialFetchStarted) return;
    _initialFetchStarted = true;
    try {
      await getMyServices();
    } finally {
      _initialFetchStarted = false;
    }
  }

  Future<bool> getMyServices({bool showLoader = true}) async {
    if (showLoader) {
      _isLoading = true;
      update();
    }

    Response response = await myServicesRepo.getMyServices();

    if (showLoader) {
      _isLoading = false;
    }
    _hasFetchedOnce = true;

    if (response.statusCode == 204) {
      categories = [];
      assignableSubCategories = [];
      update();
      return true;
    }

    if (response.statusCode == 200 && response.body['content'] != null) {
      Map<String, dynamic> content =
          Map<String, dynamic>.from(response.body['content']);
      categories = (content['categories'] as List? ?? [])
          .map((e) => MyServiceCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      assignableSubCategories =
          (content['assignable_sub_categories'] as List? ?? [])
              .map((e) =>
                  AssignableSubCategory.fromJson(Map<String, dynamic>.from(e)))
              .toList();

      final Map<String, dynamic> permissions = content['permissions'] == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(content['permissions']);
      _canCreate = (permissions['can_create'] ?? true) == true;
      _canEdit = (permissions['can_edit'] ?? true) == true;

      if (_selectedCategoryIndex >= categories.length) {
        _selectedCategoryIndex = 0;
      }
      update();
      return true;
    }

    update();
    showCustomSnackBar(
        response.body['message'] ?? 'something_went_wrong'.tr);
    return false;
  }

  Future<bool> updateService({
    required String serviceId,
    required Map<String, double> prices,
    required String shortDescription,
    XFile? image,
  }) async {
    if (prices.isEmpty) {
      showCustomSnackBar('price_is_required'.tr);
      return false;
    }

    _isSubmitting = true;
    update();

    Map<String, String> body = {
      '_method': 'put',
      'short_description': shortDescription.trim(),
    };
    prices.forEach((key, value) {
      body['price[$key]'] = value.toString();
    });

    List<MultipartBody> files = [];
    if (image != null) {
      files.add(MultipartBody('cover_image', image));
    }

    Response response =
        await myServicesRepo.updateService(id: serviceId, body: body, files: files);

    _isSubmitting = false;

    if (response.statusCode == 200) {
      await getMyServices(showLoader: false);
      return true;
    }

    update();
    showCustomSnackBar(_errorMessage(response));
    return false;
  }

  Future<bool> createService({
    required String name,
    required String subCategoryId,
    required String shortDescription,
    required String description,
    required double price,
    required String variantName,
    required XFile image,
  }) async {
    _isSubmitting = true;
    update();

    Map<String, String> body = {
      'name': name.trim(),
      'sub_category_id': subCategoryId,
      'short_description': shortDescription.trim(),
      'description': description.trim(),
      'price': price.toString(),
      'variant_name': variantName.trim().isEmpty ? 'Standard' : variantName.trim(),
    };

    Response response = await myServicesRepo.createService(
      body: body,
      files: [MultipartBody('cover_image', image)],
    );

    _isSubmitting = false;

    if (response.statusCode == 200) {
      await getMyServices(showLoader: false);
      showCustomSnackBar(
          response.body['message'] ?? 'service_sent_for_approval'.tr,
          type: ToasterMessageType.success);
      return true;
    }

    update();
    showCustomSnackBar(_errorMessage(response));
    return false;
  }

  Future<bool> deleteService(String serviceId) async {
    _isSubmitting = true;
    update();

    Response response = await myServicesRepo.deleteService(serviceId);

    _isSubmitting = false;

    if (response.statusCode == 200) {
      await getMyServices(showLoader: false);
      return true;
    }

    update();
    showCustomSnackBar(_errorMessage(response));
    return false;
  }

  String _errorMessage(Response response) {
    try {
      if (response.body is Map && response.body['errors'] is List) {
        List errors = response.body['errors'];
        if (errors.isNotEmpty) {
          if (errors.first is Map && errors.first['message'] != null) {
            return '${errors.first['message']}';
          }
          return '${errors.first}';
        }
      }
      if (response.body is Map && response.body['message'] != null) {
        return '${response.body['message']}';
      }
    } catch (_) {}
    return 'something_went_wrong'.tr;
  }
}
