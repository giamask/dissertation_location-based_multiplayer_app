import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
abstract class DragState extends Equatable {
  List<Object> get props => [];
}



class DragEmpty extends DragState{

  DragEmpty();

  @override
  List<Object> get props =>[];

}

class DragIndicator extends DragState{

  DragIndicator();

  @override
  List<Object> get props =>[];

}

class DragRequestInProgress extends DragState{
  final int keyId;
  DragRequestInProgress({this.keyId});

  @override
  List<Object> get props =>[keyId];

}

class DragFull extends DragState{
  final Image image;
  final Color color;
  DragFull({@required this.image,@required this.color});

  @override
  List<Object> get props =>[image,color];

}





