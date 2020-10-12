
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
abstract class KeyManagerState {
  List<Object> get props => [];
}

class KeyManagerListUpdated extends KeyManagerState{
}

class KeyManagerUninitialized extends KeyManagerState{}

class KeyManagerListUpdateInProgress extends KeyManagerState{}


