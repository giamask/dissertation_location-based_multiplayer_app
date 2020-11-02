
import 'dart:async';
import 'dart:convert';
import 'package:diplwmatikh_map_test/GameState.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayBloc.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayEvent.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayState.dart';
import 'package:diplwmatikh_map_test/bloc/KeyManagerBloc.dart';
import 'package:diplwmatikh_map_test/bloc/KeyManagerEvent.dart';
import 'package:diplwmatikh_map_test/bloc/NotificationBloc.dart';
import 'package:diplwmatikh_map_test/bloc/NotificationEvent.dart';
import 'package:diplwmatikh_map_test/bloc/OrderState.dart';
import 'package:flutter/material.dart';
import 'ResourceManager.dart';

class FirebaseMessageHandler {
  // TODO confirm session number


  BackgroundDisplayBloc backgroundDisplayBloc;
  KeyManagerBloc keyManagerBloc;
  NotificationBloc notificationBloc;
  StreamSubscription subscriptionToOrderBloc;
  List<Map<String,dynamic>> messageBuffer = [];

  FirebaseMessageHandler(
      this.backgroundDisplayBloc, this.keyManagerBloc, this.notificationBloc);


  void messageReceiver(Map<String,dynamic> messageReceived){
    print(messageReceived.toString() + " <- firebase message");
    String bodyAsString = messageReceived['data']['body'];
    Map<String,dynamic> body = json.decode(bodyAsString);
    if (body['type']=='match' || body['type']=="unmatch"){
      if (body['currentMoveId']<=ResourceManager().orderBloc.currentMove) return;
      if (ResourceManager().orderBloc.state is OrderUpdateInProcess){
        messageBuffer.add(messageReceived);
        return;
      }
      ResourceManager().notifyOrderManager(body);
    }
    else if(body['type']=="notification"){
      notificationBloc.add(NotificationReceivedFromAdmin(text:body['text'],timestamp: body['timestamp']));
    }
  }

  void setUpListener(){
    subscriptionToOrderBloc = ResourceManager().orderBloc.listen((state) {
      if (state is OrderUpToDate && messageBuffer.isNotEmpty){
        messageBuffer.forEach((element) {
          messageReceiver(element);
        });
        messageBuffer.clear();
      }
    });
  }




}
