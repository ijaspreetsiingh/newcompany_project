/// Progressive radius search ka shared mutable state.
///
/// Ye class jaan-boojh kar dependency-free rakhi gayi hai taaki low-level
/// [ApiClient] (HTTP layer) isse import kar sake bina kisi circular
/// dependency ke. Radius sirf tab set hota hai jab tak location change na
/// ho — RadiusSearchController ise reset karta hai.
class SearchRadiusState {
  SearchRadiusState._();

  /// Customer ki current search radius (km). `null` = server default
  /// (zone ka initial radius).
  static double? activeRadius;

  /// Admin-configured initial radius (zone ka `provider_search_radius`).
  static double? initialRadius;

  /// Admin-configured maximum expandable radius (zone ka `max_search_radius`).
  static double? maxRadius;
}
