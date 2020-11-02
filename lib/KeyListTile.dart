import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';

import 'GameKey.dart';
import 'ZoomableInkwell.dart';
import 'bloc/AnimatorBloc.dart';
import 'bloc/AnimatorState.dart';
import 'bloc/KeyManagerBloc.dart';

class KeyListTile extends StatelessWidget {
  final int index;
  KeyListTile(this.index);
  @override
  Widget build(BuildContext context) {
    GameKey gameKey = dummyKey(index);
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height*0.212/5, horizontal: 20),
      child: ZoomableInkwell(imageName: gameKey.imageName,
        child: FutureBuilder(
          future: gameKey.image.future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container(child: Center(child: CircularProgressIndicator(
                backgroundColor: Colors.purple[700]),));
            return BlocBuilder<AnimatorBloc,AnimatorState>(
              builder: (context,state) {
                if (state is MapView){
                  return Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      child: snapshot.data,
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
                        child: Opacity(opacity:0,child:snapshot.data),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white)),
                      ),
                    ),
                    feedback: Opacity(
                      opacity: 0.7,
                      child:  Container(
                        height: MediaQuery.of(context).size.height*0.212 - 79,
                        child: snapshot.data,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white)),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Stack(
                        children: [
                          Container(
                            child: snapshot.data,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white)),
                          ),

                        ],
                      ),
                    ));
              }
      );
          }
        ),),
    );
  }

  GameKey dummyKey(int index){
    return GameKey(id:index.toString(),desc:"Lorem Ipsum",imageName:"k$index.jpg");
  }

}






