
import 'dart:async';
import 'dart:ui';

import 'package:diplwmatikh_map_test/bloc/AnimationState.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'bloc/AnimatorBloc.dart';
import 'bloc/AnimatorEvent.dart';
import 'bloc/AnimatorState.dart' as aniState;
import 'main.dart';

class AnimatedMapBuilder extends StatefulWidget {
  const AnimatedMapBuilder({
    Key key,
    @required this.stateProps,
    @required this.shrinkExpandAnimation,
    @required CameraPosition kGooglePlex,
    @required this.latLngBounds,
  }) : _kGooglePlex = kGooglePlex, super(key: key);

  final List stateProps;
  final Animation shrinkExpandAnimation;
  final CameraPosition _kGooglePlex;
  final LatLngBounds latLngBounds;

  @override
  _AnimatedMapBuilderState createState() => _AnimatedMapBuilderState();
}

class _AnimatedMapBuilderState extends State<AnimatedMapBuilder> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation:
        BlocProvider
            .of<AnimatorBloc>(context)
            .animationController,
        builder: (context, oldWidget) {
          Animation animationController = widget.shrinkExpandAnimation;
          final double ratio = animationController.value>=0.8?0.0:1 - animationController.value;
          final double doubleRatio =
              1 - animationController.value * 1.1;
          final double interRatio =
          animationController.value > 0.55 ? ratio / 0.45 : 1;
          final double doubleInterRatio =
          animationController.value > 0.55 ? doubleRatio / 0.4 : 1;
          return Stack(
            children: <Widget>[
              Transform(
                alignment: alignmentCalculator(BlocProvider
                    .of<AnimatorBloc>(context)
                    .dragController),
                transform:
                Matrix4.diagonal3Values(ratio, doubleRatio, 1.0),
                child: Opacity(
                  opacity: () {
                    if (animationController.value >= 0.8) {
                      return 1.0;
                    } else if (animationController.value >= 0.6) {
                      return ((0.8 - animationController.value) / 0.2);
                    }
                    return 1.0;
                  }(),
                  child: GoogleMap(
                    zoomControlsEnabled: false,
                    onCameraIdle: () => (MainWidgetState.cameraIdle!= null && MainWidgetState.cameraIdle.isCompleted)?null:MainWidgetState.cameraIdle.complete(),
                    markers: widget.stateProps[0],
                    rotateGesturesEnabled: false,
                    mapToolbarEnabled: false,
                    tiltGesturesEnabled: false,
                    mapType: MapType.normal,
                    initialCameraPosition: widget._kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      final Completer<GoogleMapController> _controller =
                      widget.stateProps[1];
                      if (!(_controller.isCompleted)) _controller.complete(controller);
                    },
                    myLocationEnabled: true,
                    compassEnabled: false,
                    cameraTargetBounds: CameraTargetBounds(widget.latLngBounds),
                    //hardcoded limits
                    minMaxZoomPreference: MinMaxZoomPreference(10, 30),
                    myLocationButtonEnabled: false,
                  ),
                ),
              ),
            ],
          );
        });
  }

  Alignment alignmentCalculator(DragController dragController) {
    try {
      if (dragController
          .getCurrentPosition()
          .dy < 55) {
        if (dragController
            .getCurrentPosition()
            .dx < 5)
          return Alignment.topLeft;
        else
          return Alignment.topRight;
      }
      else {
        if (dragController
            .getCurrentPosition()
            .dx < 5) return Alignment.lerp(
            Alignment.centerLeft, Alignment.bottomLeft, 0.4);
      }
    }
    catch (e){}
    return Alignment.lerp(
          Alignment.centerRight, Alignment.bottomRight, 0.4);
  }

}
