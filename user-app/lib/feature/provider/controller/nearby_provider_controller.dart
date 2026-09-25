import 'package:jdds/api/local/cache_response.dart';
import 'package:jdds/common/models/api_response_model.dart';
import 'package:jdds/helper/data_sync_helper.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';


class NearbyProviderController extends GetxController implements GetxService {
  final ProviderBookingRepo providerBookingRepo;
  NearbyProviderController({required this.providerBookingRepo});


  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProviderModel? _providerModel;
  ProviderModel? get providerModel => _providerModel;


  List<CategoryModelItem> categoryItemList = [];

  List<ProviderData>? _providerList;
  List<ProviderData>? get  providerList=> _providerList;

  final List<PredictionModel> _predictionList = [];
  PredictionModel? _firstPredictionModel;

  List<PredictionModel> get predictionList => _predictionList;
  PredictionModel? get firstPredictionModel => _firstPredictionModel;

  MapController? _mapController;
  MapController? get mapController => _mapController;

  final List<String> _sortBy = ['default','asc',"desc", 'popular'];
  List<String>  get sortBy => _sortBy;

  List<bool> _categoryCheckList =[];
  List<bool> get categoryCheckList => _categoryCheckList;

  String _selectedSortBy = "default";
  String get selectedSortBy => _selectedSortBy;

  final List<String> _ratingFilter = ['5','4', '3', '2','1'];
  List<String>  get ratingFilter => _ratingFilter;

  List<String> _selectedCategoryId =[];
  List<String> get selectedCategoryId => _selectedCategoryId;

  String? _selectedRating;
  String? get selectedRating => _selectedRating;

  int? _providerAvailableStatus;
  int? get providerAvailableStatus => _providerAvailableStatus;

  List<Marker> markers = [];

  int selectedProviderIndex = -1;
  AutoScrollController? scrollController;


  bool isPopupMenuOpened = false;

  Future<void> getProviderList(int offset, bool reload, {bool applyFilter = false, LatLng? initialPosition}) async {

    if(offset != 1 || _providerModel == null || reload){
      if(reload){
        _providerModel = null;
      }

      if(!applyFilter){
        clearFilterDataValues(shouldUpdate: false);
      }
      Map<String,dynamic> body={
        'sort_by': _selectedSortBy ,
         "rating" : _selectedRating ?? "0",
      };

      if(selectedCategoryId.isNotEmpty){
        body.addAll({'category_ids': selectedCategoryId});
      }

      if(_providerAvailableStatus !=null){
        body.addAll({'service_availability': _providerAvailableStatus});
      }


      if(offset == 1){

        await DataSyncHelper.fetchAndSyncData(
          fetchFromLocal: ()=> providerBookingRepo.getProviderList<CacheResponseData>( offset, body, source: DataSourceEnum.local, limit: 30),
          fetchFromClient: ()=> providerBookingRepo.getProviderList( offset, body, source: DataSourceEnum.client, limit: 30),
          onResponse: (data, source) {
            _providerModel = ProviderModel.fromJson(data);
            _providerList = [];
            _providerList!.addAll(ProviderModel.fromJson(data).content?.data??[]);
            _sortProviderListAndInitMap(initialPosition: initialPosition);
            update();
          },
        );

      }else{
        ApiResponseModel response = await providerBookingRepo.getProviderList(offset,body, limit: 30, source: DataSourceEnum.client);
        if (response.response.statusCode == 200) {
          if(reload){
            _providerList = [];
          }
          _providerModel = ProviderModel.fromJson(response.response.body);
          if(_providerModel != null ){
            _providerList!.addAll(ProviderModel.fromJson(response.response.body).content?.data??[]);
          }
          _sortProviderListAndInitMap(initialPosition: initialPosition);

        } else {
          ApiChecker.checkApi(response.response);
        }

        update();
      }
    }
  }

  void _sortProviderListAndInitMap({ LatLng? initialPosition}){
    _providerList?.forEach((element) {
      double distance = MapHelper.getDistanceBetweenUserCurrentLocationAndProvider(Get.find<LocationController>().getUserAddress()!, element);
      element.distance = distance;
    });

    if(_selectedSortBy == "default"){
      _providerList?.sort((a, b) => a.distance!.compareTo(b.distance!));
    }
    selectedProviderIndex = -1;

    if(initialPosition !=null && _mapController !=null){
      setMarker(initialPosition);
    }
  }


  int _apiHitCount = 0;

  Future<void> updateIsFavoriteStatus({ required String providerId, required int index}) async {



    _apiHitCount ++;
    updateIsFavoriteValue(_providerList?[index].isFavorite == 1 ? 0 : 1,providerId);
    update();
    Response response = await providerBookingRepo.updateIsFavoriteStatus(serviceId: providerId);

    _apiHitCount --;
    int status;
    if(response.statusCode == 200 && (response.body['response_code'] == "provider_favorite_store_200" || response.body['response_code'] == "provider_remove_favorite_200")){
      if(response.body['content']['status'] !=null){
        status  = response.body['content']['status'];
        updateIsFavoriteValue(status,providerId);
        customSnackBar(response.body['message'], type : status == 1 ? ToasterMessageType.success : ToasterMessageType.error);
      }
    }

    if(_apiHitCount ==0){
      update();
    }
  }

  void updateIsFavoriteValue(int status, String providerId, {bool shouldUpdate = false, bool fromExploreProviderScreen = true}){

    int? index = _providerList?.indexWhere((element) => element.id == providerId);
    if(index !=null && index > -1){
      _providerList?[index].isFavorite = status;
    }

    if(fromExploreProviderScreen){
      Get.find<ProviderBookingController>().updateProviderIsFavoriteValue(status, providerId, shouldUpdate: true, fromProviderBooking: false);
    }
    if(shouldUpdate){
      update();
    }
  }

  Future<void> getCurrentLocation({MapController? mapController, LatLng? defaultLatLng, bool notify = true}) async {

    Position myPosition;
    try {
      Geolocator.requestPermission();
      Position newLocalData = await Geolocator.getCurrentPosition();
      myPosition = newLocalData;

    }catch(e) {
      if(defaultLatLng != null){
        myPosition = Position(
            latitude:defaultLatLng.latitude,
            longitude:defaultLatLng.longitude,
            timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,  altitudeAccuracy: 1, headingAccuracy: 1
        );
      }else{
        myPosition = Position(
            latitude:  Get.find<SplashController>().configModel.content?.defaultLocation?.latitude ?? 23.0000,
            longitude: Get.find<SplashController>().configModel.content?.defaultLocation?.longitude ?? 90.0000,
            timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,  altitudeAccuracy: 1, headingAccuracy: 1
        );
      }
    }

    if (mapController != null) {
      mapController.move(LatLng(myPosition.latitude, myPosition.longitude), 16);
    }

    update();

  }



  Future<void> setMarker(LatLng initialPosition) async {

    List<Marker> markerList = [];

    for(int index = 0; index < _providerList!.length; index++) {

      if(_providerList![index].coordinates !=null){
        int providerIndex = index;
        markerList.add(Marker(
          point: LatLng(_providerList![providerIndex].coordinates!.latitude!, _providerList![providerIndex].coordinates!.longitude!),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              _resetMarker(providerIndex, initialPosition);
              await scrollController!.scrollToIndex(providerIndex, preferPosition: AutoScrollPosition.middle);
              await scrollController!.highlight(providerIndex);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_providerList![providerIndex].companyName ?? "", style: robotoMedium.copyWith(fontSize: 8), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Icon(Icons.location_on, color: selectedProviderIndex == providerIndex ? Colors.blue : Colors.red, size: selectedProviderIndex == providerIndex ? 30 : 25),
              ],
            ),
          ),
          width: 80,
          height: 50,
        ));
      }
    }

    markerList.add(Marker(
      point: initialPosition,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text("my_location".tr, style: robotoMedium.copyWith(fontSize: 8)),
          ),
          Icon(Icons.my_location, color: Colors.green, size: 25),
        ],
      ),
      width: 80,
      height: 50,
    ));

    markers = markerList;

    mapBound(initialPosition);

  }

  void _resetMarker(int index, LatLng initialPosition){
    selectedProviderIndex = index;

    List<Marker> markerList = [];
    for(int i = 0; i < _providerList!.length; i++) {

      if(_providerList![i].coordinates !=null){
        markerList.add(Marker(
          point: LatLng(_providerList![i].coordinates!.latitude!, _providerList![i].coordinates!.longitude!),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              _resetMarker(i, initialPosition);
              await scrollController!.scrollToIndex(i, preferPosition: AutoScrollPosition.middle);
              await scrollController!.highlight(i);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_providerList![i].companyName ?? "", style: robotoMedium.copyWith(fontSize: 8), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Icon(Icons.location_on, color: selectedProviderIndex == i ? Colors.blue : Colors.red, size: selectedProviderIndex == i ? 30 : 25),
              ],
            ),
          ),
          width: 80,
          height: 50,
        ));
      }
    }

    markerList.add(Marker(
      point: initialPosition,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text("my_location".tr, style: robotoMedium.copyWith(fontSize: 8)),
          ),
          Icon(Icons.my_location, color: Colors.green, size: 25),
        ],
      ),
      width: 80,
      height: 50,
    ));

    markers = markerList;
    update();
  }


  void mapBound(LatLng initialPosition) async {
    List<LatLng> latLongList = [];
    latLongList.add(initialPosition);
    for (int index = 0; index < _providerList!.length; index++) {
      if(_providerList![index].coordinates !=null){
        latLongList.add(LatLng(_providerList![index].coordinates!.latitude!, _providerList![index].coordinates!.longitude!));
      }
    }
    if (_mapController != null && latLongList.isNotEmpty) {
      _mapController!.fitCamera(CameraFit.bounds(
        bounds: MapHelper.boundsFromLatLngList(latLongList),
        padding: const EdgeInsets.all(100.5),
      ));
    }

    update();
  }

  void updateSortBy(String value){
    _selectedSortBy = value;
    update();
  }

  void updateFilterByRating(String value){
    _selectedRating= value;
    update();
  }

  void toggleFromCampaignChecked(int index) {

    List<CategoryModel> categoryList = Get.find<CategoryController>().categoryList ?? [];
    _categoryCheckList[index] = !categoryCheckList[index];

    if(_categoryCheckList[index]==true){
      if(!_selectedCategoryId.contains(categoryList[index].id)){
        _selectedCategoryId.add(categoryList[index].id!);
      }
    }else{
      if(_selectedCategoryId.contains(categoryList[index].id)){
        _selectedCategoryId.remove(categoryList[index].id);
      }
    }
    update();

  }

  void resetCategoryCheckedList({bool shouldUpdate = true}){
    Get.find<CategoryController>().categoryList?.forEach((element) {
      _categoryCheckList.add(false);
    });

    if(shouldUpdate){
      update();
    }
  }

  void clearFilterDataValues ({bool shouldUpdate = true}){
    _selectedCategoryId=[];
    _categoryCheckList = [];
    _selectedRating = null;
    _selectedSortBy = "default";
    _providerAvailableStatus = null;
    resetCategoryCheckedList(shouldUpdate: false);
    if(shouldUpdate){
      update();
    }

  }
  bool isFilteredApplied() {
    if(_selectedRating == null && _selectedCategoryId.isEmpty && _selectedSortBy == "default" && _providerAvailableStatus == null){
      return false;
    }
    return true;
  }

  void updateProviderAvailableStatus({int? value, bool shouldUpdate = true}){
    _providerAvailableStatus = _providerAvailableStatus == 1 ? 0 : 1;

    if(shouldUpdate){
      update();
    }
  }

  void updatePopMenuStatus(bool newValue, {bool shouldUpdate = true}){
    isPopupMenuOpened = newValue;
    if(shouldUpdate){
      update();
    }

  }

  void setMapController({MapController? controller}){
    _mapController = controller;
  }

}
