import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class AnimatorEvent extends Equatable {
  const AnimatorEvent();

  List<Object> get props=>[];
}

class MarkerTap extends AnimatorEvent{
  final String objectId;

  const MarkerTap({@required this.objectId});
}

class PopUpDismiss extends AnimatorEvent{}



