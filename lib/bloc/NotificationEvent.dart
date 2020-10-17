import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  List<Object> get props=>[];
}


class NotificationReceived extends NotificationEvent{

}

class NotificationListOpened extends NotificationEvent{

}

class NotificationListClosed extends NotificationEvent{

}

class NotificationDeleted extends NotificationEvent{

}


class NotificationFullMessageReceived extends NotificationEvent{
  final String keyId;
  NotificationFullMessageReceived({@required this.keyId});

  @override
  List<Object> get props=>[keyId];
}



