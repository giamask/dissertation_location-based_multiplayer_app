import 'package:bloc/bloc.dart';
import 'package:flutter/animation.dart';
import 'AnimationEvent.dart';
import 'AnimationState.dart';

class AnimationBloc extends Bloc<AnimationEvent,AnimationState> {
  @override
  AnimationState get initialState => AnimationNotStarted();

  AnimationController animationController;

  @override
  Stream<AnimationState> mapEventToState(AnimationEvent event) async*{
    if (event is AnimationStartRequested && state is AnimationNotStarted){
      animationController?.forward();
      yield(AnimationInProgress(event.correct,event.position));
    }
    else if(event is AnimationEnded && state is AnimationInProgress ){
      yield (AnimationComplete());
      if (event.reset) {
        animationController?.reset();
        yield(AnimationNotStarted());
      }
    }
  }

}


