import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/DragState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ErrorBloc.dart';
import 'ErrorEvent.dart';
import 'KeyManagerBloc.dart';
import 'KeyManagerEvent.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:flutter/material.dart';
import 'AnimationBloc.dart';
import 'DragEvent.dart';
import 'DragState.dart';

class DragBloc extends Bloc<DragEvent,DragState>{
  final String objectId;
  final BuildContext context;
  final KeyManagerBloc keyManagerBloc;
  DragTimer dragTimer ;

  DragBloc(this.objectId,this.context, this.keyManagerBloc){
    dragTimer = DragTimer(this);
  }

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
        keyManagerBloc.add(KeyManagerCommit(int.parse(event.props[0])));
        ResourceManager().addMove(objectId: int.parse(objectId),
            keyId: int.parse(event.props[0]),
            type: "match",
            position: event.props[1]);
        dragTimer.startTimer();
        yield DragRequestInProgress(keyId: int.parse(event.props[0]));
      }
      on ErrorThrown catch (et){
        BlocProvider.of<ErrorBloc>(context).add(et);
        yield(DragEmpty());
      }

    }else if (event is DragResponseNegative){
      dragTimer.stopTimer();
      yield DragEmpty();
    }else if (event is DragResponseTimeout){
      BlocProvider.of<ErrorBloc>(context).add(ErrorThrown(CustomError(id: 50,
          message: "Δεν υπήρξε απάντηση απο τον server. Ελέγξτε την σύνδεση σας στο internet.")));
      keyManagerBloc.add(KeyManagerKeyUnmatch(state.props[0]));
      yield DragEmpty();
    }
    else if (event is DragResponsePositive || event is DragFullMessageReceived){
      dragTimer.stopTimer();
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

  void startImageTimer(DragEvent event) async{
    await Future.delayed(Duration(seconds: 10));
    this.add(event);
  }

}

class DragTimer {
  Timer timer;
  DragBloc dragBloc;
  DragTimer(this.dragBloc);

  void startTimer() async{
    timer = Timer(Duration(seconds: 10),(){
      dragBloc.add(DragResponseTimeout());
    });
  }

  void stopTimer() async{
    timer?.cancel();
  }

}


