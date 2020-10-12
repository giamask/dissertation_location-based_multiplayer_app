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

class KeyManagerListInitialization extends KeyManagerEvent{}





