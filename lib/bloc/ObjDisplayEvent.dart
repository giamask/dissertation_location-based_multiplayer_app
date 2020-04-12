import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

abstract class ObjDisplayEvent extends Equatable {
  const ObjDisplayEvent();

  List<Object> get props=>[];
}

class ObjDisplayChanged extends ObjDisplayEvent{
  final String id;

  ObjDisplayChanged({@required this.id});

  @override
  List<Object> get props=>[id];
}



