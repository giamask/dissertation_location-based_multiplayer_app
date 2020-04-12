
import 'package:flutter/widgets.dart';

class GameKey{
  String id;
  String desc;
  String imageName;
  Image image;

  GameKey({this.id,this.desc,this.imageName}){
    try{
      // Retrieve image

      //test

      image=Image.asset("assets/${imageName}");
    }
    catch (e){
      print("CANNOT FIND IMAGE");
    }
  }
}