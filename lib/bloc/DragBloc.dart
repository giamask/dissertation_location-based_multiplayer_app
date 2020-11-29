import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/DragState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ErrorBloc.dart';
import 'ErrorEvent.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:flutter/material.dart';
import 'AnimationBloc.dart';
import 'DragEvent.dart';
import 'DragState.dart';

class DragBloc extends Bloc<DragEvent,DragState>{
  final String objectId;
  final BuildContext context;
  DragBloc(this.objectId,this.context);

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
      try {

        await ResourceManager().addMove(objectId: int.parse(objectId),
            keyId: int.parse(event.props[0]),
            type: "match",
            position: event.props[1]);
        startTimeoutTimer();
        yield DragRequestInProgress(keyId: int.parse(event.props[0]));
      }
      on ErrorThrown catch (et){
        BlocProvider.of<ErrorBloc>(context).add(et);
        yield(DragEmpty());
      }

    }else if (event is DragResponseNegative){
      //logic
      yield DragEmpty();
    }else if (event is DragResponseTimeout){
      BlocProvider.of<ErrorBloc>(context).add(ErrorThrown(CustomError(id: 50,
          message: "Δεν υπήρξε απάντηση απο τον server. Ελέγξτε την σύνδεση σας στο internet.")));
      yield DragEmpty();
    }
    else if (event is DragResponsePositive || event is DragFullMessageReceived){
      try {
        Image image = await ResourceManager().getImage(
            "k" + (event.props[0] as String) + ".jpg");
        yield DragFull(image: image, color: event.props[1]);
      }
      on ErrorThrown{
        startImageTimer(event);
      }
    }

  }

  void startTimeoutTimer() async{
    await Future.delayed(Duration(seconds: 10));
    if (this.state is DragRequestInProgress){
      this.add(DragResponseTimeout());
    }
  }
  void startImageTimer(DragEvent event) async{
    await Future.delayed(Duration(seconds: 10));
    this.add(event);
  }

}


