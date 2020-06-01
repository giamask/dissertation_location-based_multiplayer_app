import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/BackgroundDisplayBloc.dart';

class AnimatedScoreBubble extends StatefulWidget {
  final Duration duration;
  final Curve curve;
  final Color color;
  final String points;
  final Function onEnd;
  AnimatedScoreBubble({this.duration,this.curve,Key key, this.color=Colors.lightGreen,this.points="+5",this.onEnd}):super(key:key);

  @override
  _AnimatedScoreBubbleState createState() => _AnimatedScoreBubbleState();
}

class _AnimatedScoreBubbleState extends State<AnimatedScoreBubble> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  @override
  void initState() {
    _animationController=AnimationController(vsync: this,duration: widget.duration)..forward();
    super.initState();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBubble(controller: _animationController,onEnd: widget.onEnd,points: widget.points,color: widget.color,duration: widget.duration,);
  }
}

class AnimatedBubble extends AnimatedWidget{
  final Function onEnd;
  final Color color;
  final String points;
  final Duration duration;
  AnimatedBubble({this.duration, Key key,AnimationController controller,this.onEnd,this.color, this.points,}):super(key:key,listenable: controller);

  Animation get _progress => listenable;
  @override
  Widget build(BuildContext context) {

    if (_progress.value==0.0) return Container();
    if (_progress.isCompleted) onEnd();
    return  AnimatedPositioned(
      curve: Curves.linear,
      duration: Duration(milliseconds: 1100),
      right: 5,
      top: _progress.value>0.05?0:40,
      child: AnimatedOpacity(
        opacity: _progress.value>0.05?0:1,
        duration: Duration(milliseconds: 1100 ),
        curve: Curves.easeInCubic,
        child: Container(
          decoration: BoxDecoration(color: color,borderRadius: BorderRadius.circular(40)),
          height: 40,
          width: 40,
          child: Center(child: Text(points,style: TextStyle(color: Colors.white,fontSize: 18),)),
        ),
      ),
    );
  }

}