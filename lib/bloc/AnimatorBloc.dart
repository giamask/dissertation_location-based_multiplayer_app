import 'package:bloc/bloc.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/animation.dart';
import 'AnimatorEvent.dart';
import 'AnimatorState.dart';

class AnimatorBloc extends Bloc<AnimatorEvent,AnimatorState> {
  @override
  AnimatorState get initialState => MapView();
  AnimationController animationController;
  DragController dragController = DragController();

  @override
  Stream<AnimatorState> mapEventToState(AnimatorEvent event) async*{
    if (event is AnimatorMapShrunk && state is MapView){

      animationController.forward();

      yield(AnimationInProgress(animationDirection: "forward"));
    }
    else if(event is AnimatorMapExpanded && state is ObjectView ){
      if(animationController.isCompleted){
        animationController.reverse();
      }
      yield(AnimationInProgress(animationDirection: "reverse"));
    }
    else if (event is AnimationCompleted && state is AnimationInProgress){

      if (state.props[0]=="forward"){
        yield(ObjectView());
      }
      else{
        yield(MapView());
      }
    }
  }

}


