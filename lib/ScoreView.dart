import 'package:flutter/material.dart';

class ScoreView extends StatelessWidget {
  final List<List> scoreboard;
  ScoreView(this.scoreboard);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin:Alignment.topCenter ,end:Alignment.bottomCenter,colors:[Colors.blue[900],Colors.purple[600]])),
        child:Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 38, 20, 10),
              child: Text("Πίνακας Βαθμολογίας",style: TextStyle(color: Colors.white,fontSize: 30,),),),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context,index){
                  return ListTile(
                    leading: Icon(Icons.person_pin_circle,color: scoreboard[index][0],size: 30,),
                    title: Text(scoreboard[index][1],style: TextStyle(color: Colors.white),),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(scoreboard[index][2],style: TextStyle(color: Colors.white)),
                    ),
                  );
                },
                separatorBuilder: (_,__)=>Divider(thickness: 0.5,),
                itemCount: scoreboard.length,
              ),
            )
          ],
        )
    );
  }
}
