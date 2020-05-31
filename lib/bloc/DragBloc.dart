import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/DragState.dart';
import 'package:diplwmatikh_map_test/bloc/ResourceManager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'DragEvent.dart';
import 'DragState.dart';

class DragBloc extends Bloc<DragEvent,DragState>{
  final String objectId;
  DragBloc(this.objectId);

  @override
  DragState get initialState =>  DragEmpty();

  @override
  Stream<DragState> mapEventToState(DragEvent event) async*{
    if (event is DragCommitted){
      ResourceManager().addMove(objectId: int.parse(objectId), keyId: int.parse(event.props[0]), type: "match", position: event.props[1]);
      yield DragRequestInProgress(keyId: int.parse(event.props[0]));

    }else if (event is DragResponseNegative){
      //logic
      yield DragEmpty();
    }else if (event is DragResponseTimeout){
      //popup
      yield DragEmpty();
    }
    else if (event is DragResponsePositive || event is DragFullMessageReceived){
      //keyfetchbasedonId
      print("k${event.props[0]}.jpg");
      yield DragFull(image:Image.asset("assets/k${event.props[0]}.jpg"));
    }

  }

}


