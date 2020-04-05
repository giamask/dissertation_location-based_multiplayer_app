import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class InitEvent extends Equatable {
  const InitEvent();

  List<Object> get props=>[];
}

class GameInitialized extends InitEvent{}





