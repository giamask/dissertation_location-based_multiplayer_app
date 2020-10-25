import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/DragState.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:flutter/material.dart';
import 'AnimationBloc.dart';
import 'DragEvent.dart';
import 'DragState.dart';

class DragBloc extends Bloc<DragEvent,DragState>{
  final String objectId;
  DragBloc(this.objectId);

  AnimationBloc scoreChangeAnimation = AnimationBloc();

  @override
  Future<void> close(){
    scoreChangeAnimation?.close();
    return super.close();
  }


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
      yield DragFull(image:Image.asset("assets/k${event.props[0]}.jpg"),color:event.props[1]);
    }

  }

}


