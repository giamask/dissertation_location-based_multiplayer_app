import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:diplwmatikh_map_test/AnimatedScoreBubble.dart';
import 'package:diplwmatikh_map_test/bloc/AnimationState.dart';
import 'package:diplwmatikh_map_test/bloc/DragEvent.dart';
import 'package:diplwmatikh_map_test/bloc/DragState.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayEvent.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'ScoreView.dart';
import 'bloc/AnimationEvent.dart';
import 'bloc/BackgroundDisplayBloc.dart';

class BackgroundView extends StatefulWidget {
  final Bloc<BackgroundDisplayEvent, BackgroundDisplayState> bloc;
  BackgroundView(this.bloc);

  @override
  _BackgroundViewState createState() => _BackgroundViewState();
}

class _BackgroundViewState extends State<BackgroundView>
    with SingleTickerProviderStateMixin {

/*  AnimationController animationController;
  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    BlocProvider.of<BackgroundDisplayBloc>(context).scoreChangeAnimation.animationController=animationController;
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundDisplayBloc, BackgroundDisplayState>(
        bloc: widget.bloc,
        builder: (context, state) {
          if ((state is BackgroundDisplayBuildInProgress) ||
              (state is BackgroundDisplayUninitialized)) {
            return Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue[900], Colors.purple[600]])),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is ScoreDisplayBuilt) {
            return ScoreView(state.props[0]);
          }

          Image image = state.props[2];
          Completer<ui.Image> completer = new Completer<ui.Image>();
          image.image
              .resolve(new ImageConfiguration())
              .addListener(ImageStreamListener((info, _) {
            completer.complete(info.image);
          }));

          return Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue[900], Colors.purple[600]])),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 38.0, left: 20, right: 20),
                    child: Text(
                      state.props[0],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  FutureBuilder(
                      future: completer.future,
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return Container(
                            child: Center(
                                child: CircularProgressIndicator(
                              backgroundColor: Colors.purple[700],
                            )),
                          );
                        }
                        final scale = ((MediaQuery.of(context)
                                    .devicePixelRatio *
                                (MediaQuery.of(context).size.width / 2 - 8)) /
                            snapshot.data.width);
                        final scaledHeight = (snapshot.data.height /
                                MediaQuery.of(context).devicePixelRatio) *
                            (scale);
                        final scaledWidth = (snapshot.data.width /
                                MediaQuery.of(context).devicePixelRatio) *
                            (scale);
                        if (snapshot.data.height < 484) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 21.0),
                            child: SizedBox(
                              height: scaledHeight + 12,
                              child: Stack(
                                children: <Widget>[
                                  Positioned(
                                    top: 0,
                                    left: scaledWidth - 10,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Container(
                                        height: scaledHeight,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 +
                                                2,
                                        color: Colors.black45,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 26),
                                            child: Center(
                                                child: SingleChildScrollView(
                                                    child: Text(
                                              state.props[1],
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ))),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 18,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          8,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          child: image),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width / 2 - 8,
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 3),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 21.0),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: image),
                              ),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width / 2.2 - 8,
                              height: MediaQuery.of(context).size.height / 5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(22),
                                    bottomRight: Radius.circular(22)),
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                        child: SingleChildScrollView(
                                      child: Text(
                                        state.props[1],
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.start,
                                      ),
                                    )),
                                  ),
                                  color: Colors.black45,
                                ),
                              ),
                            )
                          ],
                        );
                      }),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.transparent,),
                    height: MediaQuery.of(context).size.height / 4.2,
                    child: Row(
                      children: <Widget>[
                        for (int i = 0; i < 3; i++)
                          Stack(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.051,
                                    top: 36,
                                    bottom: 36),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: BlocBuilder(
                                    bloc: BlocProvider.of<
                                            BackgroundDisplayBloc>(context)
                                        .dragBlocList[i],
                                    builder: (context, state) {
                                      if (state is DragEmpty) {
                                        return DragTarget<String>(
                                          onWillAccept: (_) => true,
                                          onAccept: (keyId) {
                                            BlocProvider.of<
                                                        BackgroundDisplayBloc>(
                                                    context)
                                                .dragBlocList[i]
                                                .add(DragCommitted(
                                                    keyId: keyId,
                                                    position: i));
                                          },
                                          builder: (context, candidates,
                                              rejected) {
                                            if (candidates.length != 0) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black12,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18),
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 2),
                                                ),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    4.2,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.264,
                                              );
                                            }
                                            return Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  4.2,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.264,
                                              color: Colors.black12,
                                            );
                                          },
                                        );
                                      }
                                      if (state is DragRequestInProgress) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              4.2,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.264,
                                          color: Colors.black12,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(28.0),
                                            child: CircularProgressIndicator(
                                              backgroundColor:
                                                  Colors.purple[700],
                                            ),
                                          ),
                                        );
                                      }
                                      if (state is DragFull) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              4.2,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.264,
                                          color: Color.fromARGB(
                                              50, 235, 235, 228),
                                          child: BlocProvider.of<
                                                      BackgroundDisplayBloc>(
                                                  context)
                                              .dragBlocList[i]
                                              .state
                                              .props[0],
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                ),
                              ),
                              BlocBuilder(
                                  bloc: BlocProvider.of<BackgroundDisplayBloc>(context).dragBlocList[i].scoreChangeAnimation,
                                  builder: (context, state) {
                                    if (state is AnimationInProgress && i==state.position)
                                    return AnimatedScoreBubble(duration: Duration(milliseconds: 1200),
                                    color: (state.correct)?Colors.lightGreen[700]:Colors.red[700],
                                    points: (state.correct)?"+5":"-5",
                                    onEnd: ()=>BlocProvider.of<BackgroundDisplayBloc>(context).dragBlocList[i].scoreChangeAnimation.add(AnimationEnded(true)),
                                    );
                                    return Container();
                                  })

                            ],
                          )
                      ],
                    ),
                  )
                ],
              ));
        });
  }
}
