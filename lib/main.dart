import 'dart:io';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/InitEvent.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diplwmatikh_map_test/CustomFloatingButton.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'KeyList.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'PopUp.dart';
import 'package:diplwmatikh_map_test/bloc/InitBloc.dart';
import 'bloc/DialogState.dart';
import 'bloc/InitState.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Google Maps Demo',
        theme: Theme.of(context).copyWith(accentColor: Colors.black),
        home:
            BlocProvider(create: (context) => InitBloc(), child: MainWidget()));
  }
}

class MainWidget extends StatefulWidget {
  @override
  State<MainWidget> createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> {

  static Completer cameraIdle;
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
        body: BlocBuilder<InitBloc, InitState>(builder: (context, state) {
          if (!(state is Initialized))
            return Builder(builder: (context) {
              if (state is PreInitialize) BlocProvider.of<InitBloc>(context)
                  .add(GameInitialized());
              return Container(
                  child: Center(child: CircularProgressIndicator()));
            });
          return Stack(
            children: <Widget>[
              Container(color:Colors.lime),
              Transform.scale(
                scale: 1,
                child: Transform.translate(
                  offset: Offset(0,0),
                  child: GoogleMap(
                    onCameraIdle: () =>
                    (cameraIdle != null ? cameraIdle.complete() : null),
                    markers: state.props[0],
                    tiltGesturesEnabled: false,
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      final Completer<GoogleMapController> _controller = state.props[1];
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
                  ),
                ),
              ),
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
              BlocListener(
                bloc:BlocProvider.of<InitBloc>(context).dialogBloc,
                  listener: (context,state){
                  if (state is Ready){
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
                                    onTapUp: (details) => details.localPosition.dy > 130
                                        ? Navigator.of(context).pop()
                                        : null,
                                    child: Container(
                                        height: PopUp.HEIGHT,
                                        width: PopUp.WIDTH,
                                        child: Material(
                                            color: Colors.transparent,
                                            child: PopUp(3, state.props[2], () {}, state.props[1],state.props[4],state.props[3])))),
                              )
                            ],
                          );
                        });
                  }
                    },
                  child: Container()
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
                  top: MediaQuery
                      .of(context)
                      .size
                      .height * 0.758,
                  child: KeyList()),

            ],
          );
        }));
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

}