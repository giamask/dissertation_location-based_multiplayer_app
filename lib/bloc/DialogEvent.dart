import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

abstract class DialogEvent extends Equatable {
  const DialogEvent();

  List<Object> get props=>[];
}

class MarkerTap extends DialogEvent{
  final String id;
  final String name;
  final List<bool> matches;
  final String imagePath;
  final List<Color> colors;

  MarkerTap({@required this.id, @required this.name, @required this.matches,@required this.imagePath,@required this.colors});

  @override
  List<Object> get props=>[id,name,matches,imagePath,colors];
}



