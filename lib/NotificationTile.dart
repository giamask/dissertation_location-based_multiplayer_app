import 'dart:math';

import 'package:diplwmatikh_map_test/ZoomableInkwell.dart';
import 'package:diplwmatikh_map_test/bloc/ResourceManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'CustomExpansionTile.dart';

class NotificationTile extends StatefulWidget {
  final bool expandable;
  final String timestamp;
  final RichText text;
  final List<String> assets;

  final Color color;
  NotificationTile(
      {Key key,
        this.color=Colors.grey,
      this.expandable = false,
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
            trailing: Icon(Icons.cancel,color:Colors.white),
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
                    future:Future.wait([ResourceManager().retrieveImage(widget.assets[0]),ResourceManager().retrieveImage(widget.assets[1])]),
                    builder: (context, snapshot) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ZoomableInkwell(child: snapshot.hasData?snapshot.data[0]:CircularProgressIndicator(backgroundColor: Colors.purple[900],),imageName:widget.assets[0]),
                            Icon(Icons.arrow_forward,color: Colors.white,),
                            ZoomableInkwell(child: snapshot.hasData?snapshot.data[1]:CircularProgressIndicator(backgroundColor: Colors.purple[900],),imageName:widget.assets[1]),
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
