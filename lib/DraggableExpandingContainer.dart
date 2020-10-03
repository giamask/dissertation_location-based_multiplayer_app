import 'package:animations/animations.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
class DraggableExpandingContainer extends StatelessWidget {

  const DraggableExpandingContainer({
    Key key, this.closedContainer, this.openContainer, this.controller
  }) : super(key: key);
  final Widget closedContainer;
  final Widget openContainer;
  final DraggableExpandingContainerController controller;
  @override
  Widget build(BuildContext context) {
    return DraggableWidget(
        bottomMargin: 80,
        topMargin: 80,
        intialVisibility: true,
        horizontalSapce: 0,
        shadowBorderRadius: 50,
        child: OpenContainer(
          tappable: false,
          closedBuilder: (_, openContainer) {
            controller.openContainer = openContainer;
            return closedContainer;
          },
          openColor: Colors.transparent,
          closedElevation: 5.0,
          closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100)),
          closedColor: Colors.transparent,
          openBuilder: (_, closeContainer) {
            controller.closeContainer = closeContainer;
            return openContainer;
          },
        ));
  }
}

class DraggableExpandingContainerController {
  Function _openContainer;
  Function _closeContainer;

  Function get openContainer => superOpen;

  set openContainer(Function value) {
    _openContainer = value;
  }

  void superOpen(){
    _openContainer();

  }

  void superClose(){
    _closeContainer();

  }

  Function get closeContainer => superClose;

  set closeContainer(Function value) {
    _closeContainer = value;
  }
}
