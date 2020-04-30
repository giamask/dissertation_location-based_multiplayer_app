import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/DragState.dart';
import 'package:diplwmatikh_map_test/bloc/ResourceManager.dart';
import 'package:flutter/material.dart';
import 'DragEvent.dart';
import 'DragState.dart';

class DragBloc extends Bloc<DragEvent,DragState>{


  @override
  DragState get initialState =>  DragEmpty();

  @override
  Stream<DragState> mapEventToState(DragEvent event) async*{
    if (event is DragCommitted){
      yield DragRequestInProgress();
      //make request
      // wait for response
      String response = "positive";
      if (response=="positive"){
        this.add(DragResponsePositive(keyId: event.keyId));
      }else if (response == "timeout"){
        this.add(DragResponseTimeout());
      }
      else{
        this.add(DragResponseNegative());
      }
      //add response as event

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


