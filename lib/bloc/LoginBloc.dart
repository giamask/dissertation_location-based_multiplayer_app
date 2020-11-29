import 'dart:async';

import 'package:bloc/bloc.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
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
        this.add(LoginDeauthorized());
      }else{
        this.add(LoginAuthorized(event.user));
      }
    }
    if (event is LoginAuthorized){
      await preController.reverse().then((value) => null);
      Completer<List<Map>> sessionsRequest = Completer();
      yield(UserLoggedIn(sessionsRequest));
      sessionsRequest.complete(await ResourceManager().getSessions(event.user.email??event.user.phoneNumber).timeout(Duration(seconds: 7),onTimeout: (){
        //TODO error handling
        return [];
      }));
      await sessionsRequest.future;
      postController.forward();
    }
    if (event is LoginDeauthorized){
      await postController.reverse().then((value) => null);
      yield(UserLoggedOut());
      preController.forward();
    }

  }
}
