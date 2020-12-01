import 'package:flutter/material.dart';

class AnimatedLoginButton extends StatelessWidget {
  final AnimationController animationController;
  final Widget child;
  final double customOffset;

  const AnimatedLoginButton({Key key, this.animationController,  this.child, this.customOffset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animationController,
        curve: Interval(0.3, 1, curve: Curves.linear),
      )),
      child: SlideTransition(
        position: Tween<Offset>(
          begin:  Offset(0.0, customOffset??3.0),
          end: const Offset(0.0, 0),
        ).animate(CurvedAnimation(
            parent: animationController,
            curve: Interval(0.0, 1,
                curve: Curves.fastOutSlowIn))),
        child: child
      ),
    );
  }
}
