import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'AnimationBloc.dart';

import 'NotificationEvent.dart';
import 'NotificationState.dart';

class NotificationBloc extends Bloc<NotificationEvent,NotificationState>{
  final notificationListKey = GlobalKey<AnimatedListState>();

  @override
  Future<void> close(){
    return super.close();
  }


  @override
  NotificationState get initialState =>  NotificationTrayRead();

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async*{


  }

}


