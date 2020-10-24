import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class DragEvent extends Equatable {
  const DragEvent();

  List<Object> get props=>[];
}



class DragCommitted extends DragEvent{
  final String keyId;
  final int position;
  DragCommitted({@required this.keyId,@required this.position});
  @override
  List<Object> get props=>[keyId,position];
}

class DragResponsePositive extends DragEvent{
  final String keyId;
  final Color color;
  DragResponsePositive({@required this.keyId,@required this.color});
  @override
  List<Object> get props=>[keyId,color];
}

class DragResponseNegative extends DragEvent{}
class DragResponseTimeout extends DragEvent{}

class DragFullMessageReceived extends DragEvent{
  final Color color;
  final String keyId;
  DragFullMessageReceived({@required this.keyId,@required this.color});

  @override
  List<Object> get props=>[keyId,color];
}



