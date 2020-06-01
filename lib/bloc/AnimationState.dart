import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';

abstract class AnimationState extends Equatable{
  const AnimationState();

  @override
  List<Object> get props => [];
}

class AnimationComplete extends AnimationState{}

class AnimationInProgress extends AnimationState{
  final bool correct;
  final int position;

  AnimationInProgress(this.correct, this.position);

  List<Object> get props => [correct,position];
}

class AnimationPause extends AnimationState{}
class AnimationStart extends AnimationState{}
class AnimationNotStarted extends AnimationState{}

