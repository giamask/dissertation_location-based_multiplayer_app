import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ErrorBloc.dart';
import 'ErrorEvent.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:diplwmatikh_map_test/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'DialogEvent.dart';
import 'DialogState.dart';

class DialogBloc extends Bloc<DialogEvent,DialogState>{
  final BuildContext context;
  DialogBloc(this.context);
  @override
  DialogState get initialState => Ready();

  @override
  Stream<DialogState> mapEventToState(DialogEvent event) async*{
    if (event is MarkerTap) {
      yield LoadingImage();
      List props= event.props;
      try {
        props.add(await ResourceManager().getImage(event.props[3]));
      }
      on ErrorThrown catch (et){
        props.add(Image.asset("assets/placeholder_image.png"));
        BlocProvider.of<ErrorBloc>(context).add(et);
      }
      yield Ready(properties:props);
    }
  }

  }


