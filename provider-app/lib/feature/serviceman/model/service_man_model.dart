import 'package:jassdbx_provider/feature/dashboard/model/dashboard_serviceman_model.dart';

List<String> _stringListFromJson(dynamic value) {
  if (value is! List) return <String>[];
  return value
      .map<String>((dynamic item) {
        if (item is String) return item;
        if (item is Map) {
          final dynamic image = item['image'] ?? item['url'] ?? item['path'];
          return image?.toString() ?? '';
        }
        return item?.toString() ?? '';
      })
      .where((String item) => item.isNotEmpty)
      .toList();
}

class ServicemanModel {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? identificationNumber;
  String? identificationType;
  List<String>? identificationImage;
  List<String>? identificationImageFullPath;
  String? gender;
  String? profileImage;
  String? profileImageFullPath;
  int? isPhoneVerified;
  int? isEmailVerified;
  int? isActive;
  String? userType;
  String? createdAt;
  String? updatedAt;
  Serviceman? serviceman;

  ServicemanModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.identificationNumber,
    this.identificationType,
    this.identificationImage,
    this.identificationImageFullPath,
    this.gender,
    this.profileImage,
    this.profileImageFullPath,
    this.isPhoneVerified,
    this.isEmailVerified,
    this.isActive,
    this.userType,
    this.createdAt,
    this.updatedAt,
    this.serviceman,
  });

  ServicemanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    identificationNumber = json['identification_number'];
    identificationType = json['identification_type'];
    identificationImage = _stringListFromJson(json['identification_image']);
    identificationImageFullPath = _stringListFromJson(
      json['identification_image_full_path'],
    );
    gender = json['gender'];
    profileImage = json['profile_image'];
    profileImageFullPath = json['profile_image_full_path'];
    isPhoneVerified = json['is_phone_verified'];
    isEmailVerified = json['is_email_verified'];
    isActive = json['is_active'];
    userType = json['user_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    serviceman = json['serviceman'] != null
        ? Serviceman.fromJson(json['serviceman'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['phone'] = phone;
    data['identification_number'] = identificationNumber;
    data['identification_type'] = identificationType;
    data['identification_image'] = identificationImage;
    data['profile_image'] = profileImage;
    data['profile_image_full_path'] = profileImageFullPath;
    data['is_phone_verified'] = isPhoneVerified;
    data['is_email_verified'] = isEmailVerified;
    data['is_active'] = isActive;
    data['user_type'] = userType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (serviceman != null) data['serviceman'] = serviceman!.toJson();
    return data;
  }
}

class Serviceman {
  String? id;
  String? providerId;

  /// Backend se aane wali sub-category assignments.
  /// ServicemanCategoryAssignment is defined in dashboard_serviceman_model.dart
  List<ServicemanCategoryAssignment> assignedCategories;

  Serviceman({
    this.id,
    this.providerId,
    List<ServicemanCategoryAssignment>? assignedCategories,
  }) : assignedCategories = assignedCategories ?? [];

  Serviceman.fromJson(Map<String, dynamic> json) : assignedCategories = [] {
    id = json['id'];
    providerId = json['provider_id'];

    final raw = json['serviceman_categories'];
    if (raw is List) {
      assignedCategories = raw
          .map(
            (e) => ServicemanCategoryAssignment.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    }
  }

  List<String> get subCategoryIds => assignedCategories
      .map((e) => e.subCategoryId)
      .whereType<String>()
      .toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'provider_id': providerId,
    'serviceman_categories': assignedCategories.map((e) => e.toJson()).toList(),
  };
}
