import 'package:flutter/material.dart';

class ScoreView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin:Alignment.topCenter ,end:Alignment.bottomCenter,colors:[Colors.blue[900],Colors.purple[600]]))
    );
  }
}
