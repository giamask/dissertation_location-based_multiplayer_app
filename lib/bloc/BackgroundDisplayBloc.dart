import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayState.dart';
import 'package:diplwmatikh_map_test/bloc/ResourceManager.dart';
import 'package:flutter/material.dart';
import 'DragBloc.dart';
import 'BackgroundDisplayEvent.dart';
import 'BackgroundDisplayState.dart';

class BackgroundDisplayBloc extends Bloc<BackgroundDisplayEvent,BackgroundDisplayState>{

  final List<DragBloc> dragBlocList = [];
  @override
  BackgroundDisplayState get initialState => BackgroundDisplayUninitialized() ;

  @override
  Stream<BackgroundDisplayState> mapEventToState(BackgroundDisplayEvent event) async*{
    if (event is BackgroundDisplayChangedToObject){
      yield BackgroundDisplayBuildInProgress();
      String id=event.props[0];
      Map json = jsonDecode(await ResourceManager().retrieveAssetRegistry());
      List jsonObjects = json["joumerka"]["ObjectList"];
      Map object=jsonObjects.firstWhere((element) {
        if (element["@ObjectId"] == id) return true;
        return false;
      });

      //aquire the number of slot ( 3 for now)
      int slots = 3;
      //hardcode

      dragBlocList.forEach((bloc){bloc.close();});
      dragBlocList.removeWhere((element){return true;});

      for (int i=0;i<slots;i++) dragBlocList.add(new DragBloc());

      Image image = await ResourceManager().retrieveImage(object["ObjectImage"]);
      yield ObjectDisplayBuilt(object["ObjectTitle"],object["ObjectDescription"],image);
    }
    if (event is BackgroundDisplayChangedToScore){
      yield BackgroundDisplayBuildInProgress();
      //TODO retrieve and sort
      List<List> scoreboard = [[Colors.purple,"Team 1",10],[Colors.black,"Team 2",5],[Colors.yellow,"Team 3",1],[Colors.teal,"Team 4",1],[Colors.orange,"Team 5",0]];
      yield ScoreDisplayBuilt(scoreboard);

    }
  }

}


