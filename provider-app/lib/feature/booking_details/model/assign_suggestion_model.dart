/// AUTO-ASSIGN: partner/order/assign-suggestions response ek serviceman entry.
class AssignSuggestion {
  final String id;
  final String name;
  final String image;
  final double? distanceKm;
  final String? slotStatus;
  final bool isCategoryMatch;
  final List<String> assignedCategories;

  AssignSuggestion({
    required this.id,
    required this.name,
    this.image = '',
    this.distanceKm,
    this.slotStatus,
    this.isCategoryMatch = false,
    this.assignedCategories = const [],
  });

  factory AssignSuggestion.fromJson(Map<String, dynamic> json) {
    return AssignSuggestion(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      distanceKm: json['distance_km'] != null ? double.tryParse(json['distance_km'].toString()) : null,
      slotStatus: json['slot_status']?.toString(),
      isCategoryMatch: json['is_category_match'] == true || json['is_category_match']?.toString() == '1',
      assignedCategories: (json['assigned_categories'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}
