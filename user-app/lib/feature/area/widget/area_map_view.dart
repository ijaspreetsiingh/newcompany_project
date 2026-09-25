import 'package:jdds/util/core_export.dart';
import 'package:jdds/feature/area/widget/my_marker.dart';
import 'package:get/get.dart';


class AreaMapViewScreen extends StatefulWidget {
  final List<ZoneModel> zoneList;
  final Function(bool)? onValueChanged;
  const AreaMapViewScreen({super.key, required this.zoneList,  this.onValueChanged});
  @override
  State<AreaMapViewScreen> createState() => _AreaMapViewScreenState();
}

class _AreaMapViewScreenState extends State<AreaMapViewScreen> {
  MapController? _mapController;

  Map<String, GlobalKey> globalKeyMap = {};

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    for(int index = 0; index< widget.zoneList.length ; index++){
      globalKeyMap.addAll({
        index.toString() : GlobalKey()
      });
    }
  }

  void _onPanStart() {
    if(widget.onValueChanged != null){
      setState(() {
        widget.onValueChanged!(true);
      });
    }
  }
  void _onPanEnd() {
    if(widget.onValueChanged != null){
      setState(() {
        widget.onValueChanged!(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ServiceAreaController>(
          builder: (serviceAreaController) {
            return Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Stack(
                  children: [

                    ListView.builder(itemBuilder: (context, index){
                      return  MyMarker(globalKeyMap[index.toString()]! , zone: widget.zoneList[index],);
                    }, itemCount: serviceAreaController.zoneList?.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ) ,

                    Container(color: Theme.of(context).scaffoldBackgroundColor,),

                    MouseRegion(
                      onEnter: (event) => _onPanStart(),
                      onExit: (event) => _onPanEnd(),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            Get.find<SplashController>().configModel.content?.defaultLocation?.latitude ?? 23.0000,
                            Get.find<SplashController>().configModel.content?.defaultLocation?.longitude ?? 90.0000,
                          ),
                          initialZoom: 4,
                          minZoom: 0,
                          maxZoom: 16,
                          onMapReady: () {
                            serviceAreaController.setMarker(widget.zoneList, globalKeyMap).then((value) {
                              if (_mapController != null) {
                                serviceAreaController.mapBound(_mapController!);
                              }
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.sixamtech.demandium.user',
                          ),
                          MarkerLayer(markers: serviceAreaController.markers),
                          PolygonLayer(polygons: serviceAreaController.polygone),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}
