import 'dart:ui';
import 'package:diplwmatikh_map_test/BackgroundView.dart';
import 'package:diplwmatikh_map_test/bloc/AnimatorEvent.dart';
import 'package:diplwmatikh_map_test/bloc/InitEvent.dart';
import 'package:diplwmatikh_map_test/bloc/BackgroundDisplayEvent.dart';
import 'package:diplwmatikh_map_test/bloc/MenuEvent.dart';
import 'package:diplwmatikh_map_test/bloc/MenuState.dart';
import 'package:diplwmatikh_map_test/bloc/ScanEvent.dart';
import 'package:toast/toast.dart';
import 'bloc/ErrorBloc.dart';
import 'bloc/ErrorEvent.dart';
import 'bloc/OrderBloc.dart';
import 'bloc/ScanBloc.dart';
import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diplwmatikh_map_test/CustomFloatingButton.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'AnimatedMapBuilder.dart';
import 'KeyMenu.dart';
import 'PopUp.dart';
import 'package:diplwmatikh_map_test/bloc/InitBloc.dart';
import 'bloc/AnimatorBloc.dart';
import 'bloc/AnimatorState.dart';
import 'bloc/DialogState.dart';
import 'bloc/InitState.dart';
import 'bloc/BackgroundDisplayBloc.dart';
import 'bloc/KeyManagerBloc.dart';
import 'bloc/MenuBloc.dart';
import 'bloc/NotificationBloc.dart';


class GameScreen extends StatelessWidget {
  final String user;
  final int sessionId;
  const GameScreen({Key key, this.user, this.sessionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
          BlocProvider<ErrorBloc>(
            create: (BuildContext context)=>ErrorBloc(context),
          ),
          BlocProvider<OrderBloc>(
            create: (BuildContext context) => OrderBloc(context),
          ),
          BlocProvider<ScanBloc>(
            create: (BuildContext context) => ScanBloc(context),
          ),
          BlocProvider<AnimatorBloc>(
            create: (BuildContext context) => AnimatorBloc(),
          ),
          BlocProvider<BackgroundDisplayBloc>(
            create: (BuildContext context) => BackgroundDisplayBloc(context),
          ),
          BlocProvider<KeyManagerBloc>(
            create: (BuildContext context) => KeyManagerBloc(),
          ),
          BlocProvider<NotificationBloc>(
            create: (BuildContext context) => NotificationBloc(),
          ),
          BlocProvider<InitBloc>(
            create: (BuildContext context) => InitBloc(
                user,sessionId,
                BlocProvider.of<ErrorBloc>(context),
                BlocProvider.of<BackgroundDisplayBloc>(context),
                BlocProvider.of<KeyManagerBloc>(context),
                BlocProvider.of<NotificationBloc>(context),
                BlocProvider.of<OrderBloc>(context),
                BlocProvider.of<ScanBloc>(context),
                context),

          ),
          BlocProvider<MenuBloc>(
            create: (BuildContext context) => MenuBloc(
                BlocProvider.of<AnimatorBloc>(context),
                BlocProvider.of<InitBloc>(context)),
          )
        ], child: MainWidget());
  }
}

class MainWidget extends StatefulWidget {
  @override
  State<MainWidget> createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> with SingleTickerProviderStateMixin {
  static Completer cameraIdle;
  static final CameraPosition _kGooglePlex = CameraPosition(
    //target: LatLng(37.745174, 23.427974),
    target: LatLng(39.353284, 21.0),
    zoom: 13.7746,
  );

  static final latLngBounds = LatLngBounds(
      //northeast: LatLng(37.771908, 23.464144),
      //southwest: LatLng(37.727996, 23.415847)),
      northeast: LatLng(39.653284, 21.243507),
      southwest: LatLng(39.201644, 20.8584));

  Animation shrinkExpandAnimation;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<AnimatorBloc>(context).animationController =
        AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    shrinkExpandAnimation = Tween(begin: 0.0, end: 0.8)
        .animate(BlocProvider.of<AnimatorBloc>(context).animationController);
    BlocProvider.of<AnimatorBloc>(context)
        .animationController
        .addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        BlocProvider.of<AnimatorBloc>(context).add(AnimationCompleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    BlocProvider.of<AnimatorBloc>(context).animationController.dispose();
    BlocProvider.of<AnimatorBloc>(context).close();
    BlocProvider.of<InitBloc>(context).close();
    BlocProvider.of<BackgroundDisplayBloc>(context).close();
    BlocProvider.of<MenuBloc>(context).close();
    BlocProvider.of<NotificationBloc>(context).close();
    BlocProvider.of<OrderBloc>(context).close();
    BlocProvider.of<ScanBloc>(context).close();
    BlocProvider.of<ErrorBloc>(context).close();
    ResourceManager().connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        BlocProvider.of<AnimatorBloc>(context).add(AnimatorMapExpanded());
        return false;
      },
      child: Scaffold(
          body: BlocBuilder<InitBloc, InitState>(builder: (context, state) {
        if (state is InitializeInProgress)
          return Builder(builder: (context) {
            BlocProvider.of<InitBloc>(context).add(GameInitialized());
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/background.jpg"),fit: BoxFit.cover)
              ),
                child: Center(child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom:20.0),
                      child: Text("Φόρτωση παιχνιδιού..",textAlign: TextAlign.center,style:TextStyle(color:Colors.white,fontSize: 23,fontWeight: FontWeight.bold),),
                    ),
                    CircularProgressIndicator(backgroundColor: Colors.purple[600],),
                  ],
                )));
          });

        return Stack(
          children: <Widget>[
            BackgroundView(BlocProvider.of<BackgroundDisplayBloc>(context)),
            BlocBuilder(
              bloc: BlocProvider.of<AnimatorBloc>(context),
              builder: (context, state) {
                return DraggableWidget(
                  normalShadow: BoxShadow(color: Colors.transparent),
                  dragController:
                      BlocProvider.of<AnimatorBloc>(context).dragController,
                  topMargin: 50,
                  bottomMargin: 237,
                  child: GestureDetector(
                    child: Image.asset(
                      "assets/map_icon.png",
                      height: 60,
                    ),
                    onTap: () => BlocProvider.of<AnimatorBloc>(context)
                        .add(AnimatorMapExpanded()),
                  ),
                );
              },
            ),
            AnimatedMapBuilder(
              shrinkExpandAnimation: shrinkExpandAnimation,
              kGooglePlex: _kGooglePlex,
              latLngBounds: latLngBounds,
              stateProps: state.props,
            ),
            KeyMenu(),
            BlocListener(
                bloc: BlocProvider.of<InitBloc>(context).dialogBloc,
                listener: (context, state) {
                  ScanBloc scanBloc = BlocProvider.of<ScanBloc>(context);
                  BackgroundDisplayBloc displayBloc =
                      BlocProvider.of<BackgroundDisplayBloc>(context);
                  AnimatorBloc animatorBloc =
                      BlocProvider.of<AnimatorBloc>(context);
                  ScaffoldState scaffold = Scaffold.of(context);
                  if (state is Ready) {
                    showGeneralDialog(
                        barrierColor: Colors.black38,
                        context: context,
                        barrierLabel: "Label",
                        transitionDuration: Duration(milliseconds: 100),
                        barrierDismissible: true,
                        pageBuilder: (context, anim1, anim2) {
                          return Stack(
                            children: <Widget>[
                              Positioned(
                                top: MediaQuery.of(context).size.height / 2 -
                                    210,
                                left: MediaQuery.of(context).size.width / 2 -
                                    PopUp.WIDTH / 2,
                                child: GestureDetector(
                                    onTapUp: (details) =>
                                        details.localPosition.dy > 130
                                            ? Navigator.of(context).pop()
                                            : null,
                                    child: Container(
                                        height: PopUp.HEIGHT,
                                        width: PopUp.WIDTH,
                                        child: Material(
                                            color: Colors.transparent,
                                            child: PopUp(
                                                active: scanBloc.isAvailable(
                                                    int.parse(state.props[0])),
                                                colors: state.props[4],
                                                totalSlots: 3,
                                                slotsFilled: state.props[2],
                                                onTap: () {
                                                  if (!scanBloc.isAvailable(
                                                      int.parse(
                                                          state.props[0]))) {
                                                    Toast.show("Βρες τον QR κωδικό της τοποθεσίας για να την ξεκλειδώσεις!", context,duration: 3, );
                                                    return;
                                                  }
                                                  Navigator.of(context).pop();
                                                  displayBloc.add(
                                                      BackgroundDisplayChangedToObject(
                                                          id: state.props[0]));
                                                  animatorBloc
                                                      .add(AnimatorMapShrunk());
                                                },
                                                name: state.props[1],
                                                image: state.props[5],
                                                imageName: state.props[3])))),
                              )
                            ],
                          );
                        });
                  }
                },
                child: Container()),
            BlocBuilder(
                bloc: BlocProvider.of<MenuBloc>(context),
                builder: (context, state) {
                  if (!(state is MenuHidden))
                    return Positioned(
                      top: 48,
                      left: 18,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: GestureDetector(
                          onTap: () {
                            BlocProvider.of<BackgroundDisplayBloc>(context)
                                .add(BackgroundDisplayChangedToScore());
                            BlocProvider.of<AnimatorBloc>(context)
                                .add(AnimatorMapShrunk());
                          },
                          child: Container(
                              color: Color.fromRGBO(
                                  ResourceManager().teamColor[0],
                                  ResourceManager().teamColor[1],
                                  ResourceManager().teamColor[2],
                                  1),
                              child: Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: Text(
                                  ResourceManager().teamName,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                        ),
                      ),
                    );
                  return Container();
                }),
            BlocBuilder(
                bloc: BlocProvider.of<MenuBloc>(context),
                builder: (context, state) {
                  if (!(state is MenuHidden) && (!(state is MenuUninitialized)))
                    return AnimatedPositioned(
                      right: 18,
                      top: (state is MenuOpening || state is MenuOpened)
                          ? 83
                          : 43,
                      duration: Duration(milliseconds: 160),
                      onEnd: () => BlocProvider.of<MenuBloc>(context)
                          .add(MenuAnimationCompleted()),
                      child: CustomFloatingButton(
                          onTap: () {
                            if (state is MenuOpened)
                              BlocProvider.of<MenuBloc>(context)
                                  .add(MenuClose());
                            if (state is MenuClosed)
                              BlocProvider.of<MenuBloc>(context)
                                  .add(MenuOpen());
                          },
                          icon: Icons.category,
                          color: state is MenuOpened
                              ? Colors.grey[600]
                              : (Colors.blue[900]),
                          size: 40),
                    );
                  return Container();
                }),
            BlocBuilder(
              bloc: BlocProvider.of<MenuBloc>(context),
              builder: (context, state) {
                if (state is MenuOpened) {
                  return Positioned(
                    top: 30,
                    right: 30,
                    child: CustomFloatingButton(
                        onTap: () {
                          BlocProvider.of<BackgroundDisplayBloc>(context)
                              .add(BackgroundDisplayChangedToScore());
                          BlocProvider.of<AnimatorBloc>(context)
                              .add(AnimatorMapShrunk());
                        },
                        child: Stack(
                          children: <Widget>[
                            Icon(
                              Icons.score,
                              color: Colors.white,
                              size: 28,
                            ),
                            Positioned(
                              top: 5,
                              left: 6,
                              child: Container(
                                height: 8,
                                width: 17,
                                color: Colors.white,
                                child: Center(
                                    child: Text(
                                  "20",
                                  style: TextStyle(
                                      fontSize: 9.1,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple[700]),
                                )),
                              ),
                            )
                          ],
                        ),
                        color: Colors.purple[700],
                        size: 50),
                  );
                }
                return Container();
              },
            ),
            BlocBuilder(
              bloc: BlocProvider.of<MenuBloc>(context),
              builder: (context, state) {
                if (state is MenuOpened) {
                  return Positioned(
                    top: 78,
                    right: 65,
                    child: CustomFloatingButton(
                      onTap: () {
                        print(ResourceManager().user);
                        BlocProvider.of<ScanBloc>(context).cheatMode =
                            !BlocProvider.of<ScanBloc>(context).cheatMode;
                        BlocProvider.of<ErrorBloc>(context).add(ErrorThrown(CustomError(message: "Test",id:0),));
                      },
                      icon: Icons.people,
                      color: Colors.purple[700],
                      size: 50,
                    ),
                  );
                }
                return Container();
              },
            ),
            BlocBuilder(
              bloc: BlocProvider.of<MenuBloc>(context),
              builder: (context, state) {
                if (state is MenuOpened) {
                  return Positioned(
                    top: 125,
                    right: 30,
                    child: CustomFloatingButton(
                      image: "assets/QRicon.png",
                      color: Colors.purple[700],
                      size: 50,
                      onTap: () => qrScan(context),
                    ),
                  );
                }
                return Container();
              },
            ),
          ],
        );
      })),
    );
  }

  void qrScan(BuildContext context) async {
    String objectId ;
    try {
      objectId = await scanner.scan();
    }
    catch(e){
      BlocProvider.of<ErrorBloc>(context).add(ErrorThrown(CustomError(id:30,message:"To QR scanner δεν λειτουργεί σωστά. Δοκιμάστε να επανεκκινήσετε την εφαρμογή και να δώσετε δικαίωμα πρόσβασης στην κάμερα.")));
      return;
    }

      Map<dynamic, dynamic> matchStatus =
          ResourceManager().gameState.matchStatus;
      if (!matchStatus.keys.contains(objectId)) {
        BlocProvider.of<ErrorBloc>(context).add(ErrorThrown(CustomError(id: 21,
            message: "Η τοποθεσία που σκανάρατε φαίνεται να μην ανήκει σε αυτο το παιχνίδι.")));
        return;
      }
      BlocProvider.of<ScanBloc>(context)
          .add(ScanExecuted(Scan(int.parse(objectId), DateTime.now())));
      BlocProvider.of<BackgroundDisplayBloc>(context)
          .add(BackgroundDisplayChangedToObject(id: objectId));
      BlocProvider.of<AnimatorBloc>(context).add(AnimatorMapShrunk());

  }

// Asks permission to use location, returns true if given.



}
