import 'package:jdds/util/app_constants.dart';

/// Backend APP_URL (localhost / production domain) aur app ka actual baseUrl
/// alag ho sakte hain (jaise Android emulator me backend 10.0.2.2 par hai,
/// par APP_URL localhost:8000). Backend se aane wali absolute image URLs ka
/// origin app ke baseUrl se normalize karo, warna emulator/host par images
/// load nahi hoti. External URLs (firebase, google maps) untouched rehte hain.
String getFullImageUrl(String? url) {
  if (url == null || url.trim().isEmpty) {
    return '';
  }
  final String trimmed = url.trim();

  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
    return '${AppConstants.baseUrl}/${trimmed.startsWith('/') ? trimmed.substring(1) : trimmed}';
  }

  final Uri? uri = Uri.tryParse(trimmed);
  if (uri == null || uri.host.isEmpty) {
    return trimmed;
  }

  final String host = uri.host.toLowerCase();
  final bool isLoopback = host == 'localhost' ||
      host == '127.0.0.1' ||
      host == '0.0.0.0' ||
      host == '::1';
  final bool isBackendPath = uri.path.startsWith('/storage/') ||
      uri.path.startsWith('/public/storage/') ||
      uri.path.startsWith('/public/assets/') ||
      uri.path.startsWith('/assets/') ||
      uri.path.startsWith('/image-proxy');

  if (!isLoopback && !isBackendPath) {
    return trimmed;
  }

  final Uri base = Uri.parse(AppConstants.baseUrl);
  return base
      .replace(
        path: uri.path,
        query: uri.query.isEmpty ? null : uri.query,
      )
      .toString();
}
