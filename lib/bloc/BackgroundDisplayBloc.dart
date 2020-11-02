import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/AnimationEvent.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayState.dart';
import 'package:diplwmatikh_map_test/bloc/DragEvent.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ErrorBloc.dart';
import 'ErrorEvent.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:flutter/material.dart';
import '../GameState.dart';
import 'DragBloc.dart';
import 'BackgroundDisplayEvent.dart';
import 'BackgroundDisplayState.dart';

class BackgroundDisplayBloc extends Bloc<BackgroundDisplayEvent,BackgroundDisplayState>{

  //aquire the number of slot ( 3 for now)
  int slots = 3;
  //hardcode TODO
  final BuildContext context;


  List<List> scoreboard = [];
  bool scoreboardChanged=true;
  final List<DragBloc> dragBlocList = [];


  @override
  Future<void> close() {
    dragBlocList.forEach((bloc)=>bloc?.close());
    return super.close();
  }

  BackgroundDisplayBloc(this.context);
  @override
  BackgroundDisplayState get initialState => BackgroundDisplayUninitialized() ;

  @override
  Stream<BackgroundDisplayState> mapEventToState(BackgroundDisplayEvent event) async* {
    if (event is BackgroundDisplayChangedToObject) {
      yield BackgroundDisplayBuildInProgress();
      String id = event.props[0];
      Map json = jsonDecode(await ResourceManager().retrieveAssetRegistry());
      List jsonObjects = json["joumerka"]["ObjectList"];
      Map object;
      try {
        object = jsonObjects.firstWhere((element) {
          if (element["@ObjectId"] == id) return true;
          return false;
        });
      }
      on StateError{
        BlocProvider.of<ErrorBloc>(context).add(ErrorThrown(CustomError(id: 21,
            message: "Αλλοιωμένο αρχείο παιχνιδιού.")));
      }
      dropDragList(slots, id);
      await fillDragList(id);
      Image image;
      try {
        image = await ResourceManager().getImage(
            object["ObjectImage"]);
      }
      on ErrorThrown catch (et){
        image = Image.asset("assets/placeholder_image.png");
        BlocProvider.of<ErrorBloc>(context).add(et);
      }
      yield ObjectDisplayBuilt(
        object["ObjectTitle"], object["ObjectDescription"], image,
        int.parse(id),);
    }
    if (event is BackgroundDisplayChangedToScore) {
      yield BackgroundDisplayBuildInProgress();
      //TODO rebuild on change
      if (scoreboardChanged) {
        try {
          List scoreList = await ResourceManager().getScore();
          Map assetRegistry = jsonDecode(
              await ResourceManager().retrieveAssetRegistry());
          scoreboard = [];
          scoreList.forEach((teamElement) {
            var teamId = teamElement[0];
            Map team = (assetRegistry['joumerka']['Teams'] as List).firstWhere((
                element) => element['@TeamId'] == teamId);
            var score = teamElement[1].toString();
            scoreboard.add([
              Color.fromRGBO(
                  team['Color'][0], team['Color'][1], team['Color'][2], 1),
              team['TeamName'],
              score
            ]);
          });
        }
        on ErrorThrown catch (et){
          BlocProvider.of<ErrorBloc>(context).add(et);
        }
      }
      yield ScoreDisplayBuilt(scoreboard);
    }
    if (event is BackgroundDisplayBecameOutdated) {
      if (state is ObjectDisplayBuilt) {
          refreshDragList(event.correctPlacement,event.position,event.keyId,event.color);
          if (event.triggeredByFriendlyUser) animateChange(event.position,event.correctPlacement);
      }
    }
  }

  void dropDragList(int slots, String id){
    dragBlocList.forEach((bloc){bloc.close();});
    dragBlocList.removeWhere((element){return true;});
    for (int i=0;i<slots;i++) dragBlocList.add(new DragBloc(id,context));

  }

  Future<void> fillDragList(String id) async {
    List<dynamic> keyMatch = ResourceManager().readFromGameState(objectId: id);
    for (int i=0;i<keyMatch.length;i++){
      KeyMatch currKey = keyMatch[i] as KeyMatch;
      Map team = await ResourceManager().teamFromUserId(currKey.matchmaker);
      dragBlocList[currKey.position].add(DragResponsePositive(keyId: currKey.keyId,color:Color.fromRGBO(team['Color'][0], team['Color'][1], team['Color'][2], 0.85)));
    }
  }

  void refreshDragList(bool correctPlacement, int position,String keyId,Color color){
    dragBlocList[position].add(correctPlacement?DragResponsePositive(keyId:keyId,color: color):DragResponseNegative());
  }

  void animateChange(int position, bool correctPlacement){
    dragBlocList[position].scoreChangeAnimation.add(AnimationStartRequested(correctPlacement,position));
  }
}


