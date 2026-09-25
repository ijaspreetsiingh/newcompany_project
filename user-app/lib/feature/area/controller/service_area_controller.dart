import 'dart:ui';

import 'package:jdds/api/local/cache_response.dart';
import 'package:jdds/helper/data_sync_helper.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';


class ServiceAreaController extends GetxController implements GetxService{
  ServiceAreaRepo serviceAreaRepo;
  ServiceAreaController({required this.serviceAreaRepo});

  List<ZoneModel>? _zoneList;

  List<Marker> _markers = [];
  List<Polygon> _polygone = [];


  List<ZoneModel>? get zoneList => _zoneList;
  List<Marker> get markers => _markers;
  List<Polygon> get polygone => _polygone;


  Future<void> getZoneList({Map<String, GlobalKey>? globalKeyMap, bool reload = true}) async {

    DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: ()=> serviceAreaRepo.getZoneList<CacheResponseData>(source: DataSourceEnum.local),
      fetchFromClient: ()=> serviceAreaRepo.getZoneList(source: DataSourceEnum.client),
      onResponse: (data, source) {
        _zoneList = [];

        data['content']['data'].forEach((zone) => _zoneList!.add(ZoneModel.fromJson(zone)));
        List<Polygon> polygonList = [];
        List<LatLng> currentLocationList = [];

        for (int index = 0; index < _zoneList!.length; index++) {

          List<LatLng> zoneLatLongList = [];
          for (int subIndex = 0; subIndex < _zoneList![index].formattedCoordinates!.length; subIndex++) {
            zoneLatLongList.add(LatLng(_zoneList![index].formattedCoordinates![subIndex].latitude!, _zoneList![index].formattedCoordinates![subIndex].longitude!));
          }

          LatLng position =  computeCentroid(points: zoneLatLongList);
          currentLocationList.add(position);

          polygonList.add(
            Polygon(
              points: zoneLatLongList,
              borderStrokeWidth: 2,
              color: Get.theme.colorScheme.primary.withValues(alpha: .2),
              borderColor: Get.theme.colorScheme.primary,
            ),
          );

        }

        _polygone = polygonList;
        update();
      },
    );
  }

  Future<void> setMarker(List<ZoneModel> zoneList, Map<String, GlobalKey> globalKeymap) async {

    List<Marker> markerList = [];

    for (int index = 0; index < zoneList.length; index++) {
      List<LatLng> zoneLatLongList = [];
      for (int subIndex = 0; subIndex < zoneList[index].formattedCoordinates!.length; subIndex++) {
        zoneLatLongList.add(LatLng(zoneList[index].formattedCoordinates![subIndex].latitude!, zoneList[index].formattedCoordinates![subIndex].longitude!));
      }

      LatLng centroid = computeCentroid(coordinates: zoneList[index].formattedCoordinates!);

      Widget markerWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
            child: Text(zoneList[index].name ?? "", style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall, color: Colors.black
            ),),
          ),
          Icon(Icons.location_on, color: Get.theme.colorScheme.primary, size: 30),
        ],
      );

      markerList.add(Marker(
        point: centroid,
        child: markerWidget,
        width: 120,
        height: 70,
      ));
    }
    _markers = markerList;
  }


  LatLng computeCentroid({List<Coordinates> ? coordinates, Iterable<LatLng>? points}) {
    double latitude = 0;
    double longitude = 0;
    int n = 1;

    if(points !=null){
     n = points.length;

     for (LatLng point in points) {
       latitude += point.latitude;
       longitude += point.longitude;
     }

    } else if(coordinates !=null ){
      n = coordinates.length;

      for (Coordinates point in coordinates) {
        latitude += point.latitude!;
        longitude += point.longitude!;
      }

    }else{
      n = 1;
    }

    return LatLng(latitude / n, longitude / n);
  }


  Future<Uint8List?> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))?.buffer.asUint8List();
  }


  void mapBound(MapController controller) async {
    List<LatLng> latLongList = [];
    for (int index = 0; index < _zoneList!.length; index++) {
      if (_zoneList![index].formattedCoordinates != null) {
        for (int subIndex = 0; subIndex < _zoneList![index].formattedCoordinates!.length; subIndex++) {
          latLongList.add(LatLng(_zoneList![index].formattedCoordinates![subIndex].latitude!, _zoneList![index].formattedCoordinates![subIndex].longitude!));
        }
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

}
