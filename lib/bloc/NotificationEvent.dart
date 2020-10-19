import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  List<Object> get props=>[];
}


class NotificationReceivedFromMatch extends NotificationEvent{
  final Map<String,dynamic> json;
  NotificationReceivedFromMatch({@required this.json});

  @override
  List<Object> get props=>[json];
}
class NotificationReceivedFromUnmatch extends NotificationEvent{
  final Map<String,dynamic> json;
  NotificationReceivedFromUnmatch({@required this.json});

  @override
  List<Object> get props=>[json];
}
class NotificationReceivedFromAdmin extends NotificationEvent{
  final String text;
  final String timestamp;
  NotificationReceivedFromAdmin({@required this.text,@required this.timestamp});

  @override
  List<Object> get props=>[text,timestamp];
}

class NotificationTrayOpened extends NotificationEvent{

}

class NotificationTrayClosed extends NotificationEvent{

}

class NotificationDeleted extends NotificationEvent{
  final int index;
  NotificationDeleted(this.index);

  @override
  List<Object> get props=>[index];
}



