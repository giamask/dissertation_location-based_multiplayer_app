import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/ObjDisplayState.dart';
import 'package:diplwmatikh_map_test/bloc/ResourceManager.dart';
import 'package:flutter/material.dart';
import 'DragBloc.dart';
import 'ObjDisplayEvent.dart';
import 'ObjDisplayState.dart';

class ObjDisplayBloc extends Bloc<ObjDisplayEvent,ObjDisplayState>{

  final List<DragBloc> dragBlocList = [];
  @override
  ObjDisplayState get initialState => ObjDisplayUninitialized() ;

  @override
  Stream<ObjDisplayState> mapEventToState(ObjDisplayEvent event) async*{
    if (event is ObjDisplayChanged){
      yield ObjDisplayBuildInProgress();
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
      yield ObjDisplayBuilt(object["ObjectTitle"],object["ObjectDescription"],image);
    }
  }

}


