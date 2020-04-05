import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'bloc/ResourceManager.dart';

class PopUp extends StatelessWidget {
  final int totalSlots;
  final List<bool> slotsFilled;
  static const WIDTH=200.0;
  static const HEIGHT=153.0;
  final Function onButtonTap;
  final String name;
  final Image image;
  final String imageName;

  PopUp( this.totalSlots,this.slotsFilled,this.onButtonTap,this.name,this.image,this.imageName);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: HEIGHT,width: WIDTH,
        ),
        Container(
          height: 130,
          width: WIDTH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.white,
            border: Border.all(color: Colors.black,width: 0.05)
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(7, 7, 7, 0),
            child: Column(

              children:<Widget>[
                Row(
                children: <Widget>[
                  ClipRRect(
                      borderRadius:BorderRadius.circular(100),
                      child: SizedBox(height: 50,child: GestureDetector(
                          onTap: () {
                            zoomOnTap(context);
                          },
                          child: image))),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:2.0),
                    child: Container(
                      width:100,
                      child: Column(
                        children: <Widget>[
                          Text(name,style: TextStyle(fontSize: (name.length>=9)?(name.length>=11)?15:17:21,),textAlign: TextAlign.center,),
                        ],
                      ),
                    ),
                  ),
                  Spacer()
                ],
              ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical:8.0),
                  child: Row(
                    children: <Widget>[
                      for (int i=0;i<totalSlots;i++) Padding(
                        padding: const EdgeInsets.only(right:8.0),
                        child: Container(
                          height:30,
                          width:30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: (slotsFilled[i]?Colors.green[600]:Colors.grey[400]),
                          border: Border.all(color:Colors.black,width: 0.01)),
                          child: (slotsFilled[i]?Icon(Icons.check,color: Colors.white,):null),
                        ),
                      )
                    ],
                  ),
                ),
  ] ),
          )
        ),
        Positioned(top:105,left: WIDTH/2 - 138/2 ,child: FloatingActionButton.extended(onPressed: onButtonTap, label: Text("Λεπτομέριες"),backgroundColor: Colors.blue[900],) ,)
      ],
    );
  }
  void zoomOnTap(BuildContext context) async{
    showDialog(
        context: context,
        builder: (BuildContext context) {


              return Dialog(
                child: Container(child: PhotoView(tightMode:true,maxScale: 2.0,initialScale:0.55, minScale: 0.55,imageProvider: image.image)),
                backgroundColor: Colors.transparent,
              );
            }
          );

  }
}

