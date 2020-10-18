import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayBloc.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayEvent.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayState.dart';
import 'package:diplwmatikh_map_test/bloc/KeyManagerEvent.dart';
import 'package:diplwmatikh_map_test/bloc/NotificationEvent.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meta/meta.dart';
import '../GameState.dart';
import 'KeyManagerBloc.dart';
import 'NotificationBloc.dart';

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

  FirebaseMessaging _firebaseMessaging;
  Status status=Status.none;
  BackgroundDisplayBloc backgroundDisplayBloc;
  KeyManagerBloc keyManagerBloc;
  NotificationBloc notificationBloc;
  GameState _gameState;
  int userId=1;
  int teamId;
  List teamColor;
  String teamName;
  //Initialization
  Future<void> init(BackgroundDisplayBloc backgroundDisplayBloc,KeyManagerBloc keyManagerBloc,NotificationBloc notificationBloc) async{
    //firebase init
    _firebaseMessaging =FirebaseMessaging()..configure(
      onMessage: (message) async {_onFirebaseMessage(message);},
    );
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.subscribeToTopic("session4");

//    TODO close them on closing the game instance. Uncommenting might be enough
    //KeyManagerBloc init
//    if (this.keyManagerBloc!=null) this.keyManagerBloc.close();
    this.keyManagerBloc=keyManagerBloc;

    //BackgroundDisplayBloc init
//    if (this.backgroundDisplayBloc!=null) this.backgroundDisplayBloc.close();
    this.backgroundDisplayBloc=backgroundDisplayBloc;

    this.notificationBloc = notificationBloc;

    //assetRegistry init
    int version = await _recoverVersionNumber();
    http.Response response= await  _getRequest("/init/1?version=$version");
    if (response.statusCode!=HttpStatus.ok){
      status=Status.error;
      return;
    }
    await createAssetDirectory();
    if(!(response.body.contains("confirm"))) _replaceAssetRegistry(response.body);
    status = Status.initialized;

    //gameState init
    _gameState = GameState(json.decode(await retrieveAssetRegistry()));
    Map team = (await teamFromUserId(userId.toString()));
    teamId=team['@TeamId'];
    teamColor = team['Color'];
    teamName = team['TeamName'];
  }

  Future<String> retrieveAssetRegistry() async{
    final path=await _localPath;
    File registry=File("$path\\asset_registry.json");
    try{
      return registry.readAsStringSync();
    }
    on FileSystemException catch(e){
      return "Cannot find asset registry.";
    }
  }

  Future<String> addMove({@required int objectId, @required int keyId, @required String type, int position}) async{
    String extension="/move?objectId=${objectId.toString()}&userId=1&sessionId=1&type=$type";
    extension += "&keyId=${(type!="scan")?keyId:"null"}";
    if (position!=null) extension +="&position=$position";

    http.Response response= await _getRequest(extension);
    Map responseJson = json.decode(response.body);
    bool needSync = true;

    if (responseJson["outcome"].contains("valid move"))needSync=false;
    if (needSync) getPastMoves();

    return response.body;
  }

  void getPastMoves() async{
    http.Response response= await _getRequest("/past_moves/");
//    print(response.body);
//    print(response.body.runtimeType);

  }

  Future<List<int>> requestKeys() async {
    String parameters = "/keys?sessionId=1&userId=1";
    http.Response response = await _getRequest(parameters);
    Map responseJson = json.decode(response.body);
    try {

      return (responseJson['keys'] as List<dynamic>).cast<int>();
    }
    catch (e) {print(e);}
  }

  //ImageRetrieval
  Future<Image> retrieveImage(String imageName) async{
    final String path = await _localPath;
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

// get local path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //send post request
  Future<http.Response> _getRequest(String extension) async {
//    String url = 'http://192.168.2.2:8888'; //server hardcode here
    String url = 'http://hci.ece.upatras.gr:8888'; //server hardcode here

    http.Response response = await http
        .get(url + extension);

    return response;
  }

  //get version number from the asset registry
  Future<int> _recoverVersionNumber() async{
    final path=await _localPath;
    File registry=File("$path\\asset_registry.json");
    try {
      String registryContents = registry.readAsStringSync();
      if (registryContents==null) return 0;
      Map parsedJson = json.decode(registryContents);
      return parsedJson['version'];
    }
    on FileSystemException catch(e){
      return 0;
    }

  }


  //delete previous registry and save current
  void _replaceAssetRegistry(jsonFile) async{
    final path=await _localPath;
    File registry=File("$path\\asset_registry.json");
    registry.writeAsStringSync(jsonFile);
  }

  void debugPrint(String path) async{
    File file=File(path);
    String contents=file.readAsStringSync();
    print("Debug Print:" + contents);
  }

  //asset directory creator function
  Future<void> createAssetDirectory() async{
    final path=await _localPath;
    Directory(path +"/assets").create();

  }


  //Firebase Message Receiver
  void _onFirebaseMessage(Map<String,dynamic> messageReceived) async{
//    TODO confirm session number
    print(messageReceived);
    Map<String,dynamic> body = json.decode(messageReceived['data']['body']);

    // TODO call this and return if there has been a sync error
    // TODO count points if self
    if (messageReceived['data']['title']=="Move"){

      if (body['type']=="match"){
        updateCounter(body);
        backgroundDisplayBloc.scoreboard_changed= true;
        displayAwareInsert(body);
        keyManagerBloc.add(KeyManagerKeyMatch((await teamFromUserId(body["userId"]))['@TeamId'],body["userId"], body['keyId']));
        notificationBloc.add(NotificationReceivedFromMatch(json:body));
      }
      else if (body['type']=="unmatch") {
        updateCounter(body);
        backgroundDisplayBloc.scoreboard_changed= true;
        if (backgroundDisplayBloc.state is ObjectDisplayBuilt && body['objectId'] == backgroundDisplayBloc.state.props[3]){
          //version - specific code
          if (body['userId']==userId.toString()) backgroundDisplayBloc.add(BackgroundDisplayBecameOutdated(body['keyId'].toString(),body['position'],body['userId']==userId.toString(),false));

//          //spam filter
//          Map team = await teamFromUserId(body['userId']);
//           int score = backgroundDisplayBloc.scoreboard.firstWhere((element) => element[1]==team['TeamName'],orElse: ()=>[0,0,1])[2];
//           if (score ==0) return;
//          //
          notificationBloc.add(NotificationReceivedFromUnmatch(json:body));
        }
      }
      else if (body['type']=="notification"){
        print("hereeeeeeeeeeeee");
        notificationBloc.add(NotificationReceivedFromAdmin(text:body['text'],timestamp: body['timestamp']));
      }
    }

  }

  void displayAwareInsert(Map<String, dynamic> body) {
    //version - specific code
    bool response = _gameState.insert(objectId: body['objectId'].toString(), keyId: body["keyId"].toString(), matchmaker: body["userId"].toString(),position: body["position"]);
    if (backgroundDisplayBloc.state is ObjectDisplayBuilt && body['objectId']==backgroundDisplayBloc.state.props[3] && response) backgroundDisplayBloc.add(BackgroundDisplayBecameOutdated(body['keyId'].toString(),body['position'],body['userId']==userId.toString(),true));
  }

  void updateCounter(Map<String,dynamic> body){
    if (body['lastMoveId']<=_gameState.currentMoveId){
      _gameState.currentMoveId=body['currentMoveId'];
      return;
    }
    getPastMoves();
  }

  List<dynamic> readFromGameState({@required objectId}){
    List<dynamic> matches = _gameState.read(objectId: objectId);
    return matches;
  }

  Future<Map> teamFromUserId(String userId) async{
    String assetRegistry = await retrieveAssetRegistry();
    Map assetJSON = jsonDecode(assetRegistry);
    List teams= assetJSON['joumerka']['Teams'];
    return teams.firstWhere((element) {
      List playerIds = element['PlayerIds'];
      if (playerIds.contains(userId)) return true;
      return false;
    });
  }

  Future<List> getScore() async{
    String parameters = "/score/1";
    http.Response response = await _getRequest(parameters);


    try {
      backgroundDisplayBloc.scoreboard_changed = false;
      return (jsonDecode(response.body));
    }
    catch (e) {print(e);}

  }


}