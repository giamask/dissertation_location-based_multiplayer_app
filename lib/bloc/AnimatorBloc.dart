import 'package:bloc/bloc.dart';
import 'AnimatorEvent.dart';
import 'AnimatorState.dart';

class AnimatorBloc extends Bloc<AnimatorEvent,AnimatorState>{
  @override
  AnimatorState get initialState => MapView();

  @override
  Stream<AnimatorState> mapEventToState(AnimatorEvent event) async*{
    if (event is AnimatorMapShrunk){

    }
    else if(event is AnimatorMapExpanded){

    }
  }

}


