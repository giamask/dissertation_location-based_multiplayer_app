import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';

import 'LoginEvent.dart';
import 'LoginState.dart';



class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AnimationController preController;
  AnimationController postController;

  @override
  get initialState => LoginInitial();


  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoginInitialized && state is LoginInitial){
      preController = event.preController;
      postController = event.postController;
      if (event.user==null){
        yield(UserLoggedOut());
        preController.forward();
      }else{
        yield(UserLoggedIn());
        postController.forward();
      }
    }

    if (event is LoginAuthorized){
      await preController.reverse().then((value) => "");
      yield(UserLoggedIn());
      postController.forward();
    }

    if (event is LoginDeauthorized){
      await postController.reverse().then((value) => null);
      yield(UserLoggedOut());
      preController.forward();
    }

  }
}
