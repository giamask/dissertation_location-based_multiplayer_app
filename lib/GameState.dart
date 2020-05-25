import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
class GameState {
  Map<String,dynamic> objectsJson;
  Map matchStatus={};
  int lastKnownMoveId=0;


  GameState(this.objectsJson){
    List<dynamic> objectList = objectsJson["joumerka"]["ObjectList"];
    objectList.forEach((object){
      matchStatus.addAll({object['@ObjectId']:[]});
    });
  }

  bool insert({@required String objectId, @required String keyId,@required String matchmaker}){
    List<dynamic> matchList = matchStatus[objectId];
    if (matchList.any((element)=>(element.keyId==keyId))) return false;
    matchList.add(KeyMatch(keyId,matchmaker));
    return true;
  }

  List<dynamic> read({@required String objectId}){return matchStatus[objectId];}

  void delete({@required String objectId, @required String keyId}){
    matchStatus[objectId] as List<KeyMatch>..removeWhere((element){
      return element.keyId ==keyId;
    });
  }

  void printAll(){
    matchStatus.forEach((key,element){
      print("object:" + key.toString());
      element.forEach((keyMatch){
        print( "key:" + keyMatch.keyId +" matchmaker:" +  keyMatch.matchmaker);
      });
    });
  }

}


class KeyMatch {

  final String _keyId;
  final String _matchmaker;

  KeyMatch(this._keyId, this._matchmaker);

  String get keyId => _keyId;
  String get matchmaker => _matchmaker;
}