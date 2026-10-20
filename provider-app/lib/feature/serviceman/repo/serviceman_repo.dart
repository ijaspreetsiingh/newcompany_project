import 'package:get/get.dart';
import '../../../util/core_export.dart';

class ServicemanRepo {
  final ApiClient apiClient;
  ServicemanRepo({required this.apiClient});

  Future<Response> getAllServicemanData(int offset, String status) async {
    return await apiClient.getData(
        '${AppConstants.servicemanListUri}?limit=10&offset=$offset&status=$status');
  }

  Future<Response> getServicemanDetails(String id) async {
    // The backend collection endpoint requires limit/offset/status. Details
    // are served by GET /partner/technician/{id}.
    return await apiClient.getData('${AppConstants.servicemanDetailsUri}/$id');
  }

  Future<Response> assignServiceman(
      {String? bookingId, String? subBookingId, String? servicemanId}) async {
    return await apiClient.putData(
      '${AppConstants.servicemanAssignUri}/${bookingId ?? subBookingId}',
      {
        'booking_type': subBookingId != null ? 'repeat' : 'regular',
        'serviceman_id': servicemanId,
        '_method': 'put',
      },
    );
  }

  Future<Response> changeServicemanStatus(String servicemanId) async {
    return await apiClient
        .putData('${AppConstants.servicemanUpdateStatus}?serviceman_id[]=$servicemanId', {});
  }

  Future<Response> getSingleServicemanData(String id) async {
    return await apiClient.getData('${AppConstants.servicemanListUri}?serviceman_id=$id');
  }

  Future<Response> deleteServiceman(String id) async {
    return await apiClient
        .deleteData('${AppConstants.servicemanDeleteUri}?serviceman_id[]=$id');
  }

  /// Add serviceman — sub_category_ids[] form fields bhi bhejo
  Future<Response?> addNewServiceman(
    ServicemanBody servicemanBody,
    XFile? profileImage,
    List<MultipartBody> identityImage,
  ) async {
    final Map<String, String> body = {
      'first_name':       servicemanBody.firstName!,
      'last_name':        servicemanBody.lastName!,
      'email':            servicemanBody.email!,
      'phone':            servicemanBody.phone!,
      'password':         servicemanBody.password!,
      'confirm_password': servicemanBody.confirmedPassword!,
      'identity_type':    servicemanBody.identityType!,
      'identity_number':  servicemanBody.identityNumber!,
    };

    // sub_category_ids[] — repeated body keys ke roop mein bhejo
    // ApiClient.postMultipartData body Map<String,String> hai toh
    // index-based keys use karo: sub_category_ids[0], sub_category_ids[1] ...
    for (int i = 0; i < servicemanBody.subCategoryIds.length; i++) {
      body['sub_category_ids[$i]'] = servicemanBody.subCategoryIds[i];
    }

    return await apiClient.postMultipartData(
      AppConstants.addNewServicemanUri,
      body,
      identityImage,
      profileImage != null ? MultipartBody('profile_image', profileImage) : null,
    );
  }

  Future<Response?> editServicemanInfoWithPassword(
    ServicemanBody servicemanBody,
    XFile? profileImage,
    XFile? identityImage,
    String servicemanId,
  ) async {
    final Map<String, String> body = {
      'first_name':       servicemanBody.firstName!,
      'last_name':        servicemanBody.lastName!,
      'email':            servicemanBody.email!,
      'phone':            servicemanBody.phone!,
      'password':         servicemanBody.password!,
      'confirm_password': servicemanBody.confirmedPassword!,
      'identity_type':    servicemanBody.identityType!,
      'identity_number':  servicemanBody.identityNumber!,
      '_method':          'put',
    };
    return await apiClient.postMultipartData(
      '${AppConstants.addNewServicemanUri}/$servicemanId',
      body,
      identityImage != null ? [MultipartBody('identity_image[]', identityImage)] : null,
      profileImage != null ? MultipartBody('profile_image', profileImage) : null,
    );
  }

  /// Edit serviceman (no password change) — sub_category_ids[] bhi update karo
  Future<Response?> editServicemanInfoWithoutPassword(
    ServicemanBody servicemanBody,
    XFile? profileImage,
    List<MultipartBody> identityImage,
    String servicemanId,
  ) async {
    final Map<String, String> body = {
      'first_name':      servicemanBody.firstName!,
      'last_name':       servicemanBody.lastName!,
      'email':           servicemanBody.email!,
      'phone':           servicemanBody.phone!,
      'identity_type':   servicemanBody.identityType!,
      'identity_number': servicemanBody.identityNumber!,
      '_method':         'put',
    };

    for (int i = 0; i < servicemanBody.subCategoryIds.length; i++) {
      body['sub_category_ids[$i]'] = servicemanBody.subCategoryIds[i];
    }

    return await apiClient.postMultipartData(
      '${AppConstants.addNewServicemanUri}/$servicemanId',
      body,
      identityImage,
      profileImage != null ? MultipartBody('profile_image', profileImage) : null,
    );
  }

  /// Provider ki subscribed sub-categories fetch karo
  /// (ye wahi sub-categories hain jo admin ne provider ko assign ki hain)
  Future<Response> getProviderSubscribedSubCategories() async {
    return await apiClient.getData(
        '${AppConstants.subscriptionListUrl}?limit=200&offset=1');
  }
}
