class MyServiceCategory {
  final String? id;
  final String? name;
  final String? image;
  final List<MyServiceSubCategory> subCategories;

  MyServiceCategory({
    this.id,
    this.name,
    this.image,
    this.subCategories = const [],
  });

  factory MyServiceCategory.fromJson(Map<String, dynamic> json) {
    return MyServiceCategory(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      subCategories: (json['sub_categories'] as List? ?? [])
          .map((e) => MyServiceSubCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class MyServiceSubCategory {
  final String? id;
  final String? name;
  final String? image;
  final List<MyServiceItem> services;

  MyServiceSubCategory({this.id, this.name, this.image, this.services = const []});

  factory MyServiceSubCategory.fromJson(Map<String, dynamic> json) {
    return MyServiceSubCategory(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      services: (json['services'] as List? ?? [])
          .map((e) => MyServiceItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class AssignableSubCategory {
  final String? id;
  final String? name;
  final String? categoryId;
  final String? categoryName;

  AssignableSubCategory({
    this.id,
    this.name,
    this.categoryId,
    this.categoryName,
  });

  factory AssignableSubCategory.fromJson(Map<String, dynamic> json) {
    return AssignableSubCategory(
      id: json['id'],
      name: json['name'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
    );
  }
}

class MyServiceItem {
  final String id;
  final String? parentServiceId;
  final String name;
  final String? shortDescription;
  final String? description;
  final String? coverImage;
  final String? categoryId;
  final String? subCategoryId;
  final int isActive;
  final String approvalStatus;
  final bool isOwned;
  final bool isEdited;
  final bool isPending;
  final List<ServiceVariant> variants;
  final List<ServiceVariant>? baseVariants;

  MyServiceItem({
    required this.id,
    this.parentServiceId,
    required this.name,
    this.shortDescription,
    this.description,
    this.coverImage,
    this.categoryId,
    this.subCategoryId,
    this.isActive = 1,
    this.approvalStatus = 'approved',
    this.isOwned = false,
    this.isEdited = false,
    this.isPending = false,
    this.variants = const [],
    this.baseVariants,
  });

  double get priceFrom => variants.isEmpty
      ? 0
      : (variants.map((v) => v.price).reduce((a, b) => a < b ? a : b));

  factory MyServiceItem.fromJson(Map<String, dynamic> json) {
    return MyServiceItem(
      id: json['id'] ?? '',
      parentServiceId: json['parent_service_id'],
      name: json['name'] ?? '',
      shortDescription: json['short_description'],
      description: json['description'],
      coverImage: json['cover_image'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      isActive: json['is_active'] ?? 1,
      approvalStatus: json['approval_status'] ?? 'approved',
      isOwned: json['is_owned'] ?? false,
      isEdited: json['is_edited'] ?? false,
      isPending: json['is_pending'] ?? false,
      variants: (json['variants'] as List? ?? [])
          .map((e) => ServiceVariant.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      baseVariants: json['base_variants'] == null
          ? null
          : (json['base_variants'] as List)
              .map((e) => ServiceVariant.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
    );
  }
}

class ServiceVariant {
  final String variantKey;
  final String variant;
  final double price;

  ServiceVariant({
    required this.variantKey,
    required this.variant,
    required this.price,
  });

  factory ServiceVariant.fromJson(Map<String, dynamic> json) {
    return ServiceVariant(
      variantKey: json['variant_key'] ?? '',
      variant: json['variant'] ?? '',
      price: double.tryParse('${json['price']}') ?? 0,
    );
  }
}
