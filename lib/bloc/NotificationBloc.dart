import 'dart:async';

import 'package:bloc/bloc.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/AssetRegistryManager.dart';
import 'package:flutter/material.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '../NotificationTile.dart';
import 'NotificationEvent.dart';
import 'NotificationState.dart';


class NotificationBloc extends Bloc<NotificationEvent,NotificationState>{
  final notificationListKey = GlobalKey<AnimatedListState>();
  final List<List> notificationsInTray= [];
  final SnappingSheetController snappingSheetController = SnappingSheetController();
  final ScrollController scrollController = ScrollController();

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

      String text = "Ο παίκτης <b>${await ResourceManager().playerNameFromUserId(json['userId'])}</b> αντιστοίχισε το στοιχείο <b>${json['keyId'].toString()}</b> στην τοποθεσία <b>${json['objectId'].toString()}</b>.";
      RichText richText = dataToRichText(text);

      List colorValues = (await ResourceManager().teamFromUserId(json['userId']))['Color'];

      Color color = Color.fromRGBO(colorValues[0],colorValues[1],colorValues[2],1);
      notificationsInTray.insert(0, [json['timestamp'],richText,true,["k${json['keyId'].toString()}.jpg","${json['objectId'.toString()]}.jpg"],color]);
      notificationListKey.currentState.insertItem(0,duration: Duration(seconds: 1));
      if (snappingSheetController.currentSnapPosition == null || snappingSheetController.currentSnapPosition.positionFactor<0.8) yield NotificationTrayUnread();
    }

    if (event is NotificationReceivedFromUnmatch){
      Map<String,dynamic> json = event.props[0];
      Map team= (await ResourceManager().teamFromUserId(json['userId']));
      String text = "Ο παίκτης <b>${await ResourceManager().playerNameFromUserId(json['userId'])}</b> της ομάδας <b>${team['TeamName']}</b> έχασε πόντους κάνοντας μια λανθασμένη αντιστοίχηση.";
      RichText richText = dataToRichText(text);
      List colorValues = team['Color'];
      Color color = Color.fromRGBO(colorValues[0],colorValues[1],colorValues[2],1);
      notificationsInTray.insert(0, [json['timestamp'],richText,false,null,color]);
      notificationListKey.currentState.insertItem(0,duration: Duration(seconds: 1));
      if (snappingSheetController.currentSnapPosition == null || snappingSheetController.currentSnapPosition.positionFactor<0.8) yield NotificationTrayUnread();
    }
    if (event is NotificationReceivedFromAdmin){
      RichText richText = dataToRichText(event.props[0]);
      final color = Colors.grey[600];
      notificationsInTray.insert(0,[event.props[1],richText,false,null,color]);
      notificationListKey.currentState.insertItem(0,duration: Duration(seconds: 1));
      if (snappingSheetController.currentSnapPosition == null || snappingSheetController.currentSnapPosition.positionFactor<0.8) yield NotificationTrayUnread();
    }
    if (event is NotificationTrayOpened && state is NotificationTrayUnread){
      yield NotificationTrayRead();
    }
    if (event is NotificationTrayClosed){
      scrollController.jumpTo(scrollController.initialScrollOffset);
    }
    if (event is NotificationDeleted){

      List props = notificationsInTray[event.index];
      notificationListKey.currentState.removeItem(event.index, (context, animation) => FadeTransition(
        opacity: Tween(begin: 0.0,end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve:Curves.easeIn,
            )
        ),
        child: NotificationTile(timestamp: props[0], text: props[1],expandable: props[2],assets: props[3],color:props[4],onDelete: ()=>{}),
        ),
      duration: Duration(milliseconds: 400));
      notificationsInTray.removeAt(event.index);

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


