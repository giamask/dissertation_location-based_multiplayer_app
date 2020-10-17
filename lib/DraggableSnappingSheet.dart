import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DraggableSnappingSheet extends StatefulWidget {
  @override
  _DraggableSnappingSheetState createState() => _DraggableSnappingSheetState();
}

class _DraggableSnappingSheetState extends State<DraggableSnappingSheet> with SingleTickerProviderStateMixin {
  double y=0.758;
  double startingDragY =0;
  double startingY =0;
  bool enabled=true;
  double target;
  AnimationController animationController;
  bool updateEnabled=true;


  @override
  void initState() {
    animationController= AnimationController(vsync: this,duration: Duration(milliseconds: 300));
    super.initState();
  }

  @override
  void dispose(){
    animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
        animation: animationController,
        builder: (context,child){
          if (animationController.isCompleted) {
            animationController.reset();
            enabled=true;
            y=target;
          }
          return Positioned(
            top: enabled?( y * height): y*height - (y*height - target*height)*animationController.value,
            child: GestureDetector(
              onVerticalDragStart: (dragDetails){
                if (enabled) {
                  startingDragY = dragDetails.globalPosition.dy;
                  startingY = y * height;
                  updateEnabled=true;
                }
              },
              onVerticalDragUpdate: (dragDetails){
                if (updateEnabled) {
                  setState(() {
                    double offset = (dragDetails.globalPosition.dy -
                        startingDragY);
                    y = (startingY + offset) / height;
                  });
                }
              },
              onVerticalDragEnd: (dragDetails){
                if(enabled){
                  print(dragDetails.primaryVelocity.toString() + "<-");
                  enabled = false;
                  updateEnabled=false;


                  if (y>0.881)target = 0.95;
                  else if (y>0.379) target = 0.758;
                  else target = 0;
                  animationController.forward();
                }
              },
              child: Container(
                  height: MediaQuery.of(context).size.height+10 ,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.elliptical(40, 20),
                          topRight: Radius.elliptical(40, 20))),
                  child: Container()),
            ),
          );
        });
  }
}
