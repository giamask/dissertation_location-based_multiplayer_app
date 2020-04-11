import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/ResourceManager.dart';
import 'package:diplwmatikh_map_test/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'DialogBloc.dart';
import 'InitEvent.dart';
import 'InitState.dart';
import 'DialogEvent.dart';

class InitBloc extends Bloc<InitEvent,InitState>{
  final DialogBloc dialogBloc = DialogBloc();

  @override
  Future<void> close() {
    dialogBloc.close();
    return super.close();
  }

  @override
  InitState get initialState => InitializeInProgress();

  @override
  Stream<InitState> mapEventToState(InitEvent event) async*{
    if (event is GameInitialized) {
      ResourceManager resourceManager = ResourceManager();
      await resourceManager.init();
      String assetRegistry = await resourceManager.retrieveAssetRegistry();
      Set<Marker> markers = objectMarkersFromJson(assetRegistry);
      yield Initialized(markers: markers,controller: Completer());
    }
  }

  Set<Marker> objectMarkersFromJson(String objectList) {
    Map jsonFromObjectList = jsonDecode(objectList);
    List jsonMarkers = jsonFromObjectList["joumerka"]["ObjectList"];
    final Set<Marker> set = Set();
    jsonMarkers.forEach((element) {
      set.add(Marker(
          onTap: () {
          displayPopUp(element["@ObjectId"]);
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

  void displayPopUp(String objectId) async{
    if (!(state is Initialized) || ResourceManager().status != Status.initialized) {
      print("Status not initialized");
      return;
    }
    String assetRegistry = await ResourceManager().retrieveAssetRegistry();
    Map jsonFromObjectList = jsonDecode(assetRegistry);
    List jsonObjects = jsonFromObjectList["joumerka"]["ObjectList"];
    Map object=jsonObjects.firstWhere((element) {
      if (element["@ObjectId"] == objectId) return true;
      return false;
    });
    moveZoomCamera(
        LatLng(double.parse(object["ObjectLocation"].split(",")[0]),
            double.parse(object["ObjectLocation"].split(",")[1])),
        18);
    MainWidgetState.cameraIdle=Completer();
    await MainWidgetState.cameraIdle.future;
    dialogBloc.add(MarkerTap(id:object["@ObjectId"],name:object["ObjectTitle"],matches: [true,false,false],imagePath: object["ObjectImage"]));
  }



  Future<void> moveZoomCamera(LatLng latlen, double zoom) async {
    final Completer<GoogleMapController> _controller = state.props[1];
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(latlen, zoom));
  }

}



