import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import 'GameKey.dart';
import 'bloc/AnimatorBloc.dart';
import 'bloc/AnimatorState.dart';
import 'dart:ui' as ui;

class KeyMenu extends StatefulWidget {
  @override
  _KeyMenuState createState() => _KeyMenuState();
}

class _KeyMenuState extends State<KeyMenu> {
  double opacity=1.0;
  @override
  Widget build(BuildContext context) {
    return SnappingSheet(
      onMove:  _onMove,
      sheetBelow: SnappingSheetContent(
        child: Container(color: Colors.black54,
          child: Column(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height*0.212 - 7,
                  width: MediaQuery.of(context).size.width,
                  child: Opacity(
                    opacity: opacity,
                    child: ListView(scrollDirection: Axis.horizontal,
                      children: listKeyProvider(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        heightBehavior: SnappingSheetHeight.fit(),
      ),
      grabbing: Container(
          decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.elliptical(40, 20),
                  topRight: Radius.elliptical(40, 20))),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset("assets/horizontal_lines3.png",
              width: 40,
              color: Colors.white38,),
            ),
          )
      ),
      grabbingHeight: 30,
      snapPositions: [
        SnapPosition(
            positionFactor: 0.212 ,
        ),
        SnapPosition(
          positionFactor: 0,
        ),
        SnapPosition(
          positionFactor: 0.9,

        )
      ],
    );
  }


  List<Widget> listKeyProvider(){
    List<Widget> keyWidgets=[];
    //Repository.keyList()
    dummyKeyList().forEach((gameKey){
      keyWidgets.add(
          Padding(
            padding:  EdgeInsets.symmetric(
                vertical: 33, horizontal: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                hoverColor: Colors.purple,
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(child: PhotoView(tightMode:true,maxScale: 2.0,initialScale:0.4, minScale: 0.4,imageProvider: AssetImage("assets/"+gameKey.imageName,))),
                          backgroundColor: Colors.transparent,
                        );
                      });
                },
                child: BlocBuilder<AnimatorBloc,AnimatorState>(
                    builder: (context,state) {
                      if (state is MapView){
                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            child: gameKey.image,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white)),
                          ),
                        );
                      }
                      return Draggable<String>(
                          data: gameKey.id,
                          childWhenDragging: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height*0.212 - 73,
                              child: Opacity(opacity:0,child: gameKey.image),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white)),
                            ),
                          ),
                          feedback: Opacity(
                              opacity: 0.7,
                              child:  Container(
                                  height: MediaQuery.of(context).size.height*0.212 - 79,
                                  child: gameKey.image,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white)),
                                ),
                              ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              child: gameKey.image,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white)),
                            ),
                          ));
                    }
                ),
              ),
            ),
          ));
    });
    return keyWidgets;
  }



  List<GameKey> dummyKeyList(){
    return List.generate(11, (index){
      index++;
      return GameKey(id:index.toString(),desc:"Lorem Ipsum",imageName:"k$index.jpg");
    });


  }

  void _onMove(double dy) {

    if (dy<100 && opacity==1) setState(() {
      opacity=0;
    });
    if (dy>=100 && opacity==0) setState(() {
      opacity=1;
    });
  }
}
