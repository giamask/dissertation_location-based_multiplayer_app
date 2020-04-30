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

  DragRequestInProgress();

  @override
  List<Object> get props =>[];

}

class DragFull extends DragState{
  final Image image;
  DragFull({@required this.image});

  @override
  List<Object> get props =>[image];

}




