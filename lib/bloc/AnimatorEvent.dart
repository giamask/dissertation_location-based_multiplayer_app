import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class AnimatorEvent extends Equatable {
  const AnimatorEvent();

  List<Object> get props=>[];
}

class AnimatorMapShrunk extends AnimatorEvent{}
class AnimatorMapExpanded extends AnimatorEvent{}


