import 'package:equatable/equatable.dart';

abstract class InitState extends Equatable{
  @override
  List<Object> get props => [];
}

class InitializeInProgress extends InitState{}

class Initialized extends InitState{}



