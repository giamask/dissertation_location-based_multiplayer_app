
import 'dart:async';


import 'package:flutter/widgets.dart';

import 'bloc/ErrorEvent.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';

class GameKey{
  String id;
  String desc;
  String imageName;
  Completer<Image> image = Completer<Image>();

  GameKey({this.id,this.desc,this.imageName}) {
    loadImage();
  }

  void loadImage() async{
    try {
      image.complete(await ResourceManager().getImage(imageName));
    }
    on ErrorThrown catch(et){
      startTimer();
    }
  }

  void startTimer() async{
    await Future.delayed(Duration(seconds: 10));
    loadImage();
  }
}