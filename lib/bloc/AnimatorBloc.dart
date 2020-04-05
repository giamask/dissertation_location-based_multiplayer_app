import 'package:bloc/bloc.dart';
import 'AnimatorEvent.dart';
import 'AnimatorState.dart';

class AnimatorBloc extends Bloc<AnimatorEvent,AnimatorState>{
  @override
  AnimatorState get initialState => Idle();

  @override
  Stream<AnimatorState> mapEventToState(AnimatorEvent event) async*{
    if (event is MarkerTap){

    }
    else if(event is PopUpDismiss){

    }
  }

}


