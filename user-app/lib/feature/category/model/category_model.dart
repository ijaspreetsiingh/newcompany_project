import 'package:flutter/material.dart';

class CategoryModel {
  String? id;
  String? slug;
  String? parentId;
  String? name;
  String? image;
  String? imageFullPath;
  int? position;
  String? description;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? serviceCount;
  GlobalKey? globalKey;

  CategoryModel({
    this.id,
    this.slug,
    this.parentId,
    this.name,
    this.image,
    this.imageFullPath,
    this.position,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.serviceCount,
    this.globalKey,
  });

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = _asText(json['id'] ?? json['group_id'] ?? json['category_id']);
    slug = _asText(json['slug'] ?? json['group_slug'] ?? json['category_slug']);
    parentId = _asText(json['parent_id']);
    name = _asText(
      json['name'] ??
          json['group_name'] ??
          json['category_name'] ??
          json['title'],
    );
    image = _asText(json['image']);
    imageFullPath = _asText(json['image_full_path']);
    position = int.tryParse('${json['position']}');
    description = _asText(json['description']);
    final activeValue = json['is_active'] ?? json['status'] ?? json['active'];
    isActive =
        activeValue == true ||
        activeValue == 1 ||
        activeValue?.toString() == '1' ||
        activeValue == null;
    createdAt = _asText(json['created_at']);
    updatedAt = _asText(json['updated_at']);
    serviceCount = int.tryParse(json['services_count'].toString());
    globalKey = GlobalKey(debugLabel: id);
  }

  static String? _asText(dynamic value) {
    if (value == null) return null;
    if (value is List && value.isNotEmpty) return _asText(value.first);
    if (value is Map) {
      final fallback = value.isEmpty ? null : value.values.first;
      final selected =
          value['en'] ??
          value['name'] ??
          value['path'] ??
          value['url'] ??
          fallback;
      if (selected is Map || selected is List) return _asText(selected);
      return selected?.toString();
    }
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['slug'] = slug;
    data['parent_id'] = parentId;
    data['name'] = name;
    data['image'] = image;
    data['image_full_path'] = imageFullPath;
    data['position'] = position;
    data['description'] = description;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['services_count'] = serviceCount;
    return data;
  }
}
