

import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginInitial extends LoginState {
  @override
  List<Object> get props => [];
}


class UserLoggedOut extends LoginState {
  @override
  List<Object> get props => [];
}

class UserLoggedIn extends LoginState {
  final Completer<List<Map>> sessionsRequest;

  UserLoggedIn(this.sessionsRequest);
  @override
  List<Object> get props => [sessionsRequest];
}