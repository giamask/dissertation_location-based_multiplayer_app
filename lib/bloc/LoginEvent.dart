

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginInitialized extends LoginEvent {

  final User user;
  final AnimationController preController;
  final AnimationController postController;

  LoginInitialized(this.user, this.preController, this.postController);
  @override
  List<Object> get props => [user];
}

class LoginAuthorized extends LoginEvent {

  final User user;

  LoginAuthorized(this.user);
  @override
  List<Object> get props => [user];
}

class LoginDeauthorized extends LoginEvent {

  LoginDeauthorized();
  @override
  List<Object> get props => [];
}