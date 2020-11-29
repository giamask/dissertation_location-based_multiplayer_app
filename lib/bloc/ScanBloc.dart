import 'dart:async';

import 'package:bloc/bloc.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ErrorBloc.dart';
import 'ErrorEvent.dart';
import 'ScanEvent.dart';
import 'ScanState.dart';



class ScanBloc extends Bloc<ScanEvent, ScanState> {
  bool cheatMode = false;
  bool timedMode = false;
  final BuildContext context;
  ScanBloc(this.context){
    cheatMode = ResourceManager().cheatMode;
  }

  @override
  ScanState get initialState {

    return ScanInitial();
  }

  @override
  Stream<ScanState> mapEventToState(
    ScanEvent event,
  ) async* {
    if (event is ScanInitialized){
      yield(ScanUpdateSuccess(await ResourceManager().getScans()));
    }
    if (event is ScanExecuted && state is ScanUpdateSuccess){
      try{
      await ResourceManager().addScan(objectId: event.scan.objectId,dateTime: event.scan.timestamp);
      List<Scan> newScanList = [...state.props];
      newScanList.removeWhere((element) => element.objectId==event.scan.objectId);
      newScanList.add(event.scan);
      yield(ScanUpdateSuccess(newScanList));
      }
      on ErrorThrown catch (et){
        BlocProvider.of<ErrorBloc>(context).add(et);
      }
    }
  }

  bool isAvailable(int objectId){
     if (cheatMode) return true;
     if (state is ScanUpdateSuccess){
       Scan scan = (state.props.firstWhere((element) {
         return (element as Scan).objectId == objectId;
       },orElse: ()=> null)) ;
       if (scan==null) return false;

       Duration duration = DateTime.now().difference(scan.timestamp);
       if (duration.compareTo(Duration(seconds: 20))>0 && timedMode) return false;
       return true;
     }
     return false;
  }
}


class Scan extends Equatable{
  final int objectId;
  final DateTime timestamp;

  Scan(this.objectId, this.timestamp);

  @override
  List<Object> get props => [objectId,timestamp];

}