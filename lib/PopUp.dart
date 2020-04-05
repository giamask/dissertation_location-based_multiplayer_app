import 'package:flutter/material.dart';

class PopUp extends StatelessWidget {
  final int totalSlots;
  final List<bool> slotsFilled;
  static const WIDTH=200.0;
  static const HEIGHT=153.0;
  final Function onButtonTap;

  PopUp( this.totalSlots,this.slotsFilled,this.onButtonTap);

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
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            child: Column(

              children:<Widget>[
                Row(
                children: <Widget>[
                  ClipRRect(
                      borderRadius:BorderRadius.circular(100),
                      child: Image.asset("assets/1.jpg",height: 50,)),
                  Spacer(),
                  Text("Χαγιάτια",style: TextStyle(fontSize: 21,)),
                  Spacer()
                ],
              ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
}
