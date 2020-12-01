import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayBloc.dart';
import 'package:diplwmatikh_map_test/bloc/ScanEvent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../GameState.dart';
import 'ErrorBloc.dart';
import 'ErrorEvent.dart';
import 'KeyManagerBloc.dart';
import 'package:diplwmatikh_map_test/bloc/KeyManagerEvent.dart';
import 'OrderBloc.dart';
import 'OrderEvent.dart';
import 'ScanBloc.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:diplwmatikh_map_test/GameScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'DialogBloc.dart';
import 'InitEvent.dart';
import 'InitState.dart';
import 'DialogEvent.dart';
import 'NotificationBloc.dart';

class InitBloc extends Bloc<InitEvent,InitState>{
  DialogBloc dialogBloc ;
  final String user;
  final int sessionId;
  final BackgroundDisplayBloc backgroundDisplayBloc;
  final KeyManagerBloc keyManagerBloc;
  final NotificationBloc notificationBloc;
  final OrderBloc orderBloc;
  final ScanBloc scanBloc;
  final BuildContext context;
  final ErrorBloc errorBloc;

  InitBloc(this.user,this.sessionId,this.errorBloc,this.backgroundDisplayBloc,this.keyManagerBloc,this.notificationBloc,this.orderBloc,this.scanBloc,this.context,){
    dialogBloc = DialogBloc(context);
  }

  @override
  Future<void> close() {
    dialogBloc.close();
    return super.close();
  }

  @override
  InitState get initialState => InitializeInProgress();

  @override
  Stream<InitState> mapEventToState(InitEvent event) async*{
    if (event is GameInitialized && !(state is Initialized)) {
      ResourceManager resourceManager = ResourceManager();
      try {
        await resourceManager.init(user,sessionId,
            backgroundDisplayBloc, keyManagerBloc, notificationBloc, orderBloc,errorBloc);
        String assetRegistry = await resourceManager.retrieveAssetRegistry();
        Set<Marker> markers = objectMarkersFromJson(assetRegistry);
        keyManagerBloc.add(KeyManagerListInitialization());
        orderBloc.add(OrderInitialized());
        scanBloc.add(ScanInitialized());
        if (!await permissionManager()) BlocProvider.of<ErrorBloc>(context).add(ErrorThrown(CustomError(id: 31, message: "Για τη σωστή λειτουργία της εφαρμογής δώστε δικαίωματα πρόσβασης στην τοποθεσία σας")));
        yield Initialized(markers: markers,controller: Completer());
      }
      on ErrorEvent catch (ee){
        BlocProvider.of<ErrorBloc>(context).add(ee);
      }
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
      BlocProvider.of<ErrorBloc>(context).add(ErrorThrown(CustomError(id: 1, message: "Δεν έγινε σωστή εκκίνηση της εφαρμογής")));
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
    MainWidgetState.cameraIdle=new Completer();
    await MainWidgetState.cameraIdle.future;

    List<dynamic> keyMatches = ResourceManager().readFromGameState(objectId: object["@ObjectId"]);
    List<Color> colors = [];
    keyMatches.forEach((element) async {
        KeyMatch keyMatch = element;
        Map team = await ResourceManager().teamFromUserId(keyMatch.matchmaker);

        colors.add(Color.fromRGBO(team['Color'][0], team['Color'][1], team['Color'][2], 1));
    });
    //hardcode
    int slots = 3;

    List<bool> matches = [for (int i=0;i<keyMatches.length;i++) true, for (int i=0;i<slots-keyMatches.length;i++) false];
    dialogBloc.add(MarkerTap(id:object["@ObjectId"],name:object["ObjectTitle"],matches: matches,imagePath: object["ObjectImage"],colors: colors));

  }



  Future<void> moveZoomCamera(LatLng latlen, double zoom) async {
    final Completer<GoogleMapController> _controller = state.props[1];
    final GoogleMapController controller = await _controller.future;
    try {
      controller.animateCamera(CameraUpdate.newLatLngZoom(latlen, zoom));
    }
    catch(e){
      BlocProvider.of<ErrorBloc>(context).add(ErrorThrown(CustomError(id: 40, message: "Ο χάρτης δεν ανταποκρίνεται σωστά. Συνίσταται η επανεκκίνηση της εφαρμογής")));
    }
  }

  Future<bool> permissionManager() async {
      return true;
  }

}



