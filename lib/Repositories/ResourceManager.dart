import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:diplwmatikh_map_test/GameState.dart';
import 'package:diplwmatikh_map_test/bloc/OrderBloc.dart';
import 'package:diplwmatikh_map_test/bloc/OrderEvent.dart';
import 'package:diplwmatikh_map_test/bloc/ScanBloc.dart';
import 'AssetRegistryManager.dart';
import 'FirebaseMessageHandler.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayBloc.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayEvent.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayState.dart';
import 'package:diplwmatikh_map_test/bloc/KeyManagerBloc.dart';
import 'package:diplwmatikh_map_test/bloc/KeyManagerEvent.dart';
import 'package:diplwmatikh_map_test/bloc/NotificationBloc.dart';
import 'package:diplwmatikh_map_test/bloc/NotificationEvent.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meta/meta.dart';


/*
Για την χρήση αυτής της κλάσης χρειάζεται ο ορισμός ενός server (hardcoded σε local host) και η χρήση συγκεκριμένου formatting στα αρχεία. Συγκεκριμένα:
asset_registry.json που να περιέχει το version (int).
assets/$imageName.jpg
Επισης προσοχή στα paths του server.
*/

enum Status{
  none,
  initialized,
  error
}

class ResourceManager{
  // Singleton
  static final ResourceManager _resourceManager= ResourceManager._internal();

  factory ResourceManager(){
    return _resourceManager;
  }
  ResourceManager._internal(){}

  ConnectivityResult connectivityState = ConnectivityResult.mobile;
  FirebaseMessaging _firebaseMessaging;
  Status status=Status.none;
  BackgroundDisplayBloc backgroundDisplayBloc;
  KeyManagerBloc keyManagerBloc;
  OrderBloc orderBloc;
  NotificationBloc notificationBloc;
  GameState gameState;
  int userId=1;
  bool cheatMode=false;
  int teamId;
  List teamColor;
  String teamName;
  FirebaseMessageHandler firebaseMessageHandler;
  AssetRegistryManager assetRegistryManager;
  //Initialization
  Future<void> init(BackgroundDisplayBloc backgroundDisplayBloc,KeyManagerBloc keyManagerBloc,NotificationBloc notificationBloc,OrderBloc orderBloc) async{
    assetRegistryManager = AssetRegistryManager();
    firebaseMessageHandler= FirebaseMessageHandler(backgroundDisplayBloc,keyManagerBloc,notificationBloc);
    //firebase init
    _firebaseMessaging =FirebaseMessaging()..configure(
      onMessage: (message) async {_onFirebaseMessage(message);},
    );
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.subscribeToTopic("session6");

//    TODO close them on closing the game instance. Uncommenting might be enough
    //KeyManagerBloc init
//    if (this.keyManagerBloc!=null) this.keyManagerBloc.close();
    this.keyManagerBloc=keyManagerBloc;

    //BackgroundDisplayBloc init
//    if (this.backgroundDisplayBloc!=null) this.backgroundDisplayBloc.close();
    this.backgroundDisplayBloc=backgroundDisplayBloc;

    this.notificationBloc = notificationBloc;
    this.orderBloc = orderBloc;
    firebaseMessageHandler.setUpListener();
    //assetRegistry init
    int version = await assetRegistryManager.getVersionNumber();
    http.Response response= await  _getRequest("/init/1?version=$version");
    if (response.statusCode!=HttpStatus.ok){
      status=Status.error;
      return;
    }
    await createAssetDirectory();
    if(!(response.body.contains("confirm"))) assetRegistryManager.replaceAssetRegistry(response.body);
    status = Status.initialized;
    //gameState init
    gameState = GameState(json.decode(await assetRegistryManager.retrieveAssetRegistry()));
    Map team = (await assetRegistryManager.teamFromUserId(userId.toString()));
    teamId=team['@TeamId'];
    teamColor = team['Color'];
    teamName = team['TeamName'];
    final Connectivity _connectivity = Connectivity();
    StreamSubscription<ConnectivityResult> _connectivitySubscription;
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

  }

  void _onFirebaseMessage(Map<String,dynamic> messageReceived) async => firebaseMessageHandler.messageReceiver(messageReceived);
  Future<String> retrieveAssetRegistry() async =>  assetRegistryManager.retrieveAssetRegistry();
  Future<Map> teamFromUserId(String userId) async => assetRegistryManager.teamFromUserId(userId);


  Future<String> addMove({@required  int objectId, @required int keyId, @required String type, int position}) async{
    String extension="/move?objectId=${objectId.toString()}&userId=1&sessionId=1&type=$type";
    extension += "&keyId=${(type!="scan")?keyId:"null"}";
    if (position!=null) extension +="&position=$position";

    http.Response response= await _getRequest(extension);
    Map responseJson = json.decode(response.body);
    bool needSync = true;
    if (responseJson["outcome"].contains("valid move")) needSync=false;
    if (needSync) orderBloc.add(OrderInconsistencyDetected());
    return response.body;
  }

  Future<List> getPastMoves(int lastKnownMove) async{
    http.Response response= await _getRequest("/past_moves/1?move="+lastKnownMove.toString());
    return(jsonDecode(response.body));
  }

  Future<List> getScore() async{
    String parameters = "/score/1";
    http.Response response = await _getRequest(parameters);
    try {
      backgroundDisplayBloc.scoreboardChanged = false;
      return (jsonDecode(response.body));
    }
    catch (e) {print(e);}
  }

  Future<void> addScan({@required int objectId,DateTime dateTime }) async{
    String parameters = "/scan/1?userId=$userId&objectId=$objectId&timestamp=$dateTime";
    http.Response response = await _getRequest(parameters);
    try{
      if (!response.body.contains("confirm")) throw Exception("Scan did not register to server.");
    }
    catch(e){
      print (e);
    }
  }

  Future<List<Scan>> getScans() async{
    String parameters = "/past_scans/1?userId=$userId";
    http.Response response = await _getRequest(parameters);
    List<Scan> scanList = [];
    try{
      Map jsonResponse = (jsonDecode(response.body));
      jsonResponse.forEach((key, value) { scanList.add(Scan(int.parse(key),DateTime.parse(value)));});
    }
    catch(e){
      print (e);
    }
    return scanList;
  }

  Future<List<int>> getKeys() async {
    String parameters = "/keys?sessionId=1&userId=1";
    http.Response response = await _getRequest(parameters);
    Map responseJson = json.decode(response.body);
    try {
      return (responseJson['keys'] as List<dynamic>).cast<int>();
    }
    catch (e) {
      print(e);
      return [];
    }
  }

  //ImageRetrieval
  Future<Image> retrieveImage(String imageName) async{
    final String path = await assetRegistryManager.localPath;
    File imageFile=File("$path/assets/$imageName");

    try{
      if (imageFile.readAsBytesSync().isEmpty) throw FileSystemException();
      return Image.file(imageFile);
    }
    on FileSystemException catch(e){
      http.Response response= await  _getRequest("/image/$imageName");
      imageFile.writeAsBytesSync(response.bodyBytes);
      return Image.file(imageFile);
    }
  }

  //asset directory creator function
  Future<void> createAssetDirectory() async{
    final path=await assetRegistryManager.localPath;
    Directory(path +"/assets").create();
  }



  Future<http.Response> _getRequest(String extension) async {
//    String url = 'http://192.168.2.2:8888'; // local host
    String url = 'http://hci.ece.upatras.gr:8888'; // hci server

    http.Response response = await http
        .get(url + extension);

    return response;
  }



  void notifyOrderManager(Map<String,dynamic> body)  {
    orderBloc.add(OrderMoveAdded(move:body));
  }

  List<dynamic> readFromGameState({@required objectId}){
    List<dynamic> matches = gameState.read(objectId: objectId);
    return matches;
  }


  void _updateConnectionStatus(ConnectivityResult event) {
    if ((ConnectivityResult.none != event) && connectivityState == ConnectivityResult.none){
      orderBloc.add(OrderConnectivityIssueDetected());
    }
    if (ConnectivityResult.none == event && connectivityState != ConnectivityResult.none){}
    connectivityState = event;
  }
}