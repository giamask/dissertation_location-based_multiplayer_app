
import 'package:diplwmatikh_map_test/CustomFloatingButton.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:photo_view/photo_view.dart';
import 'GameKey.dart';
import 'bloc/AnimatorBloc.dart';
import 'bloc/AnimatorState.dart';

class KeyList extends StatefulWidget {
  final keyListHeightPercentage=0.242;
  final verticalPadding=40.0;
  final horizontalPadding=20.0;

  @override
  _KeyListState createState() => _KeyListState();
}

class _KeyListState extends State<KeyList> {
  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.only(
              topLeft: Radius.elliptical(40, 20),
              topRight: Radius.elliptical(40, 20))),
      child: Stack(
        children: <Widget>[
          Positioned(
            left:MediaQuery.of(context).size.width/2-8,
            top:6,
            child: Container(
              child: GestureDetector(
                child: Image.asset(
                  "assets/horizontal_lines3.png",
                  width: 35,
                  height: 6,
                  color: Colors.white38,
                ),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(0.5),
              child: Container(
                height: widget.keyListHeightPercentage* MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: keyWidgetList(widget.verticalPadding,widget.horizontalPadding),
                ),
              )),
        ],
      ),
    );
  }


  List<Widget> keyWidgetList(double vertical, double horizontal){
    List<Widget> keyWidgets=[];

    //Repository.keyList()
    dummyKeyList().forEach((gameKey){
      keyWidgets.add(
        Padding(
          padding:  EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height/18.5, horizontal: horizontal),
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
                    print(state.toString());
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
                        childWhenDragging: Container(),
                        feedback: Opacity(
                            opacity: 0.7,
                            child: Container(
                              height: MediaQuery.of(context).size.height * widget.keyListHeightPercentage - vertical*2 -6,
                              child: gameKey.image,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white)),
                            )),
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







