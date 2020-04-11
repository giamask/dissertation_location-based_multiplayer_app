import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
abstract class InitState extends Equatable{
  @override
  List<Object> get props => [];
}

class InitializeInProgress extends InitState{}

class Initialized extends InitState{
  final Completer<GoogleMapController> controller ;
  final Set<Marker> markers;

  Initialized({@required this.markers,@required this.controller});

  @override
  List<Object> get props => [markers, controller];

}


