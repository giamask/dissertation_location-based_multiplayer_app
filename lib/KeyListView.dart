import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';

import 'GameKey.dart';
import 'bloc/AnimatorBloc.dart';
import 'bloc/AnimatorState.dart';

class KeyListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(scrollDirection: Axis.horizontal,
        children: listKeyProvider(context));
  }



  List<Widget> listKeyProvider(BuildContext context){
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


}

