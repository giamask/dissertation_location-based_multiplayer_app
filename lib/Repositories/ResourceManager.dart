import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:diplwmatikh_map_test/GameState.dart';
import 'package:diplwmatikh_map_test/bloc/ErrorBloc.dart';
import 'package:diplwmatikh_map_test/bloc/ErrorEvent.dart';
import 'package:diplwmatikh_map_test/bloc/LoginBloc.dart';
import 'package:diplwmatikh_map_test/bloc/LoginEvent.dart';
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

  LoginBloc loginBloc;
  Status status=Status.none;
  BackgroundDisplayBloc backgroundDisplayBloc;
  KeyManagerBloc keyManagerBloc;
  OrderBloc orderBloc;
  NotificationBloc notificationBloc;
  GameState gameState;
  ErrorBloc errorBloc;
  StreamSubscription<ConnectivityResult> connectivitySubscription;
  bool cheatMode=false;
  int teamId;
  List teamColor;
  String teamName;
  String user;
  int sessionId;
  FirebaseMessageHandler firebaseMessageHandler;
  AssetRegistryManager assetRegistryManager;
  //Initialization
  Future<void> init(String user, int sessionId,BackgroundDisplayBloc backgroundDisplayBloc,KeyManagerBloc keyManagerBloc,NotificationBloc notificationBloc,OrderBloc orderBloc,ErrorBloc errorBloc) async{
    this.user= user;
    this.sessionId = sessionId;
    assetRegistryManager = AssetRegistryManager();
    firebaseMessageHandler= FirebaseMessageHandler(backgroundDisplayBloc,keyManagerBloc,notificationBloc);
    //firebase init
    this.keyManagerBloc=keyManagerBloc;
    this.backgroundDisplayBloc=backgroundDisplayBloc;
    this.notificationBloc = notificationBloc;
    this.orderBloc = orderBloc;
    this.errorBloc=errorBloc;





    firebaseMessageHandler.setUpListener();
    //assetRegistry init
    int version = await assetRegistryManager.getVersionNumber();
    http.Response response;
    try {
      response = await _getRequest("/init/$sessionId?version=$version");
      if (response.statusCode != HttpStatus.ok) {
        status = Status.error;
        throw SocketException("");
      }
    }
    catch(e){
      throw ErrorFatalThrown(CustomError(id: 2,
          message: "Δεν υπήρξε απάντηση απο τον server. Ελέγξτε την σύνδεση σας στο internet και προσπαθήστε ξανά."));
    }
    await createAssetDirectory();
    if(!(response.body.contains("confirm"))) assetRegistryManager.replaceAssetRegistry(response.body);
    status = Status.initialized;
    //gameState init
    gameState = GameState(json.decode(await assetRegistryManager.retrieveAssetRegistry()));
    Map team = (await assetRegistryManager.teamFromUserId(user));
    teamId=team['@TeamId'];
    teamColor = team['Color'];
    teamName = team['TeamName'];
    final Connectivity _connectivity = Connectivity();

    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void onFirebaseMessage(Map<String,dynamic> messageReceived) async {
    String bodyAsString = messageReceived['data']['body'];
    Map<String,dynamic> body = json.decode(bodyAsString);
    print(body['type']);
    if ((body['type'] as String).contains("gameStarted")){
      loginBloc.add(LoginOutdated());
      return;
    }
    print("heyheyeheheeee");
    firebaseMessageHandler.messageReceiver(messageReceived);
  }
  Future<String> retrieveAssetRegistry() async =>  assetRegistryManager.retrieveAssetRegistry();
  Future<Map> teamFromUserId(String userId) async => assetRegistryManager.teamFromUserId(userId);


  Future<String> addMove({@required  int objectId, @required int keyId, @required String type, int position}) async{
    String extension="/move?objectId=${objectId.toString()}&userId=$user&sessionId=$sessionId&type=$type";
    extension += "&keyId=${(type!="scan")?keyId:"null"}";
    if (position!=null) extension +="&position=$position";
    try {
      http.Response response = await _getRequest(extension);
      Map responseJson = json.decode(response.body);

      if (!responseJson["outcome"].contains("valid move")) {
        orderBloc.add(OrderInconsistencyDetected());
        throw SocketException("");
      }
      return response.body;
    }
    on SocketException catch (ce){
      throw ErrorThrown(CustomError(id: 51,
          message: "Υπήρξε πρόβλημα με την αντιστοίχηση σας. Παρακαλώ προσπαθήστε ξανά."));
    }

  }

  Future<List> getPastMoves(int lastKnownMove) async{
    try {
      http.Response response = await _getRequest(
          "/past_moves/$sessionId?move=" + lastKnownMove.toString());
      return (jsonDecode(response.body));
    }
    on SocketException{
      throw ErrorThrown(CustomError(id: 52,
          message: "Αδυναμία επικοινωνίας με τον server. Ελέγξτε την σύνδεση σας στο internet."));
    }
  }

  Future<List> getScore() async{
    String parameters = "/score/$sessionId";
    try {
      http.Response response = await _getRequest(parameters);
      backgroundDisplayBloc.scoreboardChanged = false;
      return (jsonDecode(response.body));
    }
    on SocketException {
      throw ErrorThrown(CustomError(id: 53,
          message: "Αδυναμία επικοινωνίας με τον server. Ελέγξτε την σύνδεση σας στο internet."));
    }
  }

  Future<void> addScan({@required int objectId,DateTime dateTime }) async{
    String parameters = "/scan/$sessionId?userId=$user&objectId=$objectId&timestamp=$dateTime";
    try{
      http.Response response = await _getRequest(parameters);
      if (!response.body.contains("confirm")) throw SocketException("");
    }
    on SocketException{
      throw ErrorThrown(CustomError(id: 54,
          message: "Αδυναμία επικοινωνίας με τον server. Ελέγξτε την σύνδεση σας στο internet."));
    }
  }

  Future<List<Scan>> getScans() async{
    String parameters = "/past_scans/$sessionId?userId=$user";
    http.Response response = await _getRequest(parameters);
    List<Scan> scanList = [];
    try{
      Map jsonResponse = (jsonDecode(response.body));
      jsonResponse.forEach((key, value) { scanList.add(Scan(int.parse(key),DateTime.parse(value)));});
    }
    catch(e){}
    return scanList;
  }

  Future<List<int>> getKeys() async {
    String parameters = "/keys?sessionId=$sessionId&userId=$user";
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
  Future<Image> getImage(String imageName) async{
    final String path = await assetRegistryManager.localPath;
    File imageFile=File("$path/assets/$imageName");

    try{
      if (imageFile.readAsBytesSync().isEmpty) throw FileSystemException();
      return Image.file(imageFile);
    }
    on FileSystemException catch(e) {
      try {
        http.Response response = await _getRequest("/image/$imageName");
        if (response.body.isEmpty) throw SocketException("");
        imageFile.writeAsBytesSync(response.bodyBytes);
        return Image.file(imageFile);
      }
      on SocketException catch (se){
        throw ErrorThrown(CustomError(id: 55,
            message: "Αδυναμία φόρτωσης εικόνας. Ελέγξτε την σύνδεση σας στο internet."));
      }
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

  Future<String> playerNameFromUserId(String userId)async => assetRegistryManager.playerNameFromUserId(userId);


  Future<List<Map>> getSessions(String user) async{
    String parameters = "/sessions/$user";
    try {
      http.Response response = await _getRequest(parameters);
      List responseJson = json.decode(response.body);
      print(responseJson.runtimeType);
      return responseJson.cast<Map>();
    }
    on SocketException catch (se){
      throw ErrorThrown(CustomError(id: 57,
          message: "Αδυναμία φόρτωσης παιχνιδιών. Ελέγξτε την σύνδεση σας στο internet."));
    }
  }

  void _updateConnectionStatus(ConnectivityResult event) {
    if ((ConnectivityResult.none != event) && connectivityState == ConnectivityResult.none){
      orderBloc.add(OrderConnectivityIssueDetected());
    }
    if (ConnectivityResult.none == event && connectivityState != ConnectivityResult.none){
      errorBloc.add(ErrorThrown(CustomError(id:56,message: "Ανιχνεύθηκε διακοπή της σύνδεσης σας στο διαδίκτυο. Συνίσταται η αποκατάσταση της πριν συνεχίσετε.")));
    }
    connectivityState = event;
  }

}

