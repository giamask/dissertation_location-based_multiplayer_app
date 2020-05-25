
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
abstract class MenuState {
  List<Object> get props => [];
}

class MenuClosed extends MenuState{}

class MenuOpened extends MenuState{}

class MenuHidden extends MenuState{}
class MenuOpening extends MenuState{}
class MenuClosing extends MenuState{}


