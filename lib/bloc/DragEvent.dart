import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class DragEvent extends Equatable {
  const DragEvent();

  List<Object> get props=>[];
}



class DragCommitted extends DragEvent{
  final String keyId;
  DragCommitted({@required this.keyId});
  @override
  List<Object> get props=>[keyId];
}

class DragResponsePositive extends DragEvent{
  final String keyId;
  DragResponsePositive({@required this.keyId});
  @override
  List<Object> get props=>[keyId];
}

class DragResponseNegative extends DragEvent{}
class DragResponseTimeout extends DragEvent{}

class DragFullMessageReceived extends DragEvent{
  final String keyId;
  DragFullMessageReceived({@required this.keyId});

  @override
  List<Object> get props=>[keyId];
}



