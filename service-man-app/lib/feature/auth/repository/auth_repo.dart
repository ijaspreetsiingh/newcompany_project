import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';

class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  // W3.18: token secure storage (Keystore/Keychain) + in-memory cache
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static String? tokenCache;

  AuthRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response?> login({
    required String emailOrPhone,
    required String password,
    required String type,
  }) async {
    Map<String, String> body = {"password": password};
    if (type == "email") {
      body["email"] = emailOrPhone;
    } else {
      body["phone"] = emailOrPhone;
    }
    return await apiClient.postData(AppConstants.loginUrl, body);
  }

  Future<Response?> updateToken() async {
    String? deviceToken;
    if (GetPlatform.isIOS) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: true,
            sound: true,
          );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        deviceToken = await _saveDeviceToken();
      }
    } else {
      deviceToken = await _saveDeviceToken();
    }

    // Token null hai to backend ko '@' mat bhejo — backend me purana valid
    // token overwrite ho jaata tha aur notification aana band ho jaate the
    if (deviceToken == null || deviceToken.isEmpty || deviceToken == '@') {
      if (kDebugMode) {
        print('updateToken skipped: fcm token unavailable');
      }
      return null;
    }

    FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
    if (Get.find<UserController>().zoneId != null) {
      FirebaseMessaging.instance.subscribeToTopic(
        '${AppConstants.topic}-${Get.find<UserController>().zoneId}',
      );
    }
    return await apiClient.putData(AppConstants.tokenUri, {
      "fcm_token": deviceToken,
    });
  }

  // On-duty toggle — backend par bhi update hota hai taki auto-assign
  // sirf on-duty servicemen ko ho
  Future<Response?> updateWorkStatus(bool isOnDuty) async {
    return await apiClient.putData(AppConstants.workStatusUri, {
      "is_on_duty": isOnDuty ? "1" : "0",
    });
  }

  Future<Response?> getWorkStatus() async {
    return await apiClient.getData(AppConstants.workStatusUri);
  }

  Future<String?> _saveDeviceToken() async {
    String? deviceToken;
    if (!GetPlatform.isWeb) {
      try {
        deviceToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        if (kDebugMode) {
          print("");
        }
      }
    }
    if (deviceToken != null) {
      if (kDebugMode) {
        print('--------Device Token---------- $deviceToken');
      }
    }
    return deviceToken;
  }

  Future<void> unsubscribeToken() async {
    if (GetPlatform.isAndroid) {
      FirebaseMessaging.instance.unsubscribeFromTopic(
        '${AppConstants.topic}-${Get.find<UserController>().zoneId}',
      );
      apiClient.putData(AppConstants.tokenUri, {
        "fcm_token": "@",
      });
    }
  }

  Future<Response> sendOtpForForgetPassword(
    String identity,
    String identityType,
  ) async {
    return await apiClient.postData(AppConstants.sendOtpForForgetPassword, {
      "identity": identity,
      "identity_type": identityType,
    });
  }

  Future<Response> verifyOtpForForgetPassword(
    String identity,
    String identityType,
    String otp,
  ) async {
    return await apiClient.postData(
      AppConstants.verifyOtpForForgetPasswordScreen,
      {"identity": identity, 'otp': otp, "identity_type": identityType},
    );
  }

  Future<Response> verifyOtpForFirebaseOtpLogin({
    String? session,
    String? phone,
    String? code,
  }) async {
    return await apiClient.postData(AppConstants.firebaseOtpVerify, {
      "sessionInfo": session,
      'phoneNumber': phone,
      'code': code,
      "user_type": "provider-serviceman",
    });
  }

  Future<Response?> resetPassword(
    String identity,
    String identityType,
    String otp,
    String password,
    String confirmPassword,
    int isFirebaseOtp,
  ) async {
    return await apiClient.putData(AppConstants.resetPasswordUri, {
      "_method": "put",
      "identity": identity,
      "identity_type": identityType,
      "otp": otp,
      "password": password,
      "confirm_password": confirmPassword,
      "is_firebase_otp": isFirebaseOtp,
    });
  }

  // for  user token
  Future<bool?> saveUserToken(String token) async {
    apiClient.token = token;
    apiClient.updateHeader(
      token,
      null,
      sharedPreferences.getString(AppConstants.languageCode),
    );
    tokenCache = token;
    await _secureStorage.write(key: AppConstants.token, value: token);
    await sharedPreferences.remove(AppConstants.token);
    return true;
  }

  bool isLoggedIn() {
    return tokenCache != null || sharedPreferences.containsKey(AppConstants.token);
  }

  bool clearSharedData() {
    if (GetPlatform.isAndroid) {
      FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
      FirebaseMessaging.instance.unsubscribeFromTopic(
        '${AppConstants.topic}-${Get.find<UserController>().zoneId}',
      );
      apiClient.putData(AppConstants.tokenUri, {
        "fcm_token": "@",
      });
    }
    tokenCache = null;
    _secureStorage.delete(key: AppConstants.token);
    sharedPreferences.remove(AppConstants.token);

    apiClient.token = null;
    apiClient.updateHeader(null, null, null);
    return true;
  }

  // for  Remember Email
  Future<void> saveUserNumberAndPassword(
    String number,
    String password,
    String countryCode,
  ) async {
    try {
      // W3.18: plaintext password kabhi store nahi — purana copy delete
      await sharedPreferences.remove(AppConstants.userPassword);
      await sharedPreferences.setString(AppConstants.userNumber, number);
      await sharedPreferences.setString(
        AppConstants.userCountryCode,
        countryCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  String getUserNumber() {
    return sharedPreferences.getString(AppConstants.userNumber) ?? "";
  }

  String getUserCountryCode() {
    return sharedPreferences.getString(AppConstants.userCountryCode) ?? "";
  }

  String getUserPassword() {
    // W3.18: password persist nahi hota
    return "";
  }

  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences.remove(AppConstants.userPassword);
    await sharedPreferences.remove(AppConstants.userCountryCode);
    return await sharedPreferences.remove(AppConstants.userNumber);
  }
}
