import 'package:bloc/bloc.dart';
import 'package:flutter/animation.dart';
import 'AnimatorEvent.dart';
import 'AnimatorState.dart';

class AnimatorBloc extends Bloc<AnimatorEvent,AnimatorState> {
  @override
  AnimatorState get initialState => MapView();

  AnimationController animationController;
  
  @override
  Stream<AnimatorState> mapEventToState(AnimatorEvent event) async*{
    if (event is AnimatorMapShrunk){
        if(animationController.isCompleted){
          animationController.reverse();
        }
        else {
          animationController.forward();
        }
      yield(ObjectView());
    }
    else if(event is AnimatorMapExpanded){

    }
  }

}


