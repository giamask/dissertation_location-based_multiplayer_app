import 'dart:convert';

import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:flutter/material.dart';

import '../KeyListTile.dart';
import 'KeyManagerEvent.dart';
import "KeyManagerState.dart";
import 'package:flutter_bloc/flutter_bloc.dart';

class KeyManagerBloc extends Bloc<KeyManagerEvent, KeyManagerState> {
  KeyManagerBloc();
  final animatedListKey = GlobalKey<AnimatedListState>();
  List<int> keyList = [];
  List<int> committedKeys = [];
  List<KeyListTile> tileList = [];

  @override
  Future<void> close() {
    return super.close();
  }

  @override
  KeyManagerState get initialState => KeyManagerUninitialized();

  @override
  Stream<KeyManagerState> mapEventToState(KeyManagerEvent event) async* {
    if (event is KeyManagerKeyUnmatch){
      if (!(committedKeys.contains(event.keyId))) return;
      keyList.insert(0, event.keyId);
      tileList.insert(0,KeyListTile(event.keyId));
      animatedListKey.currentState.insertItem(0,duration: Duration(milliseconds: 700));
      committedKeys.remove(event.keyId);
      await Future.delayed(Duration(seconds: 1));
    }
    if (((event is KeyManagerKeyMatch && (keyList.contains(event.props[2]) || committedKeys.contains(event.props[2]))) || (event is KeyManagerSyncNeeded))
        && !(state is KeyManagerUninitialized)) {
      yield(KeyManagerListUpdateInProgress());
      List<int> newKeyList = await ResourceManager().getKeys();
      List<int> elementsToRemoveList = keyList.where((element) => !newKeyList.contains(element)).toList();
      List<int> elementsToAddList = newKeyList.where((element) => !keyList.contains(element)).toList();
      //care for committed keys
      if (event is KeyManagerKeyMatch && committedKeys.contains(event.props[2])){
        committedKeys.remove(event.props[2]);
      }else{
        committedKeys.forEach((element){
          elementsToRemoveList.remove(element);
        });
      }
      // removing items from the list
      elementsToRemoveList.sort((a, b) => elementsToRemoveList.indexOf(b) - elementsToRemoveList.indexOf(a));
      List<int> tempIndexList = [];
      List<KeyListTile> tempTileList=[];
      elementsToRemoveList.forEach((element) {
        int index= keyList.indexOf(element);
        tempIndexList.add(index);
        tempTileList.add(tileList.elementAt(index));
      });
      for (int i=0;i<tempIndexList.length;i++) {
        animatedListKey.currentState.removeItem(
           tempIndexList[i],
                (context, animation) =>
            ResourceManager().teamId != event.props[0]
                ? slideDownAnimation(tempTileList[i], animation)
                : successAndFadeAnimation(animation, tempTileList[i]),
            duration: Duration(milliseconds: 1500));
      }
      tempIndexList.forEach((index) {
        tileList.removeAt(index);
        keyList.removeAt(index);
      });

      await Future.delayed(Duration(milliseconds: 2300));
      // adding items to the list
      for (int i=0;i<elementsToAddList.length;i++){
        keyList.insert(0, elementsToAddList[i]);
        tileList.insert(0,KeyListTile(elementsToAddList[i]));
        animatedListKey.currentState.insertItem(0,duration: Duration(milliseconds: 700));
        await Future.delayed(Duration(seconds: 1));
      }
      yield (KeyManagerListUpdated());
    }
    if (event is KeyManagerListInitialization && state is KeyManagerUninitialized) {
      List<int> newKeyList = await ResourceManager().getKeys();
      keyList = newKeyList;
      keyList.forEach((keyId)=>tileList.add(KeyListTile(keyId)));
      yield (KeyManagerListUpdated());
    }
    if (event is KeyManagerCommit){
      committedKeys.add(event.keyId);
      int index= keyList.indexOf(event.keyId);
      KeyListTile tile = tileList.elementAt(index);
      animatedListKey.currentState.removeItem(index, (context, animation) => fastFadeAnimation(tile,animation),duration: Duration(milliseconds: 100));
      tileList.removeAt(index);
      keyList.remove(event.keyId);
      await Future.delayed(Duration(milliseconds: 1000));
    }
  }
  FadeTransition fastFadeAnimation(KeyListTile tile,Animation<double> animation){
    return FadeTransition(
        child: tile,
        opacity: Tween(begin: 0.0,end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve:Curves.decelerate
        )
    ));
  }

  SlideTransition slideDownAnimation(KeyListTile tile, Animation<double> animation) {
    return SlideTransition(
              child: tile,
              position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(
                CurvedAnimation(
                    parent: animation,
                    curve: Interval(0.0,1.0,curve:Curves.decelerate)),
              ));
  }

  FadeTransition successAndFadeAnimation(Animation<double> animation, KeyListTile tile) {
    return FadeTransition(
            opacity: Tween(begin: 0.0,end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve:Interval(0.0,1.0,curve: Curves.decelerate),
              )
            ),
            child: DecoratedBoxTransition(
              decoration: DecorationTween(
                end: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.lightGreen,
                ),
                begin: BoxDecoration(
                  color: Colors.lightGreen,
                  shape: BoxShape.circle,
                )
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.decelerate
              )),
              child: tile,
            ),
          );


  }
  SlideTransition exampleTransition(Animation animation, KeyListTile tile){
    return SlideTransition(
        position: Tween<Offset>(
        begin: const Offset(-1, 0),
    end: Offset(0, 0),
    ).animate(animation),
    child: tile);
  }
}
