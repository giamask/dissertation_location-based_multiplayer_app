
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';


abstract class ErrorEvent extends Equatable {
  const ErrorEvent();
}

class ErrorThrown extends ErrorEvent{
  final CustomError error;
  ErrorThrown(this.error);

  @override
  List<Object> get props => [error];

}

class ErrorFatalThrown extends ErrorEvent{
  final CustomError error;
  ErrorFatalThrown(this.error);

  @override
  List<Object> get props => [error];

}
@immutable
class CustomError extends Equatable implements Exception{

  final int id;
  final String message;
  final String origin;
  const CustomError({@required this.id,@required this.message,this.origin});

  @override
  List<Object> get props => [id,message];

}