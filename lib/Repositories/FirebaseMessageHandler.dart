
import 'dart:convert';
import 'package:diplwmatikh_map_test/GameState.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayBloc.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayEvent.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayState.dart';
import 'package:diplwmatikh_map_test/bloc/KeyManagerBloc.dart';
import 'package:diplwmatikh_map_test/bloc/KeyManagerEvent.dart';
import 'package:diplwmatikh_map_test/bloc/NotificationBloc.dart';
import 'package:diplwmatikh_map_test/bloc/NotificationEvent.dart';
import 'ResourceManager.dart';

class FirebaseMessageHandler {
  // TODO confirm session number
  // TODO call this and return if there has been a sync error

  BackgroundDisplayBloc backgroundDisplayBloc;
  KeyManagerBloc keyManagerBloc;
  NotificationBloc notificationBloc;

  FirebaseMessageHandler(
      this.backgroundDisplayBloc, this.keyManagerBloc, this.notificationBloc);



  void messageReceiver(Map<String,dynamic> messageReceived){
    print(messageReceived.toString() + " <- firebase message");
    String bodyAsString = messageReceived['data']['body'];
    Map<String,dynamic> body = json.decode(bodyAsString);
    switch(body['type']){
      case 'match':
        matchHandler(body);
        break;
      case 'unmatch':
        unmatchHandler(body);
        break;
      case 'notification':
        notificationHandler(body);
        break;
    }

  }

  void matchHandler(Map<String,dynamic> match) async{
    ResourceManager().updateCounter(match);
    backgroundDisplayBloc.scoreboard_changed= true;
    insertAndDisplay(match);
    notificationBloc.add(NotificationReceivedFromMatch(json:match));
    keyManagerBloc.add(KeyManagerKeyMatch((await ResourceManager().assetRegistryManager.teamFromUserId(match["userId"]))['@TeamId'],match["userId"], match['keyId']));
  }

  void unmatchHandler(Map<String,dynamic> unmatch) async{
    ResourceManager().updateCounter(unmatch);
    backgroundDisplayBloc.scoreboard_changed= true;
    if (backgroundDisplayBloc.state is ObjectDisplayBuilt && unmatch['objectId'] == backgroundDisplayBloc.state.props[3]){
      if (unmatch['userId']==ResourceManager().userId.toString()) {
        backgroundDisplayBloc.add(BackgroundDisplayBecameOutdated(
            unmatch['keyId'].toString(), unmatch['position'],
            unmatch['userId'] == ResourceManager().userId.toString(), false));
      }
      if (unmatch['showNotification']==null) notificationBloc.add(NotificationReceivedFromUnmatch(json:unmatch));
    }
  }

  void notificationHandler(Map<String, dynamic> notification) {
    notificationBloc.add(NotificationReceivedFromAdmin(text:notification['text'],timestamp: notification['timestamp']));
  }

  void insertAndDisplay(Map<String, dynamic> body) {
    bool response = ResourceManager().gameState.insert(objectId: body['objectId'].toString(), keyId: body["keyId"].toString(), matchmaker: body["userId"].toString(),position: body["position"]);
    if (backgroundDisplayBloc.state is ObjectDisplayBuilt && body['objectId']==backgroundDisplayBloc.state.props[3] && response) backgroundDisplayBloc.add(BackgroundDisplayBecameOutdated(body['keyId'].toString(),body['position'],body['userId']==ResourceManager().userId.toString(),true));
  }



}
