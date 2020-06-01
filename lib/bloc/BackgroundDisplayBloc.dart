import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/AnimationEvent.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayState.dart';
import 'package:diplwmatikh_map_test/bloc/DragEvent.dart';
import 'package:diplwmatikh_map_test/bloc/MenuBloc.dart';
import 'package:diplwmatikh_map_test/bloc/ResourceManager.dart';
import 'package:flutter/material.dart';
import '../GameState.dart';
import 'AnimationBloc.dart';
import 'DragBloc.dart';
import 'BackgroundDisplayEvent.dart';
import 'BackgroundDisplayState.dart';
import 'DragState.dart';

class BackgroundDisplayBloc extends Bloc<BackgroundDisplayEvent,BackgroundDisplayState>{

  //aquire the number of slot ( 3 for now)
  int slots = 3;
  //hardcode TODO


  final List<DragBloc> dragBlocList = [];

  @override
  Future<void> close() {
    dragBlocList.forEach((bloc)=>bloc?.close());
    return super.close();
  }


  @override
  BackgroundDisplayState get initialState => BackgroundDisplayUninitialized() ;

  @override
  Stream<BackgroundDisplayState> mapEventToState(BackgroundDisplayEvent event) async* {
    if (event is BackgroundDisplayChangedToObject) {
      yield BackgroundDisplayBuildInProgress();
      String id = event.props[0];
      Map json = jsonDecode(await ResourceManager().retrieveAssetRegistry());
      List jsonObjects = json["joumerka"]["ObjectList"];
      Map object = jsonObjects.firstWhere((element) {
        if (element["@ObjectId"] == id) return true;
        return false;
      });

      dropDragList(slots, id);
      fillDragList(id);


      Image image = await ResourceManager().retrieveImage(
          object["ObjectImage"]);
      yield ObjectDisplayBuilt(
        object["ObjectTitle"], object["ObjectDescription"], image,
        int.parse(id),);
    }
    if (event is BackgroundDisplayChangedToScore) {
      yield BackgroundDisplayBuildInProgress();
      //TODO retrieve and sort
      List<List> scoreboard = [
        [Colors.purple, "Team 1", 10],
        [Colors.black, "Team 2", 5],
        [Colors.yellow, "Team 3", 1],
        [Colors.teal, "Team 4", 1],
        [Colors.orange, "Team 5", 0]
      ];
      yield ScoreDisplayBuilt(scoreboard);
    }
    if (event is BackgroundDisplayBecameOutdated) {
      if (state is ObjectDisplayBuilt) {
          refreshDragList(event.correctPlacement,event.position,event.keyId);
          if (event.triggeredByFriendlyUser) animateChange(event.position,event.correctPlacement);
      }
    }
  }

  void dropDragList(int slots, String id){
    dragBlocList.forEach((bloc){bloc.close();});
    dragBlocList.removeWhere((element){return true;});
    for (int i=0;i<slots;i++) dragBlocList.add(new DragBloc(id));

  }

  void fillDragList(String id){
    List<dynamic> keyMatch = ResourceManager().readFromGameState(objectId: id);
    for (int i=0;i<keyMatch.length;i++){
      KeyMatch currKey = keyMatch[i] as KeyMatch;
      dragBlocList[currKey.position].add(DragResponsePositive(keyId: currKey.keyId));
    }
  }

  void refreshDragList(bool correctPlacement, int position,String keyId){
    dragBlocList[position].add(correctPlacement?DragResponsePositive(keyId:keyId):DragResponseNegative());
  }

  void animateChange(int position, bool correctPlacement){
    dragBlocList[position].scoreChangeAnimation.add(AnimationStartRequested(correctPlacement,position));
  }
}


