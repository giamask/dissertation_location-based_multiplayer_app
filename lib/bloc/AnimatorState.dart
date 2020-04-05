import 'package:equatable/equatable.dart';

abstract class AnimatorState extends Equatable{
  const AnimatorState();

  @override
  List<Object> get props => [];
}

class Idle extends AnimatorState{}

class CameraMoveInProgress extends AnimatorState{}

class PopUpDisplay extends AnimatorState{}


