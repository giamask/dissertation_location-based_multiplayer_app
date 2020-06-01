import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

abstract class AnimationEvent extends Equatable {
  const AnimationEvent();

  List<Object> get props=>[];
}

class AnimationStartRequested extends AnimationEvent{
  final bool correct;
  final int position;

  AnimationStartRequested(this.correct, this.position);

  List<Object> get props => [correct,position];
}
class AnimationEnded extends AnimationEvent{
  final bool reset;

  AnimationEnded(this.reset);

  List<Object> get props => [reset];
}


