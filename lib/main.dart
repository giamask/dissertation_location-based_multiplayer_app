import 'dart:io';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diplwmatikh_map_test/CustomFloatingButton.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'KeyList.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'PopUp.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Google Maps Demo',
        theme: Theme.of(context).copyWith(accentColor: Colors.black),
        home: MainWidget());
  }
}

class MainWidget extends StatefulWidget {
  @override
  State<MainWidget> createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> {
  Completer<GoogleMapController> _controller = Completer();
  Completer finishedMoving;
  static final CameraPosition _kGooglePlex = CameraPosition(
    //target: LatLng(37.745174, 23.427974),
    target: LatLng(39.353284, 21.0),

    zoom: 13.7746,
  );
  bool cfbm_opening = false;
  bool cfbm_open = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
          FutureBuilder(
            future: getObjectList(),
            builder: (context, snap) {
              getObjectList();
              return GoogleMap(
                onCameraIdle: ()=>(finishedMoving!=null?finishedMoving.complete():null),
                markers: objectMarkersFromJson(snap.data),
                tiltGesturesEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
                compassEnabled: false,
                cameraTargetBounds: CameraTargetBounds(
                  LatLngBounds(
                      //northeast: LatLng(37.771908, 23.464144),
                      //southwest: LatLng(37.727996, 23.415847)),
                      northeast: LatLng(39.653284, 21.243507),
                      southwest: LatLng(39.201644, 20.8584)),
                ),
                //hardcoded limits
                minMaxZoomPreference: MinMaxZoomPreference(10, 30),
                myLocationButtonEnabled: false,
              );
            }),
        //          Builder(
        //            builder: (context) {
        //              return Positioned(
        //                top: MediaQuery.of(context).size.height/2 - 210,
        //                left: MediaQuery.of(context).size.width/2 - PopUp.WIDTH/2 ,
        //                child: PopUp(3, [true, false, false], () {}),
        //              );
        //            }
        //          ),
          AnimatedPositioned(
          right: 18,
          top: cfbm_opening ? 83 : 43,
          duration: Duration(milliseconds: 160),
          onEnd: () {
            if (cfbm_opening) {
              cfbm_open = true;
              setState(() {});
            }
          },
            child: CustomFloatingButton(
              onTap: () {
                cfbm_opening = !cfbm_opening;
                if (cfbm_open) cfbm_open = false;

                setState(() {});
              },
              icon: Icons.category,
              color: cfbm_open ? Colors.grey[600] : Colors.blue[900],
              size: 40),
        ),
          cfbm_open
              ? Positioned(
                  top: 30,
                  right: 30,
                  child: CustomFloatingButton(
                      icon: Icons.score, color: Colors.purple, size: 50),
                )
              : Container(),
          cfbm_open
              ? Positioned(
                  top: 78,
                  right: 65,
                  child: CustomFloatingButton(
                    icon: Icons.people,
                    color: Colors.purple,
                    size: 50,
                  ),
                )
              : Container(),
          cfbm_open
              ? Positioned(
                  top: 125,
                  right: 30,
                  child: CustomFloatingButton(
                    image: "assets/QRicon.png",
                    color: Colors.purple,
                    size: 50,
                    onTap: qrScan,
                  ),
                )
              : Container(),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.758, child: KeyList()),
      ],
    ));
  }

  Future<void> moveZoomCamera(LatLng latlen, double zoom) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(latlen, zoom));
  }

  void qrScan() async {
    String photoScanResult = await scanner.scan();
  }

// Asks permission to use location, returns true if given.
// import 'package:permission_handler/permission_handler.dart';
  /* Future<bool> permissionManager() async {
    Map<PermissionGroup, PermissionStatus> permission =
        await PermissionHandler().requestPermissions([PermissionGroup.locationWhenInUse]);
    if (permission[PermissionGroup.locationWhenInUse]== PermissionStatus.granted){
      return true;
    }
    return false;
  }*/

  Set<Marker> objectMarkersFromJson(String objectList) {
    Map jsonFromObjectList = json.decode(objectList);
    List jsonMarkers = jsonFromObjectList["GameOptions"]["ObjectList"];
    final Set<Marker> set = Set();
    jsonMarkers.forEach((element) {
      set.add(Marker(
          onTap: () {
            displayObjectWindow(element["@ObjectId"]);
          },
          markerId: MarkerId(element["@ObjectId"]),
          position: LatLng(
              double.parse(element["ObjectLocation"].split(",")[0]),
              double.parse(element["ObjectLocation"].split(",")[1])),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          consumeTapEvents: true));
    });

    return set;
  }

//kanonika apo to repository
  Future<String> getObjectList() async {
    return "{\"GameOptions\":{\"ObjectList\":[{\"@ObjectId\":\"1\",\"ObjectLocation\":\"39.594276, 21.107203,20\"},{\"@ObjectId\":\"2\",\"ObjectLocation\":\"39.59692, 21.105193,20\"},{\"@ObjectId\":\"3\",\"ObjectLocation\":\"39.5941354,21.1069223\"}]}}";
  }

  void displayObjectWindow(String id) async {
    //kanonika apo to repository
    Map json = jsonDecode(
        " {\"ObjectList\": [{\"@ObjectId\": \"1\",    \"ObjectTitle\": \"Χαγιάτια\",    \"ObjectDescription\": \"Πρόκειται για δύο μεγάλα πετρόχτιστα υπόστεγα με πεζούλια που χρησίμευαν για την αγοραπωλησία προϊόντων.\",\"ObjectHint\": \"Συρράκο, Χάνια\",\"CollectType\": \"QR\",\"CollectData\": \"1\",\"ObjectLocation\": \"39.594276, 21.107203,20\",\"ObjectImage\": \"1.jpg\"},{\"@ObjectId\": \"2\",\"ObjectTitle\": \"Η βρύση δίπλα στο γεφύρι στο Σιόπατου\",\"ObjectDescription\": \"Το γεφύρι στο Σιόπατου ή γεφύρι της βρύσης χρηματοδοτήθηκε από τις καλόγριες για να έχουν πρόσβαση στη βρύση.\",\"ObjectHint\": \"Συρράκο, η βρύση δίπλα στο γεφύρι του Σιόπατου\",\"CollectType\": \"QR\",\"CollectData\": \"2\",\"ObjectLocation\": \"39.59692, 21.105193,20\",\"ObjectImage\": \"2.jpg\"},{\"@ObjectId\": \"3\",\"ObjectTitle\": \"Άγιος Νικόλαος\",\"ObjectDescription\": \"Η εκκλησία του Αγ. Νικολάου βρίσκεται στο κέντρο του χωριού και χτίστηκε το 1834. Ο περίβολος της εκκλησίας ήταν το κέντρο της θρησκευτικής και της κοινωνικής ζωής του χωριού.\",\"ObjectHint\": \"Συρράκο, Εκκλησία Αγ. Νικολάου\",\"CollectType\": \"QR\",\"CollectData\": \"3\",\"ObjectLocation\": \"39.5941354,21.1069223\",\"ObjectImage\": \"3.jpg\"}]}");
    List objectList = json["ObjectList"];
    Map object = objectList.firstWhere((element) {
      if (element["@ObjectId"] == id) return true;
      return false;
    });
    moveZoomCamera(
        LatLng(double.parse(object["ObjectLocation"].split(",")[0]),
            double.parse(object["ObjectLocation"].split(",")[1])),
         18);
    finishedMoving = Completer();
    await finishedMoving.future;
    showGeneralDialog(
        context: context,
        barrierLabel: "Label",
        transitionDuration: Duration(milliseconds: 100),
        barrierDismissible: true,
        pageBuilder: (context, anim1, anim2) {
          return Stack(
            children: <Widget>[
              Positioned(
                top: MediaQuery.of(context).size.height / 2 - 210,
                left: MediaQuery.of(context).size.width / 2 - PopUp.WIDTH / 2,
                child: GestureDetector(
                    onTapUp: (details) => details.localPosition.dy > 130 ?Navigator.of(context).pop():null,
                    child: Container(
                        height: PopUp.HEIGHT,
                        width: PopUp.WIDTH,
                        child: Material(
                            color: Colors.transparent,
                            child: PopUp(3, [true, false, false], () {})))),
              )
            ],
          );
        });
  }
}
