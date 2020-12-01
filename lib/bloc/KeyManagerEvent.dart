import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class KeyManagerEvent extends Equatable {
  const KeyManagerEvent();
  List<Object> get props=>[];
}

class KeyManagerKeyMatch extends KeyManagerEvent{
  final int matchingTeam;
  final String matchingPlayer;
  final int keyId;

  KeyManagerKeyMatch(this.matchingTeam, this.matchingPlayer, this.keyId);

  @override
  List<Object> get props => [matchingTeam,matchingPlayer,keyId,];
}

class KeyManagerKeyUnmatch extends KeyManagerEvent{

  final int keyId;

  KeyManagerKeyUnmatch(this.keyId);

  @override
  List<Object> get props => [keyId,];
}

class KeyManagerListInitialization extends KeyManagerEvent{}

class KeyManagerSyncNeeded extends KeyManagerEvent{
  final int team=0 ;
  @override
  List<Object> get props => [team];
}

class KeyManagerCommit extends KeyManagerEvent{
  final int keyId ;

  KeyManagerCommit(this.keyId);
  @override
  List<Object> get props => [keyId];
}



