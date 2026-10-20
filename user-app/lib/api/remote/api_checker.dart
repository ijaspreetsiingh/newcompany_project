import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';


class ApiChecker {
  static void checkApi(Response response, {bool showDefaultToaster = true}) {

    final dynamic body = response.body;
    final String? responseCode = body is Map ? body['response_code']?.toString() : null;

    // zone_404 is a location/business validation response in this backend,
    // not an expired customer session. Do not erase a valid login for it.
    if (response.statusCode == 401 && responseCode == 'zone_404') {
      final address = Get.find<LocationController>().getUserAddress();
      if (address != null) {
        address.zoneId = '';
        Get.find<LocationController>().saveUserAddress(address);
      }
      customSnackBar(
        body is Map && body['message'] != null
            ? body['message'].toString()
            : 'zone_not_available'.tr,
        showDefaultSnackBar: showDefaultToaster,
      );
      return;
    }

    if(response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData(response: response);
      if(Get.currentRoute != RouteHelper.getinitialRoute()){
        Get.offAllNamed(RouteHelper.getinitialRoute());
        customSnackBar("${response.statusCode!}".tr);
      }
      return;
    } else if(response.statusCode == 204) {
      customSnackBar('information_not_found'.tr, showDefaultSnackBar: showDefaultToaster);
      Get.offAllNamed(RouteHelper.getinitialRoute());

    }else if(response.statusCode == 500){
      customSnackBar("${response.statusCode!}".tr, showDefaultSnackBar: showDefaultToaster);
    }
    else if(response.statusCode == 400 && response.body != null && response.body['errors'] !=null){
      customSnackBar("${response.body['errors'][0]['message']}",showDefaultSnackBar: showDefaultToaster);
    }
    else if(response.statusCode == 429){
      customSnackBar("too_many_request".tr, showDefaultSnackBar: showDefaultToaster);
    }
    else{
      /// Null-safety: body can be null on network failure / empty response,
      /// fallback to status code message instead of crashing on body['message'].
      final dynamic body = response.body;
      String message;
      if (body is Map<String, dynamic> && body['message'] != null) {
        message = '${body['message']}';
      } else if (body is Map && body['message'] != null) {
        message = '${body['message']}';
      } else {
        message = 'error_loading'.tr;
      }
      customSnackBar(message, showDefaultSnackBar: showDefaultToaster);
    }
  }
}

