
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
abstract class ObjDisplayState extends Equatable {
  List<Object> get props => [];
}

class ObjDisplayUninitialized extends ObjDisplayState {
  ObjDisplayUninitialized();
  @override
  List<Object> get props =>[];
}

class ObjDisplayBuildInProgress extends ObjDisplayState{
  ObjDisplayBuildInProgress();
  @override
  List<Object> get props =>[];

}

class ObjDisplayBuilt extends ObjDisplayState{
  final String title;
  final String desc;
  final Image image;


  ObjDisplayBuilt(this.title, this.desc, this.image);

  @override
  List<Object> get props =>[title,desc,image];

}





