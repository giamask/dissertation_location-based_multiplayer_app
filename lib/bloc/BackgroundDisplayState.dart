
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
abstract class BackgroundDisplayState extends Equatable {
  List<Object> get props => [];
}

class BackgroundDisplayUninitialized extends BackgroundDisplayState {
  BackgroundDisplayUninitialized();
  @override
  List<Object> get props =>[];
}

class BackgroundDisplayBuildInProgress extends BackgroundDisplayState{
  BackgroundDisplayBuildInProgress();
  @override
  List<Object> get props =>[];

}

class ObjectDisplayBuilt extends BackgroundDisplayState{
  final String title;
  final String desc;
  final Image image;
  final int objectId;


  ObjectDisplayBuilt(this.title, this.desc, this.image,this.objectId,);

  @override
  List<Object> get props =>[title,desc,image,objectId];

}

class ScoreDisplayBuilt extends BackgroundDisplayState{
  final  List<List> scoreboard;
  ScoreDisplayBuilt(this.scoreboard);
  @override
  List<Object> get props =>[scoreboard];
}





