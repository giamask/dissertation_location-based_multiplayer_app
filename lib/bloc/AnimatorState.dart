import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AnimatorState extends Equatable{
  const AnimatorState();

  @override
  List<Object> get props => [];
}

class MapView extends AnimatorState{}

class ObjectView extends AnimatorState{}

class AnimationInProgress extends AnimatorState{
  final String animationDirection;
  AnimationInProgress({@required this.animationDirection});
  List<Object> get props => [animationDirection];
}