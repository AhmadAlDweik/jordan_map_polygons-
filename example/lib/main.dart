import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:maps_toolkit/maps_toolkit.dart' as map;z`

void main() => runApp(const MyApp());


class MyApp extends StatefulWidget {
  const MyApp({key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    Get.put(MapConfigure());
    super.initState();
  }

  MapType currentMapType = MapType.normal;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.layers_rounded),
          onPressed: () {
            // if (Get.find<MapConfigure>().mapType == true)
            //   Get.find<MapConfigure>().changeMapType(false);
            // else
            //   Get.find<MapConfigure>().changeMapType(true);
            setState(() {
              currentMapType = (currentMapType == MapType.normal)
                  ? MapType.terrain
                  : MapType.normal;
            });
          },
        ),
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          elevation: 2,
        ),
        body: MapScreen(currentMapType),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  MapScreen(this.currentMapType, {
    Key key,
  }) : super(key: key);

  MapType currentMapType;

  @override
  State<MapScreen> createState() => _MapScreenState(currentMapType);
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _center = const LatLng(31.894353, 35.911884);

  _MapScreenState(MapType currentMapType);

  // String customMapStyle2;

  @override
  void initState() {
    // TODO: implement initState
    // customMapStyle2 = await rootBundle.loadString('assets/map_style.json');

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapConfigure>(
      init: MapConfigure(),
      builder: (mapConfigure) =>
          GoogleMap(
            markers: mapConfigure.markersGroup,
            initialCameraPosition: CameraPosition(target: _center, zoom: 7.5),
            mapType: widget.currentMapType,
            // mapType:mapConfigure.mapType? MapType.normal:MapType.satellite,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            compassEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            indoorViewEnabled: true,
            trafficEnabled: true,
            onMapCreated: (GoogleMapController controller) async {
              String customMapStyle2 = await rootBundle.loadString(
                  'assets/map_style.json');

              controller.setMapStyle(customMapStyle2);
              await mapConfigure.getPointFromJison(context);
            },
            onTap: (LatLng latLng) async {
              print("polygons ${PointMode.polygon.name}");
              ///todo  setMarkerOnTapped
              // await mapConfigure.setMarkerOnTapped(latLng);
              await mapConfigure.setMarkerOnTappedWithPolygon(latLng);
            },
            polygons: {
              ...List.generate(
                  mapConfigure.polygonCoords.length,
                      (index) =>
                      Polygon(
                        polygonId: PolygonId("$index"),
                        points: mapConfigure.polygonCoords[index],
                        fillColor:

                        // Color.fromRGBO(
                        //     66, 75, 245, 0.7294117647058823),
                        index != mapConfigure.polygonCoords.length-1
                            ?
                        Color.fromARGB(
                          Random().nextInt(256),
                          Random().nextInt(256),
                          Random().nextInt(256),
                          150,
                        )
                            : Colors.white10,
                        strokeWidth: 4,
                      )),
            },

          ),
    );
  }
}

class MapConfigure extends GetxController {
  List<List<LatLng>> polygonCoords = [];
  List<dynamic> featuresCount = [];
  List<dynamic> featuresCount2 = [];

  Marker marker1;
  Set<Marker> markersGroup = <Marker>{};

  bool mapType = true;


  changeMapType(bool type) {
    mapType = type;
    print("changeMapType $mapType");
  }

  Future getPointMaps(lon, lat) async {
    polygonCoords = [];
    // final response = await http.get(Uri.parse(
    //     'https://api.geoapify.com/v1/boundaries/part-of?lon=36.485273&lat=30.322036&geometry=geometry_1000&apiKey=e15ee377d78e4a259ecf62b9888463d6'));

    print(
        'https://api.geoapify.com/v1/boundaries/part-of?lon=$lon&lat=$lat&geometry=geometry_1000&apiKey=e15ee377d78e4a259ecf62b9888463d6');
    final response2 = await http.get(Uri.parse(
        'https://api.geoapify.com/v1/boundaries/part-of?lon=$lon&lat=$lat&geometry=geometry_1000&apiKey=e15ee377d78e4a259ecf62b9888463d6'));
    try {
      if (
      // response.statusCode == 200 &&
      response2.statusCode == 200) {
        // featuresCount = json.decode(response.body)['features'];
        featuresCount2 = json.decode(response2.body)['features'];
        // for (int i = 0; i < featuresCount.length-1; i++) {
        //   polygonCoords.add(json
        //       .decode(response.body)['features'][i]['geometry']['coordinates']
        //           [0]
        //       .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
        //       .toList());
        // }
        for (int i = 0; i < featuresCount2.length; i++) {
          polygonCoords.add(json
              .decode(response2.body)['features'][i]['geometry']['coordinates']
          [0]
              .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
              .toList());
        }
      }
    } catch (e) {
      print("erroororrrrrr ${e.toString()}");
    }
    update();
  }

  setMarkerOnTappedWithPolygon(LatLng latLng) async {
    markersGroup.clear();
    print("Lat: ${latLng.latitude} || Lon : ${latLng.longitude}");

    marker1 = (Marker(
      markerId: MarkerId("1"),
      position: latLng,
      icon: BitmapDescriptor.defaultMarker,
      // draggable: true,
      // onDragEnd: (updateLatLng) {
      //   checkUpdateLocation(updateLatLng);
      //   print("updateLatLng:|$updateLatLng");
      // }
    ));

    markersGroup.add(marker1);
    getPointMaps(latLng.longitude, latLng.latitude);

    update();
  }

  setMarkerOnTapped(LatLng latLng) async {

    markersGroup.clear();
    marker1 = (Marker(
      markerId: MarkerId("1"),
      position: latLng,
      icon: BitmapDescriptor.defaultMarker,
    ));

    markersGroup.add(marker1);

    update();
  }


  Future getPointFromJison(context) async {
    polygonCoords = [];
    var response = await DefaultAssetBundle.of(context).loadString(
        'assets/Untitled_layer_test2.geojson');
    print("response getPointFromJison $response");
    var data = json.decode(response);
    List data2 = json.decode(response)['features'];
    print("data2 ${data2.length}");
    for (int i = 0; i < data2.length; i++) {
      polygonCoords.add(data['features'][i]['geometry']['coordinates']
      [0]
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList());
    }
    print("polygonCoords $polygonCoords");
    update();
  }

  Set<Polygon> _polygons = {};



  void _onPolygonTapped(Polygon polygon) {
        _polygons = _polygons.map((Polygon p) {
        if (p.polygonId == polygon.polygonId) {
          return p.copyWith(fillColorParam: Colors.green.withOpacity(0.5));
        }
        return p.copyWith(fillColorParam: Colors.transparent);
      }).toSet();
    update();
  }

// bool isInSelectedArea = true;
//
// void checkUpdateLocation(LatLng pointLatLng) {
//   print("hi");
//   isInSelectedArea = map.PolygonUtil.containsLocation(
//       pointLatLng as map.LatLng, pointLatLng as List<map.LatLng>, false);
//   print("updateLatLng:| $isInSelectedArea  $pointLatLng");
//
//   update();
// }
}