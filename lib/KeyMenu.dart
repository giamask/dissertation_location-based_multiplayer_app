import 'dart:async';

import 'package:diplwmatikh_map_test/KeyListView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import 'GameKey.dart';
import 'bloc/AnimatorBloc.dart';
import 'bloc/AnimatorState.dart';
import 'dart:ui' as ui;

class KeyMenu extends StatefulWidget {
  @override
  _KeyMenuState createState() => _KeyMenuState();
}

class _KeyMenuState extends State<KeyMenu> {
  double opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return SnappingSheet(
      sheetBelow: SnappingSheetContent(
        child: Container(color: Colors.black54,
          child: Column(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.212 - 7,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Opacity(
                      opacity: opacity,
                      child: KeyListView()
                  ),
                ),
              ),
            ],
          ),
        ),
        heightBehavior: SnappingSheetHeight.fit(),
      ),
      grabbing: Container(
          decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.elliptical(40, 20),
                  topRight: Radius.elliptical(40, 20))),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset("assets/horizontal_lines3.png",
                width: 40,
                color: Colors.white38,),
            ),
          )
      ),
      grabbingHeight: 30,
      snapPositions: [
        SnapPosition(
          positionFactor: 0.212,
        ),
        SnapPosition(
          positionFactor: 0,
        ),
        SnapPosition(
          positionFactor: 0.9,

        )
      ],
    );
  }

}
