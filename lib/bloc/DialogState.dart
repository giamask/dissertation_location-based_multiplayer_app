
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
abstract class DialogState {
  List<Object> get props => [];
}

class Ready extends DialogState{
  final List<Object> properties;

  Ready({@required this.properties});

  @override
  List<Object> get props => properties;
}

class LoadingImage extends DialogState{}


