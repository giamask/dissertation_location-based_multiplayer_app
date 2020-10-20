import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
abstract class NotificationState extends Equatable {
  List<Object> get props => [];
}


class NotificationTrayRead extends NotificationState{}
class NotificationTrayUnread extends NotificationState{}


class NotificationRequestInProgress extends NotificationState{
  final int keyId;
  NotificationRequestInProgress({this.keyId});

  @override
  List<Object> get props =>[keyId];

}






