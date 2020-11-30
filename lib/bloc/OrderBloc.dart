import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ErrorBloc.dart';
import 'ErrorEvent.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayBloc.dart';
import 'package:diplwmatikh_map_test/bloc/KeyManagerEvent.dart';
import 'package:flutter/material.dart';

import 'BackgroundDisplayEvent.dart';
import 'BackgroundDisplayState.dart';
import 'NotificationEvent.dart';
import 'OrderEvent.dart';
import 'OrderState.dart';


class OrderBloc extends Bloc<OrderEvent, OrderState> {
  int currentMove;
  final BuildContext context;
  OrderBloc(this.context){
    currentMove= 0;
  }

  @override
  OrderState get initialState => OrderUpToDate();

  @override
  Stream<OrderState> mapEventToState(OrderEvent event) async* {
    if (event is OrderMoveAdded && state is OrderUpToDate){
      if (event.move['lastMoveId'] == currentMove){
        currentMove = event.move['currentMoveId'];
        ResourceManager().backgroundDisplayBloc.scoreboardChanged=true;
        if (event.move['type']=='match') {
          insertAndDisplay(event.move);
          ResourceManager().notificationBloc.add(NotificationReceivedFromMatch(json:event.move));
          ResourceManager().keyManagerBloc.add(KeyManagerKeyMatch((await ResourceManager().assetRegistryManager.teamFromUserId(event.move["userId"]))['@TeamId'],event.move["userId"], event.move['keyId']));
        }
        else if (event.move['type']=='unmatch'){
          BackgroundDisplayBloc backgroundDisplayBloc = ResourceManager().backgroundDisplayBloc;
          unmatchDisplayNotify(backgroundDisplayBloc, event.move);
          if (event.move['userId'] == ResourceManager().user )ResourceManager().keyManagerBloc.add(KeyManagerKeyUnmatch(event.move['keyId']));

        }
      }
      else{
        this.add(OrderInconsistencyDetected());
      }
    }
    if (event is OrderInitialized){this.add(OrderInconsistencyDetected());}
    if (event is OrderConnectivityIssueDetected){
      this.add(OrderInconsistencyDetected());}

    if (event is OrderInconsistencyDetected && state is OrderUpToDate){
      yield(OrderUpdateInProcess());
      try{
      List lostMovesList = await ResourceManager().getPastMoves(currentMove);
      await lostMovesList.forEach((element) async {
          Map<String,dynamic> lostMove ={};
          lostMove['timestamp']=element[6].toString();
          lostMove['id']=element[0];
          lostMove['type']=element[1];
          lostMove['objectId']=element[2];
          lostMove['keyId']=element[3];
          lostMove['userId']=element[4];
          lostMove['currentMoveId']=-1;
          lostMove['lastMoveId']=-1;
          lostMove['position']=element[5];
          if (lostMove['type']=='match'){
            insertAndDisplay(lostMove);
            ResourceManager().notificationBloc.add(NotificationReceivedFromMatch(json:lostMove));
          } else if(lostMove['type']=='unmatch'){
            BackgroundDisplayBloc backgroundDisplayBloc = ResourceManager().backgroundDisplayBloc;
            await unmatchDisplayNotify(backgroundDisplayBloc, lostMove);
          }
      });
      if (lostMovesList.isNotEmpty) {
        currentMove=lostMovesList.last[0];
        ResourceManager().backgroundDisplayBloc.scoreboardChanged=true;
        ResourceManager().keyManagerBloc.add(KeyManagerSyncNeeded());
      }}
      on ErrorThrown catch(et){
        BlocProvider.of<ErrorBloc>(context).add(et);
      }
      yield(OrderUpToDate());
    }

  }

  Future<void> unmatchDisplayNotify(BackgroundDisplayBloc backgroundDisplayBloc, Map move) async{
    if (backgroundDisplayBloc.state is ObjectDisplayBuilt && move['objectId'] == backgroundDisplayBloc.state.props[3] && move['userId']==ResourceManager().user){
        backgroundDisplayBloc.add(BackgroundDisplayBecameOutdated(
        move['keyId'].toString(), move['position'],
        move['userId'] == ResourceManager().user, false,Colors.grey));
    }

    if ((await ResourceManager().teamFromUserId(move['userId']))['TeamName']==ResourceManager().teamName) ResourceManager().notificationBloc.add(NotificationReceivedFromUnmatch(json:move));
  }


  Future<void> insertAndDisplay(Map body) async {
    bool response = ResourceManager().gameState.insert(objectId: body['objectId'].toString(), keyId: body["keyId"].toString(), matchmaker: body["userId"].toString(),position: body["position"]);
    BackgroundDisplayBloc backgroundDisplayBloc = ResourceManager().backgroundDisplayBloc;
    if (backgroundDisplayBloc.state is ObjectDisplayBuilt && body['objectId']==backgroundDisplayBloc.state.props[3] && response) {
      Map team = await ResourceManager().teamFromUserId(body['userId']);
      backgroundDisplayBloc.add(BackgroundDisplayBecameOutdated(
          body['keyId'].toString(), body['position'],
          body['userId'] == ResourceManager().user, true,Color.fromRGBO(team['Color'][0], team['Color'][1], team['Color'][2], 0.8)));
    }
  }



}
