import 'dart:async';
import 'dart:math';

import 'package:diplwmatikh_map_test/KeyListView.dart';
import 'package:diplwmatikh_map_test/bloc/NotificationState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import 'GameKey.dart';
import 'NotificationTile.dart';
import 'bloc/AnimatorBloc.dart';
import 'bloc/AnimatorState.dart';
import 'dart:ui' as ui;

import 'bloc/NotificationBloc.dart';

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
        child: Container(
          color: Color.fromRGBO(0, 0, 0, 0.65),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.212 - 7,
                width: MediaQuery.of(context).size.width,
                child: Opacity(opacity: opacity, child: KeyListView()),
              ),
              Divider(
                color: Colors.white38,
                indent: 20,
                endIndent: 20,
                thickness: 3,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Text(
                    "Ενημερώσεις",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  )),
              Expanded(

                  child: AnimatedList(
                    key: BlocProvider.of<NotificationBloc>(context).notificationListKey,
                    itemBuilder: (BuildContext context, int index,
                        Animation<double> animation) {
                      List props = BlocProvider.of<NotificationBloc>(context).notificationsInTray[index];
                      return SlideTransition(
                        key: Key(props[1].toString()),
                        position: Tween(begin: Offset(-1,0),end: Offset(0,0)).animate(CurvedAnimation(parent: animation,curve: Curves.easeOut),),
                        child: NotificationTile(timestamp: props[0], text: props[1],expandable: props[2],assets: props[3],color:props[4]),
                      );
                    },
                    initialItemCount: 0,
                  )),
            ],
          ),
        ),
        heightBehavior: SnappingSheetHeight.fixed(),
      ),
      grabbing: Stack(
        children: [
          Container(
              decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.65),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.elliptical(40, 20),
                      topRight: Radius.elliptical(40, 20))),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    "assets/horizontal_lines3.png",
                    width: 40,
                    color: Colors.white38,
                  ),
                ),
              )),
          BlocBuilder(
            bloc: BlocProvider.of<NotificationBloc>(context),
            builder: (context,state) {
              if (state != NotificationTrayUnread) return Container();
              return Positioned(top:8.65,left:MediaQuery.of(context).size.width/2 + 16.75,child: SizedBox(child: Container(decoration: BoxDecoration(color:Colors.red,borderRadius: BorderRadius.circular(10))),height: 6.5,width:6.5,));
            }
          ),
        ],
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
          positionFactor: 0.85,
        )
      ],
    );
  }
}

