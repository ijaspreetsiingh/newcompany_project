import 'dart:convert';
import 'package:jdds/api/local/cache_response.dart';
import 'package:jdds/helper/data_sync_helper.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class SplashController extends GetxController implements GetxService {
  final SplashRepo splashRepo;
  SplashController({required this.splashRepo});

  ConfigModel? _configModel = ConfigModel();
  bool _firstTimeConnectionCheck = true;
  final bool _hasConnection = true;
  bool _isLoading = false;
  DataSourceEnum _currentDataSource = DataSourceEnum.local;


  bool get isLoading => _isLoading;
  ConfigModel get configModel => _configModel!;
  DateTime get currentTime => DateTime.now();
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
  bool get hasConnection => _hasConnection;
  DataSourceEnum get currentDataSource => _currentDataSource;

  bool savedCookiesData = false;

  Future<bool> getConfigData() async {

    try {
      final localResponse = await splashRepo.getConfigData<CacheResponseData>(source: DataSourceEnum.local);
      if(localResponse.isSuccess) {
        _configModel = ConfigModel.fromJson(jsonDecode(localResponse.response!.response));
        _currentDataSource = DataSourceEnum.local;
        update();
      }
    } catch(e) {
      // local cache empty
    }

    splashRepo.getConfigData(source: DataSourceEnum.client).then((clientResponse) {
      try {
        if(clientResponse.isSuccess && clientResponse.response?.statusCode == 200) {
          _configModel = ConfigModel.fromJson(clientResponse.response!.body);
          _currentDataSource = DataSourceEnum.client;
          update();
        }
      } catch(e) {}
    }).catchError((e) {});

    return true;
  }



  void _startTimer (DateTime startTime){
    Timer.periodic(const Duration(seconds: 30), (Timer timer){
      DateTime now = DateTime.now();
      if (now.isAfter(startTime) || now.isAtSameMomentAs(startTime)) {
        timer.cancel();
        Get.offAllNamed(RouteHelper.getMaintenanceRoute());
      }
    });
  }


  Future<bool> initSharedData() {
    return splashRepo.initSharedData();
  }

  void setGuestId(String guestId){
    splashRepo.setGuestId(guestId);
  }

  String getGuestId (){
    return splashRepo.getGuestId();
  }




  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }



  void saveCookiesData(bool data) {
    splashRepo.saveCookiesData(data);
    savedCookiesData = true;
    update();
  }

  void getCookiesData(){
    savedCookiesData = splashRepo.getSavedCookiesData();
    update();
  }


  void cookiesStatusChange(String? data) {
    if(data != null){
      splashRepo.sharedPreferences!.setString(AppConstants.cookiesManagement, data);
    }
  }

  bool getAcceptCookiesStatus(String data) => splashRepo.sharedPreferences!.getString(AppConstants.cookiesManagement) != null
      && splashRepo.sharedPreferences!.getString(AppConstants.cookiesManagement) == data;

  void disableShowOnboardingScreen() {
    splashRepo.disableShowOnboardingScreen();
  }

  bool  isShowOnboardingScreen() {
    return splashRepo.isShowOnboardingScreen();
  }

  void  disableShowInitialLanguageScreen() {
    splashRepo.disableShowInitialLanguageScreen();
  }

  bool isShowInitialLanguageScreen() {
    return splashRepo.isShowInitialLanguageScreen();
  }


  void updateLanguage(bool isInitial) async {
    try {
      Response response = await splashRepo.updateLanguage(getGuestId());
      if(!isInitial){
        if(response.statusCode == 200 && response.body['response_code'] == "default_200"){

        }else{
          customSnackBar("${response.body['message']}");
        }
      }
    } catch(e) {
      // timeout or network error, don't block
    }
  }

  Future<void> addError404UrlToServer(String url) async {
    Response response = await splashRepo.addError404UrlToServer(url);
    if (kDebugMode) {
      print("Error Url Add Response Status : ${response.statusCode}");
    }
  } 
  
  Future<ResponseModel> newsLetterSubscription({required String email}) async {
    _isLoading  = true;
    update();
    Response response = await splashRepo.newsLetterSubscription(email: email);
    if(response.statusCode == 200){
      _isLoading  = false;
      update();
      return ResponseModel(true, "successfully_subscribed".tr);
    }else if(response.statusCode == 400){
      _isLoading  = false;
      update();
      return ResponseModel(false, "${response.body['errors'][0]['message'] ?? ""}");
    }else{
      _isLoading  = false;
      update();
      return ResponseModel(false, "${response.body['message'] ?? ""}");
    }

  }

}
