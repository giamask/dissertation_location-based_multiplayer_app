import 'dart:math';

import 'package:diplwmatikh_map_test/ZoomableInkwell.dart';
import 'package:diplwmatikh_map_test/bloc/NotificationEvent.dart';
import 'bloc/ErrorEvent.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'CustomExpansionTile.dart';
import 'bloc/NotificationBloc.dart';

class NotificationTile extends StatefulWidget {
  final bool expandable;
  final String timestamp;
  final RichText text;
  final List<String> assets;
  final Function onDelete;
  final Color color;
  NotificationTile(
      {Key key,
        this.color=Colors.grey,
      this.expandable = false,
        @required this.onDelete,
      @required this.timestamp,
      @required this.text,
      this.assets})
      : super(key: key);

  @override
  _NotificationTileState createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile>{




  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color:widget.color,
          child: CustomExpansionTile(
            expandable: widget.expandable,
            backgroundColor: widget.color,
            title: Text(
              widget.timestamp,
              style: TextStyle(
                  color: Colors.white, fontSize: 20),
            ),
            trailing: GestureDetector(child: Icon(Icons.cancel,color:Colors.white),onTap: widget.onDelete),
            subtitle: Padding(
              padding: const EdgeInsets.only(bottom:4.0,top: 1.3),
              child: widget.text,
            ),
            children: <Widget>[(widget.expandable?
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  padding: const EdgeInsets.only(bottom:3),
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: FutureBuilder(
                    future:Future.wait([
                      ResourceManager().getImage(widget.assets[0]),
                      ResourceManager().getImage(widget.assets[1])]),
                    builder: (context, snapshot) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ZoomableInkwell(child: snapshot.hasData?snapshot.data[0]:CircularProgressIndicator(
                              backgroundColor:
                              Colors.purple[800],
                              valueColor: new AlwaysStoppedAnimation<Color>(Colors.purple[600]),
                            ),imageName:widget.assets[0]),
                            Icon(Icons.arrow_forward,color: Colors.white,),
                            ZoomableInkwell(child: snapshot.hasData?snapshot.data[1]:CircularProgressIndicator(
                              backgroundColor:
                              Colors.purple[800],
                              valueColor: new AlwaysStoppedAnimation<Color>(Colors.purple[600]),
                            ),imageName:widget.assets[1]),
                          ]);
                    }
                  ),
                ),
              ):Container()),
            ],

          ),
        ),
      ),
    );

  }
}
