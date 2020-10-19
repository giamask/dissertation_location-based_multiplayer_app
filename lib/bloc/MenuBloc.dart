import 'dart:async';

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/AnimatorState.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayBloc.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'AnimatorBloc.dart';
import 'BackgroundDisplayEvent.dart';
import 'InitBloc.dart';
import 'InitState.dart';
import 'MenuEvent.dart';
import 'MenuState.dart';

class MenuBloc extends Bloc<MenuEvent,MenuState>{
  final AnimatorBloc animatorBloc;
  final InitBloc initBloc;
  StreamSubscription subscriptionToABloc;
  StreamSubscription subscriptionToIBloc;

  MenuBloc(this.animatorBloc,this.initBloc){
    subscriptionToABloc = animatorBloc.listen((state){
      if (state is MapView){
        this.add(MenuShow());
      }
      else{
        this.add(MenuHide());
      }
    });
    subscriptionToIBloc = initBloc.listen((state){
          if (state is Initialized) this.add(MenuInitialize());
        }
    );
  }

  @override
  Future<void> close(){
    super.close();
    subscriptionToIBloc.cancel();
    subscriptionToABloc.cancel();
  }


  @override
  MenuState get initialState => MenuUninitialized();

  @override
  Stream<MenuState> mapEventToState(MenuEvent event) async*{
    if (event is MenuOpen) {
      yield MenuOpening();
    }
    else if(event is MenuInitialize){
      yield MenuClosed();
    }
    else if (event is MenuClose){
      yield MenuClosing();
    }
    else if (event is MenuHide){
      yield MenuHidden();
    }
    else if (event is MenuShow){
      yield MenuClosed();
    }
    else if (event is MenuAnimationCompleted){
      if (state is MenuOpening){
        yield MenuOpened();
      }
      else if (state is MenuClosing){
        yield MenuClosed();
      }
    }
  }

}


