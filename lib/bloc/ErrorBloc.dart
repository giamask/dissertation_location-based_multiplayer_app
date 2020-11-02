import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

import 'ErrorEvent.dart';
import 'ErrorState.dart';

class ErrorBloc extends Bloc<ErrorEvent, ErrorState> {
  BuildContext context;
  ErrorBloc(this.context);

  @override
  Stream<ErrorState> mapEventToState(
    ErrorEvent event,
  ) async* {
    if (event is ErrorThrown){
      Toast.show("Σφάλμα ${event.error.id}: ${event.error.message}", context,duration: 5);
    }
    if (event is ErrorFatalThrown){
      Toast.show("Σφάλμα ${event.error.id}: ${event.error.message}", context,duration: 5);
      await Future.delayed(Duration(seconds: 5));
      SystemNavigator.pop();
    }
  }

  @override
  get initialState => ErrorInitial();
}
