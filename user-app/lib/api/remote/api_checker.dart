import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';


class ApiChecker {
  static void checkApi(Response response, {bool showDefaultToaster = true}) {

    if(response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData(response: response);
      if(Get.currentRoute != RouteHelper.getInitialRoute()){
        Get.offAllNamed(RouteHelper.getInitialRoute());
        customSnackBar("${response.statusCode!}".tr);
      }
    }if(response.statusCode == 204) {
      customSnackBar('information_not_found'.tr, showDefaultSnackBar: showDefaultToaster);
      Get.offAllNamed(RouteHelper.getInitialRoute());

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
