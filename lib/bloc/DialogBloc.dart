import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/bloc/ResourceManager.dart';
import 'package:diplwmatikh_map_test/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'DialogEvent.dart';
import 'DialogState.dart';

class DialogBloc extends Bloc<DialogEvent,DialogState>{


  @override
  DialogState get initialState => Ready();

  @override
  Stream<DialogState> mapEventToState(DialogEvent event) async*{
    if (event is MarkerTap) {
      yield LoadingImage();
      List props= event.props;
      props.add(await ResourceManager().retrieveImage(event.props[3]));
      yield Ready(properties:props);
    }
  }

  }


