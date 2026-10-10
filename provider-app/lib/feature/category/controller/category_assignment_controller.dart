import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class CategoryAssignmentController extends GetxController
    implements GetxService {
  final CategoryAssignmentRepo categoryAssignmentRepo;

  CategoryAssignmentController({required this.categoryAssignmentRepo});

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;

  CategoryAssignmentData? _data;
  CategoryAssignmentData? get data => _data;

  List<AssignmentCategory> get categories => _data?.categories ?? [];
  List<String> get currentSubCategoryIds => _data?.currentSubCategoryIds ?? [];
  PendingCategoryRequest? get pendingRequest => _data?.pendingRequest;

  final Set<String> _selectedIds = <String>{};
  Set<String> get selectedIds => _selectedIds;

  final TextEditingController noteController = TextEditingController();

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  int get assignedCount => currentSubCategoryIds.length;
  int get selectedCount => _selectedIds.length;

  /// jinhi sub categories par abhi assignment hai woh by default selected
  bool isSelected(String id) => _selectedIds.contains(id);

  Future<void> loadData({bool showLoader = true}) async {
    if (showLoader) {
      _isLoading = true;
      update();
    }

    Response response = await categoryAssignmentRepo.getAssignment();
    if (response.statusCode == 200) {
      _data = CategoryAssignmentData.fromJson(response.body['content']);
      _selectedIds
        ..clear()
        ..addAll(_data?.currentSubCategoryIds ?? []);
      noteController.clear();
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  void toggleSubCategory(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    update();
  }

  void clearSelection() {
    _selectedIds.clear();
    update();
  }

  Future<bool> _submit(String requestType) async {
    _isSubmitting = true;
    update();

    Response response = await categoryAssignmentRepo.submitRequest(
      requestType: requestType,
      subCategoryIds: requestType == 'replace'
          ? _selectedIds.toList()
          : const [],
      note: noteController.text.trim(),
    );

    _isSubmitting = false;

    if (response.statusCode == 200) {
      showCustomSnackBar(
        response.body['content']?['message'] ?? response.body['message'],
        type: ToasterMessageType.success,
      );
      await loadData(showLoader: false);
      return true;
    }

    ApiChecker.checkApi(response);
    update();
    return false;
  }

  /// current assignment ki jagah naye sub categories ki request
  Future<bool> submitReplaceRequest() async {
    if (_selectedIds.isEmpty) {
      showCustomSnackBar('select_at_least_one_sub_category'.tr);
      return false;
    }
    return _submit('replace');
  }

  /// poori assignment hi cancel karwani hai
  Future<bool> submitCancelRequest() async {
    return _submit('cancel');
  }
}
