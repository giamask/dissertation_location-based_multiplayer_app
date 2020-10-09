import 'dart:convert';

import 'package:diplwmatikh_map_test/bloc/ResourceManager.dart';
import 'package:flutter/material.dart';

import '../KeyListTile.dart';
import 'KeyManagerEvent.dart';
import "KeyManagerState.dart";
import 'package:flutter_bloc/flutter_bloc.dart';

class KeyManagerBloc extends Bloc<KeyManagerEvent, KeyManagerState> {
  KeyManagerBloc();
  final animatedListKey = GlobalKey<AnimatedListState>();
  List<int> keyList = [];

  @override
  Future<void> close() {
    return super.close();
  }

  @override
  KeyManagerState get initialState => KeyManagerUninitialized();

  @override
  Stream<KeyManagerState> mapEventToState(KeyManagerEvent event) async* {

    if (event is KeyManagerKeyMatch && keyList.contains(event.props[2]) && !(state is KeyManagerUninitialized)) {
      yield(KeyManagerListUpdateInProgress());
      List<int> newKeyList = await ResourceManager().requestKeys();
      List<int> elementsToRemoveList = keyList.where((element) => !newKeyList.contains(element)).toList();
      List<int> elementsToAddList = newKeyList.where((element) => !keyList.contains(element)).toList();

      // removing items from the list
      elementsToRemoveList.sort((a, b) => elementsToRemoveList.indexOf(b) - elementsToRemoveList.indexOf(a));
      elementsToRemoveList.forEach((element) {
        int keyId = element;
        animatedListKey.currentState.removeItem(
            keyList.indexOf(element),
            (context, animation) => DecoratedBoxTransition(
              decoration: DecorationTween(
                end: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.lightGreen,
                ),
                begin: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                )
              ).animate(CurvedAnimation(
                parent: animation,
                curve:Interval(
                  0.6,1.0,
                  curve: Curves.easeOut
                )
              )),
              child: SlideTransition(
                  child: KeyListTile(keyId),
                  position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(
                    CurvedAnimation(
                        parent: animation,
                        curve: Interval(0.0,0.2,curve:Curves.easeOut),
                        reverseCurve: Curves.fastOutSlowIn),
                  )),
            ),
            duration: Duration(milliseconds: 2000));
      });
      elementsToRemoveList.forEach((element) {
        keyList.remove(element);
      });

      await Future.delayed(Duration(milliseconds: 2200));
      // adding items to the list
      for (int i=0;i<elementsToAddList.length;i++){
        keyList.insert(0, elementsToAddList[i]);
        animatedListKey.currentState.insertItem(0,duration: Duration(milliseconds: 700));
        await Future.delayed(Duration(seconds: 1));
      }
      yield (KeyManagerListUpdated());
    }


    if (event is KeyManagerListInitialization && state is KeyManagerUninitialized) {
      List<int> newKeyList = await ResourceManager().requestKeys();
//      List<int> newKeyList = [1,2,3,4,5];
      keyList = newKeyList;
      yield (KeyManagerListUpdated());
    }
  }

}
