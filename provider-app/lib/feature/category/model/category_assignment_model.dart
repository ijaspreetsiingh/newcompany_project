class CategoryAssignmentData {
  final List<AssignmentCategory> categories;
  final List<String> currentMainCategoryIds;
  final List<String> currentSubCategoryIds;
  final PendingCategoryRequest? pendingRequest;

  CategoryAssignmentData({
    required this.categories,
    required this.currentMainCategoryIds,
    required this.currentSubCategoryIds,
    required this.pendingRequest,
  });

  factory CategoryAssignmentData.fromJson(Map<String, dynamic> json) {
    return CategoryAssignmentData(
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((item) => AssignmentCategory.fromJson(item))
          .toList(),
      currentMainCategoryIds: (json['current_main_category_ids']
              as List<dynamic>? ??
          [])
          .map((item) => item.toString())
          .toList(),
      currentSubCategoryIds: (json['current_sub_category_ids'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      pendingRequest: json['pending_request'] == null
          ? null
          : PendingCategoryRequest.fromJson(json['pending_request']),
    );
  }
}

class AssignmentCategory {
  final String? id;
  final String? name;
  final bool isAssigned;
  final List<AssignmentSubCategory> subCategories;

  AssignmentCategory({
    required this.id,
    required this.name,
    required this.isAssigned,
    required this.subCategories,
  });

  factory AssignmentCategory.fromJson(Map<String, dynamic> json) {
    return AssignmentCategory(
      id: json['id'],
      name: json['name'],
      isAssigned: json['is_assigned'] == true,
      subCategories: (json['sub_categories'] as List<dynamic>? ?? [])
          .map((item) => AssignmentSubCategory.fromJson(item))
          .toList(),
    );
  }
}

class AssignmentSubCategory {
  final String? id;
  final String? name;
  final String? description;
  final String? image;
  final bool isAssigned;

  AssignmentSubCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.isAssigned,
  });

  factory AssignmentSubCategory.fromJson(Map<String, dynamic> json) {
    return AssignmentSubCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      isAssigned: json['is_assigned'] == true,
    );
  }
}

class PendingCategoryRequest {
  final String? id;
  final String? requestType;
  final List<String> requestedSubCategoryIds;
  final String? note;

  PendingCategoryRequest({
    required this.id,
    required this.requestType,
    required this.requestedSubCategoryIds,
    required this.note,
  });

  factory PendingCategoryRequest.fromJson(Map<String, dynamic> json) {
    return PendingCategoryRequest(
      id: json['id'],
      requestType: json['request_type'],
      requestedSubCategoryIds: (json['requested_sub_category_ids']
              as List<dynamic>? ??
          [])
          .map((item) => item.toString())
          .toList(),
      note: json['note'],
    );
  }
}
