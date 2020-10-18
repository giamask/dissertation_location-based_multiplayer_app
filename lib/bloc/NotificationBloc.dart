import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../NotificationTile.dart';
import 'AnimationBloc.dart';

import 'NotificationEvent.dart';
import 'NotificationState.dart';
import 'ResourceManager.dart';

class NotificationBloc extends Bloc<NotificationEvent,NotificationState>{
  final notificationListKey = GlobalKey<AnimatedListState>();
  final List<List> notificationsInTray= [];

  @override
  Future<void> close(){
    return super.close();
  }


  @override
  NotificationState get initialState =>  NotificationTrayRead();

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async*{
    if (event is NotificationReceivedFromMatch){
      Map<String,dynamic> json = event.props[0];
      String text = "Ο παίκτης <b>${json['userId']}</b> αντιστοίχισε το στοιχείο <b>${json['keyId'].toString()}</b> στην τοποθεσία <b>${json['objectId'].toString()}</b>.";
      RichText richText = dataToRichText(text);
      List colorValues = (await ResourceManager().teamFromUserId(json['userId']))['Color'];
      Color color = Color.fromRGBO(colorValues[0],colorValues[1],colorValues[2],1);
      notificationsInTray.insert(0, [json['timestamp'],richText,true,["k${json['keyId'].toString()}.jpg","${json['objectId'.toString()]}.jpg"],color]);
      notificationListKey.currentState.insertItem(0,duration: Duration(seconds: 1));

      yield NotificationTrayUnread();
    }
    if (event is NotificationReceivedFromUnmatch){
      Map<String,dynamic> json = event.props[0];
      Map team= (await ResourceManager().teamFromUserId(json['userId']));
      String text = "Ο παίκτης <b>${json['userId']}</b> της ομάδας <b>${team['TeamName']}</b> έχασε πόντους κάνοντας μια λανθασμένη αντιστοίχηση.";
      RichText richText = dataToRichText(text);
      List colorValues = team['Color'];
      Color color = Color.fromRGBO(colorValues[0],colorValues[1],colorValues[2],1);
      notificationsInTray.insert(0, [json['timestamp'],richText,false,null,color]);
      notificationListKey.currentState.insertItem(0,duration: Duration(seconds: 1));

      yield NotificationTrayUnread();
    }
    if (event is NotificationReceivedFromAdmin){
      RichText richText = dataToRichText(event.props[0]);
      final color = Colors.grey;
      notificationsInTray.insert(0,[event.props[1],richText,false,null,color]);
      notificationListKey.currentState.insertItem(0,duration: Duration(seconds: 1));
      yield NotificationTrayUnread();
    }
    if (event is NotificationTrayOpened){
      
      yield NotificationTrayRead();
    }
    if (event is NotificationTrayClosed){
      //TODO reset scroll
    }
    if (event is NotificationDeleted){
      //TODO delete not by id
    }

  }

  RichText dataToRichText(String text) {
    bool startsBold = false;
    if (text.startsWith("<b>")) startsBold = true;
    List<String> splitText = text.split(RegExp("<b>|<\/b>"));

    return  RichText(
        text: TextSpan(
          text: splitText[0],
          style: TextStyle(
              color: Colors.white, fontSize: 16,fontWeight: startsBold?FontWeight.bold:FontWeight.normal),
          children: [for (int i=1;i<splitText.length;i++)
            TextSpan(text:splitText[i],style: TextStyle(fontWeight: (startsBold?i%2==0:i%2==1)?FontWeight.bold:FontWeight.normal)),
          ],
        ));
  }

}


