import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

abstract class BackgroundDisplayEvent extends Equatable {
  const BackgroundDisplayEvent();

  List<Object> get props=>[];
}

class BackgroundDisplayChangedToObject extends BackgroundDisplayEvent{
  final String id;

  BackgroundDisplayChangedToObject({@required this.id});

  @override
  List<Object> get props=>[id];
}

class BackgroundDisplayChangedToScore extends BackgroundDisplayEvent{

  BackgroundDisplayChangedToScore();

  @override
  List<Object> get props=>[];
}

class BackgroundDisplayBecameOutdated extends BackgroundDisplayEvent{
  final String keyId;
  BackgroundDisplayBecameOutdated(this.keyId);
  @override
  List<Object> get props=>[keyId];
}


