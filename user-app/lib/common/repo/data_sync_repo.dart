import 'dart:convert';
import 'package:jdds/api/local/cache_response.dart';
import 'package:jdds/common/models/api_response_model.dart';
import 'package:jdds/helper/db_helper.dart';
import 'package:jdds/helper/get_di.dart';
import 'package:jdds/util/core_export.dart';
import 'package:drift/drift.dart';
import 'package:get/get_connect/http/src/response/response.dart';



class DataSyncRepo {
  final ApiClient apiClient;
  final SharedPreferences? sharedPreferences;

  DataSyncRepo({required this.apiClient, required this.sharedPreferences});

  Future<AptresponseModel<T>> fetchData<T>(String uri, DataSourceEnum source, {dynamic body, ApiMethodType method = ApiMethodType.get} ) async {
    try {
      return source == DataSourceEnum.client || _isACachesDisable() ? await _fetchFromClient<T>(uri, method: method, body: body) : await _fetchFromLocalCache<T>(uri);
    } catch (e) {
      debugPrint('DataSyncRepo: ===> $source $e ($uri)');

      return AptresponseModel.withError(e);
    }
  }

  Future<AptresponseModel<T>> _fetchFromClient<T>(String uri, {dynamic body,ApiMethodType method = ApiMethodType.get}) async {
    final response = await _fetchResponseFromClient(uri, body: body, method: method);
    if(response.statusCode == 200) {
      final cacheKey = _cacheKeyForZone(uri);
      final cacheData = CacheResponseCompanion(
        endPoint: Value(cacheKey),
        header: Value(jsonEncode(response.headers)),
        response: Value(jsonEncode(response.body)),
      );

      // Cache the data based on the platform
      if (kIsWeb && _isWebCachesActive()) {
        _cacheResponseWeb(cacheKey, cacheData);
      }

      if(!kIsWeb && _isAppCachesActive()) {
        await DbHelper.insertOrUpdate(id: cacheKey, data: cacheData);
      }
    }

    // Prepare the cache data


    return AptresponseModel.withSuccess(response as T);
  }

  /// Home screen se sab kuch selected location (zone) par based hai,
  /// isliye cache key me zone_id shamil karo — location/zone badalne par
  /// purane zone ka cached data dobara na mile.
  String _cacheKeyForZone(String uri) {
    try {
      final addressJson = sharedPreferences?.getString(AppConstants.userAddress);
      if (addressJson != null && addressJson.isNotEmpty) {
        final zoneId = jsonDecode(addressJson)['zone_id'];
        if (zoneId != null && zoneId.toString().isNotEmpty) {
          return '$uri##zone_$zoneId';
        }
      }
    } catch (_) {
      // address parse fail → plain uri key (backward compatible)
    }
    return uri;
  }

  Future<Response> _fetchResponseFromClient (String uri,{dynamic body, ApiMethodType method = ApiMethodType.get}){
    if(method == ApiMethodType.get){
      return apiClient.getData(uri);
    }else{
      return apiClient.postData(uri, body);
    }
  }

  bool _isWebCachesActive()=> (AppConstants.cachesType == LocalCachesTypeEnum.all || AppConstants.cachesType == LocalCachesTypeEnum.web);
  bool _isAppCachesActive()=> (AppConstants.cachesType == LocalCachesTypeEnum.all || AppConstants.cachesType == LocalCachesTypeEnum.app);
  bool _isACachesDisable() => AppConstants.cachesType == LocalCachesTypeEnum.none;

  void _cacheResponseWeb(String uri, CacheResponseCompanion cacheData) {
    final cacheJson = CacheResponseData(
      id: 0,
      endPoint: cacheData.endPoint.value,
      header: cacheData.header.value,
      response: cacheData.response.value,
    ).toJson();
    sharedPreferences?.setString(uri, jsonEncode(cacheJson));
  }

  Future<AptresponseModel<T>> _fetchFromLocalCache<T>(String uri) async {
    CacheResponseData? cacheData;
    final cacheKey = _cacheKeyForZone(uri);

    if (kIsWeb) {
      final cachedJson = sharedPreferences?.getString(cacheKey);
      if (cachedJson != null) {
        cacheData = CacheResponseData.fromJson(jsonDecode(cachedJson));
      }
    } else {
      cacheData = await database.getCacheResponseById(cacheKey);
    }

    if (cacheData != null && jsonDecode(cacheData.response) != null) {
      return AptresponseModel.withSuccess(cacheData as T);
    } else {
      return AptresponseModel.withError("No local data found for $uri");
    }
  }
}


