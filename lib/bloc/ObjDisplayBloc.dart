import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/ObjDisplayState.dart';
import 'package:diplwmatikh_map_test/bloc/ResourceManager.dart';
import 'package:flutter/material.dart';
import 'ObjDisplayEvent.dart';
import 'ObjDisplayState.dart';

class ObjDisplayBloc extends Bloc<ObjDisplayEvent,ObjDisplayState>{


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
      Image image = await ResourceManager().retrieveImage(object["ObjectImage"]);
      yield ObjDisplayBuilt(object["ObjectTitle"],object["ObjectDescription"],image);
    }
  }

}


