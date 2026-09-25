import 'dart:ui';

import 'package:jdds/api/local/cache_response.dart';
import 'package:jdds/common/models/api_response_model.dart';
import 'package:jdds/helper/data_sync_helper.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';


class ProviderBookingController extends GetxController implements GetxService {
  final ProviderBookingRepo providerBookingRepo;
  ProviderBookingController({required this.providerBookingRepo});


  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProviderModel? _providerModel;
  ProviderModel? get providerModel => _providerModel;

  ProviderDetailsContent? _providerDetailsContent;
  ProviderDetailsContent? get providerDetailsContent => _providerDetailsContent;

  List<CategoryModelItem> categoryItemList =[];

  List<ProviderData>? _providerList;
  List<ProviderData>? get  providerList=> _providerList;

  List<Review>? _reviewList;
  List<Review>? get reviewList => _reviewList;

  List<Marker> markers = [];
  int selectedProviderIndex = 0;
  AutoScrollController? scrollController;


  ValueNotifier<bool> isTabBarPinnedNotifier = ValueNotifier(false);

  void updateTabBarPinned(bool pinned) {
    if (isTabBarPinnedNotifier.value != pinned) {
      isTabBarPinnedNotifier.value = pinned;
    }
  }


  String formatDays(List<String> dayList) {
    if (dayList.isEmpty) {
      return "";
    }
    List<String> formattedList = dayList.map((day) => day[0].toLowerCase() + day.substring(1)).toList();
    if (formattedList.length == 1) {
      return formattedList[0].tr;
    }
    formattedList.sort((a, b) {
      const daysOfWeek = [ "saturday", "sunday", "monday", "tuesday", "wednesday", "thursday", "friday"];
      return daysOfWeek.indexOf(a) - daysOfWeek.indexOf(b);
    });
    bool isConsecutive = true;
    for (int i = 1; i < formattedList.length; i++) {
      if (_nextDay(formattedList[i - 1]) != formattedList[i]) {
        isConsecutive = false;
        break;
      }
    }
    if (isConsecutive) {
      return "${formattedList.first.toLowerCase().tr} - ${formattedList.last.toLowerCase().tr}";
    } else {

      List<String> translatedList =[];
      for (var element in formattedList) {
        translatedList.add(element.tr);
      }
      return translatedList.join(', ');
    }
  }
  String _nextDay(String day) {
    const daysOfWeek = [ "saturday", "sunday", "monday", "tuesday", "wednesday", "thursday","friday"];
    final index = daysOfWeek.indexOf(day);
    return daysOfWeek[(index + 1) % daysOfWeek.length];
  }


  // Future<void> getProviderList(int offset, bool reload) async {
  //   if (offset != 1 || _providerList == null || reload) {
  //     if (reload) {
  //       _providerList = null;
  //     }
  //
  //     Map<String, dynamic> body = {
  //       'sort_by': sortBy[selectedSortByIndex],
  //       'rating': selectedRatingIndex,
  //     };
  //
  //     if (selectedCategoryId.isNotEmpty) {
  //       body.addAll({'category_ids': selectedCategoryId});
  //     }
  //
  //     // 🟢 Debug request body
  //     print('📤 Sending Request with Offset: $offset, Body: $body');
  //
  //     if (offset == 1) {
  //       await DataSyncHelper.fetchAndSyncData(
  //         fetchFromLocal: () => providerBookingRepo.getProviderList<CacheResponseData>(
  //           offset,
  //           body,
  //           source: DataSourceEnum.local,
  //         ),
  //         fetchFromClient: () => providerBookingRepo.getProviderList(
  //           offset,
  //           body,
  //           source: DataSourceEnum.client,
  //         ),
  //         onResponse: (data, source) {
  //           // 🟢 Debug raw response
  //           print('📥 Response from $source: $data');
  //
  //           _providerModel = ProviderModel.fromJson(data);
  //           print('✅ Parsed ProviderModel: $_providerModel');
  //
  //           _providerList = [];
  //           _providerList!.addAll(_providerModel?.content?.data ?? []);
  //
  //           // 🟢 Debug provider list after parsing
  //           print('📊 Provider List Count: ${_providerList!.length}');
  //           print('📊 Providers: $_providerList');
  //
  //           _calculateDistance();
  //           update();
  //         },
  //       );
  //     } else {
  //       ApiResponseModel response = await providerBookingRepo.getProviderList(
  //         offset,
  //         body,
  //         source: DataSourceEnum.client,
  //       );
  //
  //       // 🟢 Debug raw response
  //       print('📥 API Response: ${response.response.body}');
  //       print('📥 Status Code: ${response.response.statusCode}');
  //
  //       if (response.response.statusCode == 200) {
  //         if (reload) {
  //           _providerList = [];
  //         }
  //         _providerModel = ProviderModel.fromJson(response.response.body);
  //
  //         print('✅ Parsed ProviderModel: $_providerModel');
  //
  //         if (_providerList != null) {
  //           _providerList!.addAll(_providerModel?.content?.data ?? []);
  //         }
  //
  //         // 🟢 Debug provider list after parsing
  //         print('📊 Provider List Count: ${_providerList!.length}');
  //         print('📊 Providers: $_providerList');
  //
  //         _calculateDistance();
  //       } else {
  //         ApiChecker.checkApi(response.response);
  //       }
  //       update();
  //     }
  //   }
  // }





  Future<void> getProviderList(int offset, bool reload) async {

    if(offset != 1 || _providerList == null || reload){

      if(reload){
        _providerList = null;
      }

      Map<String,dynamic> body={
        'sort_by': sortBy[selectedSortByIndex],
        'rating': selectedRatingIndex,
      };

      if(selectedCategoryId.isNotEmpty){
        body.addAll({'category_ids': selectedCategoryId});
      }


      if(offset == 1){

       await  DataSyncHelper.fetchAndSyncData(
          fetchFromLocal: ()=> providerBookingRepo.getProviderList<CacheResponseData>( offset, body, source: DataSourceEnum.local),
          fetchFromClient: ()=> providerBookingRepo.getProviderList( offset, body, source: DataSourceEnum.client),
          onResponse: (data, source) {
            _providerModel = ProviderModel.fromJson(data);
            _providerList = [];
            _providerList!.addAll(ProviderModel.fromJson(data).content?.data??[]);
            _calculateDistance();
            update();
          },
        );

      }else{
        ApiResponseModel response  = await providerBookingRepo.getProviderList(offset,body, source: DataSourceEnum.client);

        if (response.response.statusCode == 200) {
          if(reload){
            _providerList = [];
          }
          _providerModel = ProviderModel.fromJson(response.response.body);
          if(_providerList != null){
            _providerList!.addAll(_providerModel?.content?.data??[]);
          }
          _calculateDistance();

        } else {
          ApiChecker.checkApi(response.response);
        }
        update();
      }
    }
  }

  void _calculateDistance (){
    _providerList?.forEach((element) {
      double distance = MapHelper.getDistanceBetweenUserCurrentLocationAndProvider(Get.find<LocationController>().getUserAddress()!, element);
      element.distance = distance;
    });
  }


  Future<void> getProviderDetailsData(String providerId, bool reload, {int offSet = 1}) async {

    if(_providerDetailsContent == null || reload){
      if(reload){
        categoryItemList =[];
        _providerDetailsContent = null;
      }
      Response response = await providerBookingRepo.getProviderDetails(providerId, offSet);
      if (response.statusCode == 200) {
        _providerDetailsContent = ProviderDetails.fromJson(response.body).content;

        if(_providerDetailsContent!.subCategories!=null || _providerDetailsContent!.subCategories!.isNotEmpty){
          for (var subcategory in _providerDetailsContent!.subCategories!) {
            List<Service> serviceList = [];
            if(subcategory.services!.isNotEmpty){
              subcategory.services?.forEach((service) {
                  serviceList.add(service);
              });

              if(serviceList.isNotEmpty){
                categoryItemList.add(CategoryModelItem(
                  title: subcategory.name!, serviceList: serviceList,
                ));
              }
            }
          }
        }

        if(offSet!=1){
          _providerDetailsContent?.providerReview?.reviewList?.forEach((element){
            _reviewList?.add(element);
          });
        }else{
          _reviewList = [];
          _providerDetailsContent?.providerReview?.reviewList?.forEach((element){
            _reviewList?.add(element);
          });
        }
      } else {
        _providerDetailsContent = ProviderDetailsContent();
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  int _apiHitCount = 0;

  Future<void> updateIsFavoriteStatus({ required String providerId,  int? index}) async {

    _apiHitCount ++;
    Response response = await providerBookingRepo.updateIsFavoriteStatus(serviceId: providerId);

    _apiHitCount --;
    int status;
    if(response.statusCode == 200 && (response.body['response_code'] == "provider_favorite_store_200" || response.body['response_code'] == "provider_remove_favorite_200")){
      if(response.body['content']['status'] !=null){
        status  = response.body['content']['status'];
        updateProviderIsFavoriteValue(status,providerId);
        customSnackBar(response.body['message'], type: status == 1 ? ToasterMessageType.success : ToasterMessageType.error);
      }
    }

    if(_providerDetailsContent != null && _providerDetailsContent?.provider?.id == providerId){
      int? status = _providerDetailsContent?.provider?.isFavorite;
      _providerDetailsContent?.provider?.isFavorite = status == 1 ? 0 : 1;
    }
    if(_apiHitCount ==0){
      update();
    }
  }

  void updateProviderIsFavoriteValue(int status, String providerId, {bool shouldUpdate = false, bool fromProviderBooking = true}){

    int? index = _providerList?.indexWhere((element) => element.id == providerId);
    if(index !=null && index > -1){
      _providerList?[index].isFavorite = status;
    }
    Get.find<AdvertisementController>().updateIsFavoriteValue(status, providerId, shouldUpdate: true);
    if(fromProviderBooking){
      Get.find<NearbyProviderController>().updateIsFavoriteValue(status, providerId, shouldUpdate: true, fromExploreProviderScreen: false);

    }
    if(shouldUpdate){
      update();
    }
  }

  void updateServiceIsFavoriteValue(int status, String serviceId, {bool shouldUpdate = false}){
    if(_providerDetailsContent !=null && _providerDetailsContent?.subCategories != null){
      for(int categoryIndex = 0; categoryIndex < (_providerDetailsContent?.subCategories?.length ?? 0) ; categoryIndex ++){
        int? serviceIndex = _providerDetailsContent?.subCategories![categoryIndex].services?.indexWhere((element) => element.id == serviceId);
        if(serviceIndex !=null && serviceIndex>-1){
          _providerDetailsContent?.subCategories?[categoryIndex].services?[serviceIndex].isFavorite = status;
        }
      }
    }
    if(shouldUpdate){
      update();
    }
  }



  /// filter Section
  int selectedRatingIndex = 0;
  int selectedSortByIndex = 0;



  List<String> sortBy = ['asc',"desc"];

  List<bool> categoryCheckList =[];
  List<String> selectedCategoryId =[];

  // Future<void> getCategoryList() async {
  //   Response response = await providerBookingRepo.getCategoryList();
  //   if(response.statusCode == 200){
  //
  //     categoryList = [];
  //     categoryCheckList = [];
  //
  //     List<dynamic> serviceCategoryList = response.body['content']['data'];
  //     for (var category in serviceCategoryList) {
  //       categoryList.add(CategoryModel.fromJson(category));
  //       categoryCheckList.add(false);
  //     }
  //   }
  //   else {
  //     ApiChecker.checkApi(response);
  //   }
  //   update();
  // }

  void updateSortByIndex(int rating){
    selectedSortByIndex= rating;
    update();
  }

  void updateRatingIndex(int rating){
    selectedRatingIndex= rating;
    update();
  }

  void toggleFromCampaignChecked(int index) {
    List<CategoryModel> categoryList = Get.find<CategoryController>().categoryList ?? [];
    categoryCheckList[index] = !categoryCheckList[index];

    if(categoryCheckList[index]==true){
      if(!selectedCategoryId.contains(categoryList[index].id)){
        selectedCategoryId.add(categoryList[index].id!);
      }
    }else{
      if(selectedCategoryId.contains(categoryList[index].id)){
        selectedCategoryId.remove(categoryList[index].id);
      }
    }
    update();

  }

  void resetProviderFilterData({bool shouldUpdate= false}){
    selectedCategoryId=[];
    categoryCheckList = [];
    selectedRatingIndex=0;
    selectedSortByIndex = 0;

    for (var element in Get.find<CategoryController>().categoryList ??[]) {
      categoryCheckList.add(false);
      if (kDebugMode) {
        print(element.name);
      }
    }
    if(shouldUpdate){
      update();
    }
  }

  Future<void> setMarker(MapController mapController, LatLng initialPosition) async {

    markers = [];
    for(int index = 0; index < _providerList!.length; index++) {

      if(_providerList![index].coordinates !=null){
        int providerIndex = index;
        markers.add(Marker(
            point: LatLng(_providerList![providerIndex].coordinates!.latitude!, _providerList![providerIndex].coordinates!.longitude!),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                _resetMarker(providerIndex, mapController, initialPosition);
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

    markers.add(Marker(
      point: initialPosition,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){
          mapController.move(initialPosition, 16);
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
              child: Text("my_location".tr, style: robotoMedium.copyWith(fontSize: 8)),
            ),
            Icon(Icons.my_location, color: Colors.green, size: 25),
          ],
        ),
      ),
      width: 80,
      height: 50,
    ));

    mapBound(mapController);

  }

  void _resetMarker(int index, MapController mapController, LatLng initialPosition){
    selectedProviderIndex = index;

    markers = [];
    for(int i = 0; i < _providerList!.length; i++) {

      if(_providerList![i].coordinates !=null){
        markers.add(Marker(
          point: LatLng(_providerList![i].coordinates!.latitude!, _providerList![i].coordinates!.longitude!),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              _resetMarker(i, mapController, initialPosition);
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

    markers.add(Marker(
      point: initialPosition,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){
          mapController.move(initialPosition, 16);
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
              child: Text("my_location".tr, style: robotoMedium.copyWith(fontSize: 8)),
            ),
            Icon(Icons.my_location, color: Colors.green, size: 25),
          ],
        ),
      ),
      width: 80,
      height: 50,
    ));

    update();
  }



  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }


  void mapBound(MapController controller) async {
    List<LatLng> latLongList = [];
    for (int index = 0; index < _providerList!.length; index++) {
      if(_providerList![index].coordinates !=null){
        latLongList.add(LatLng(_providerList![index].coordinates!.latitude!, _providerList![index].coordinates!.longitude!));
      }
    }
    if (latLongList.isNotEmpty) {
      controller.fitCamera(CameraFit.bounds(
        bounds: MapHelper.boundsFromLatLngList(latLongList),
        padding: const EdgeInsets.all(100.5),
      ));
    }

    update();
  }

  void updateProviderReviewExpendedStatus({int? index, bool shouldUpdate = true}){
    if(index  !=null){
      _reviewList?[index].isExpended = 1;
      if(shouldUpdate){
        update();
      }
    } else{
      if(_reviewList !=null && reviewList!.isNotEmpty){
        for(int index = 0; index < _reviewList!.length ; index ++){
          _reviewList?[index].isExpended = 0;
        }
      }
    }
  }




}