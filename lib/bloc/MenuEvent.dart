import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  List<Object> get props=>[];
}

class MenuOpen extends MenuEvent{}
class MenuClose extends MenuEvent{}
class MenuHide extends MenuEvent{}
class MenuShow extends MenuEvent{}
class MenuAnimationCompleted extends MenuEvent{}



