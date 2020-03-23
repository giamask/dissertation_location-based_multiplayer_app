import 'package:flutter/material.dart';
//AIzaSyAgpR5OehDygZbymBI82KhJ4FTEXjdgSaQ
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.745174, 23.427974),
    zoom: 15.7746,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: FutureBuilder(
          future: permissionManager(),

          builder: (context, snap) {
            if (snap.data==true){
            return GoogleMap(
              markers: objectMarkersFromJson(
                "{\"markers\":[{\"len\":23.432223,\"lat\":37.746841,\"text\":\"X1\"},{\"len\":23.432223,\"lat\":37.751841,\"text\":\"X2\"}]}"
              ),
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: true,
              compassEnabled: false,
              cameraTargetBounds: CameraTargetBounds(LatLngBounds(northeast: LatLng(37.771908,23.464144),southwest: LatLng(37.727996,23.415847)),),//hardcoded limits
              minMaxZoomPreference: MinMaxZoomPreference(14, 30),
              myLocationButtonEnabled: false,

            );
          }
          return Container();}),
    );
  }

  Future<void> moveCamera(CameraPosition cp) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  Future<bool> permissionManager() async {
    Map<PermissionGroup, PermissionStatus> permission =
        await PermissionHandler().requestPermissions([PermissionGroup.locationWhenInUse]);
    if (permission[PermissionGroup.locationWhenInUse]== PermissionStatus.granted){
      return true;
    }
    return false;
  }


  Set<Marker> objectMarkersFromJson(String markers) {
    final Map<String,dynamic>jsonMarkers = json.decode(markers);
    final Set<Marker> set=Set();
    jsonMarkers["markers"].forEach((element){
      print(element["lat"]);

      set.add(Marker(
        markerId: MarkerId(element["text"]),
        position:  LatLng(element["lat"],element["len"]),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        consumeTapEvents: true
      ));
    });

    return set;
  }

}

