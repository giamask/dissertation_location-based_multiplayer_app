import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/ResourceManager.dart';
import 'InitEvent.dart';
import 'InitState.dart';

class AnimatorBloc extends Bloc<InitEvent,InitState>{
  @override
  InitState get initialState => InitializeInProgress();

  @override
  Stream<InitState> mapEventToState(InitEvent event) async*{
    if (event is GameInitialized) {
      ResourceManager resourceManager = ResourceManager();
      await resourceManager.init();
      String json = await resourceManager.retrieveAssetRegistry();
      Map decodedJson=jsonDecode(json);

    }
  }

}


