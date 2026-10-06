import 'package:jdds/api/local/cache_response.dart';
import 'package:jdds/helper/data_sync_helper.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/models/category_types_model.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryRepo categoryRepo;
  CategoryController({required this.categoryRepo});

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? _subCategoryList;
  List<Service>? _searchProductList = [];
  List<CategoryModel>? _campaignBasedCategoryList;

  bool _isLoading = false;
  int? _pageSize;
  bool? _isSearching = false;
  final String _type = 'all';
  final String _searchText = '';

  List<CategoryModel>? get categoryList => _categoryList;
  List<CategoryModel>? get campaignBasedCategoryList =>
      _campaignBasedCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;
  List<Service>? get searchServiceList => _searchProductList;
  bool get isLoading => _isLoading;
  int? get pageSize => _pageSize;
  bool? get isSearching => _isSearching;
  String? get type => _type;
  String? get searchText => _searchText;

  Future<void> getCategoryList(bool reload) async {
    if (_categoryList == null || reload) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => categoryRepo.getCategoryList<CacheResponseData>(
          source: DataSourceEnum.local,
        ),
        fetchFromClient: () =>
            categoryRepo.getCategoryList(source: DataSourceEnum.client),
        onResponse: (data, source) {
          try {
            final categories = _extractCategories(data);
            _categoryList = categories
                .whereType<Map>()
                .map(
                  (item) =>
                      CategoryModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList();
            debugPrint(
              'Home categories: source=$source, count=${_categoryList!.length}, '
              'names=${_categoryList!.take(4).map((category) => category.name).toList()}',
            );
            if (Get.isRegistered<AllSearchController>()) {
              Get.find<AllSearchController>().insertCategoryCheckedList();
            }
          } catch (error) {
            // Keep the last successfully loaded categories visible on a malformed refresh.
            debugPrint('Category response parse error: $error');
            _categoryList ??= <CategoryModel>[];
          }
          debugPrint(
            'CategoryController.update() called - categoryList.length=${_categoryList?.length}',
          );
          update();
        },
      );
    }
  }

  List<dynamic> _extractCategories(dynamic response) {
    if (response is List) return response;
    if (response is! Map) return const <dynamic>[];
    final dynamic content = response['content'];
    if (content is List) return content;
    if (content is Map) {
      for (final key in [
        'data',
        'groups',
        'categories',
        'items',
        'records',
        'result',
      ]) {
        if (content[key] is List) return content[key] as List;
      }
    }
    for (final key in [
      'data',
      'groups',
      'categories',
      'items',
      'records',
      'result',
    ]) {
      if (response[key] is List) return response[key] as List;
    }
    // Some API versions nest/paginate groups under different keys. Walk the
    // response recursively instead of assuming a fixed content.data shape.
    return _findCategoryList(response) ?? const <dynamic>[];
  }

  List<dynamic>? _findCategoryList(dynamic value) {
    if (value is List) {
      if (value.isNotEmpty &&
          value.any((item) => item is Map && _looksLikeCategory(item))) {
        return value;
      }
      for (final item in value) {
        final nested = _findCategoryList(item);
        if (nested != null) return nested;
      }
    } else if (value is Map) {
      for (final nestedValue in value.values) {
        final nested = _findCategoryList(nestedValue);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  bool _looksLikeCategory(Map value) =>
      value.containsKey('name') ||
      value.containsKey('group_name') ||
      value.containsKey('category_name') ||
      value.containsKey('slug') ||
      value.containsKey('group_id');

  Future<void> getSubCategoryList(
    String categorySlug, {
    bool shouldUpdate = true,
  }) async {
    _subCategoryList = null;
    if (shouldUpdate) {
      update();
    }
    Response response = await categoryRepo.getSubCategoryList(categorySlug);
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_200') {
      _subCategoryList = [];
      response.body['content']['data'].forEach(
        (category) => _subCategoryList!.addIf(
          CategoryModel.fromJson(category).isActive,
          CategoryModel.fromJson(category),
        ),
      );
    } else {
      _subCategoryList = [];
    }
    update();
  }

  Future<void> getCampaignBasedCategoryList(
    String campaignID,
    bool isWithPagination,
  ) async {
    printLog("inside_campaign_based_category !");
    Response response = await categoryRepo.getItemsBasedOnCampaignId(
      campaignID: campaignID,
    );

    if (response.body['response_code'] == 'default_200') {
      if (!isWithPagination) {
        _campaignBasedCategoryList = [];
      }
      response.body['content']['data'].forEach((categoryTypesModel) {
        if (CategoryTypesModel.fromJson(categoryTypesModel).category != null) {
          _campaignBasedCategoryList!.add(
            CategoryTypesModel.fromJson(categoryTypesModel).category!,
          );
        }
      });
      _isLoading = false;
      Get.toNamed(RouteHelper.getCategoryRoute('fromCampaign', campaignID));
    } else {
      if (response.statusCode != 200) {
        ApiChecker.checkApi(response);
      } else {
        customSnackBar(
          'campaign_is_not_available_for_this_service'.tr,
          type: ToasterMessageType.info,
        );
      }
    }
    update();
  }

  void toggleSearch() {
    _isSearching = !_isSearching!;
    _searchProductList = [];
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }
}
