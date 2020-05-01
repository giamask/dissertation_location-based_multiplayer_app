
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


  ObjectDisplayBuilt(this.title, this.desc, this.image);

  @override
  List<Object> get props =>[title,desc,image];

}

class ScoreDisplayBuilt extends BackgroundDisplayState{
  final  List<List> scoreboard;
  ScoreDisplayBuilt(this.scoreboard);
  @override
  List<Object> get props =>[scoreboard];
}





