import 'package:equatable/equatable.dart';

abstract class AnimatorState extends Equatable{
  const AnimatorState();

  @override
  List<Object> get props => [];
}

class MapView extends AnimatorState{}

class ObjectView extends AnimatorState{}

