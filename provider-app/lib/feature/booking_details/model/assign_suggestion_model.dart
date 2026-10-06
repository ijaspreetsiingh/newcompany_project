/// AUTO-ASSIGN: partner/order/assign-suggestions response ek serviceman entry.
class AssignSuggestion {
  final String id;
  final String name;
  final String image;
  final double? distanceKm;
  final String? slotStatus;

  AssignSuggestion({
    required this.id,
    required this.name,
    this.image = '',
    this.distanceKm,
    this.slotStatus,
  });

  factory AssignSuggestion.fromJson(Map<String, dynamic> json) {
    return AssignSuggestion(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      distanceKm: json['distance_km'] != null ? double.tryParse(json['distance_km'].toString()) : null,
      slotStatus: json['slot_status']?.toString(),
    );
  }
}
