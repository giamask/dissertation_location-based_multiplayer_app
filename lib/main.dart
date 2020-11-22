import 'package:diplwmatikh_map_test/bloc/LoginState.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AnimatedLoginButton.dart';
import 'LoginButton.dart';
import 'LoginPopup.dart';
import 'bloc/LoginBloc.dart';
import 'bloc/LoginEvent.dart';
import 'main3.dart';

void main() => runApp(MaterialApp(
    title: 'Scrabbling',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: LoginScreen()));

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: FutureBuilder(
          future: Future.wait([Firebase.initializeApp(),Future.delayed(Duration(seconds: 3))]),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              //TODO pop up
              print("init error");
              return null;
            }
          if (snapshot.connectionState == ConnectionState.done) {
              return LoginPage();
            }
            return Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: Image.asset("assets/splashscreen.png").image,
                        fit: BoxFit.cover)));

          }),
    );

    // Otherwise, show something whilst waiting for initialization to complete
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  AnimationController preController;
  AnimationController postController;

  @override
  void initState() {
    super.initState();
    preController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    preController.value = 1.0;
    postController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    if (FirebaseAuth.instance.currentUser == null) {
      BlocProvider.of<LoginBloc>(context)
          .add(LoginInitialized(null, preController, postController));
    } else {
      BlocProvider.of<LoginBloc>(context).add(LoginInitialized(
          FirebaseAuth.instance.currentUser, preController, postController));
    }
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        BlocProvider.of<LoginBloc>(context).add(LoginDeauthorized());
        print('User is currently signed out!');
      } else {
        BlocProvider.of<LoginBloc>(context).add(LoginAuthorized(user));
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset:false,
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          LoginBloc loginBloc = BlocProvider.of<LoginBloc>(context);
          if (loginBloc.state is UserLoggedOut) loginBloc.add(LoginAuthorized(null));
          if (loginBloc.state is UserLoggedIn) loginBloc.add(LoginDeauthorized());
        },
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background.png"),
                fit: BoxFit.cover)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40, top: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: Image(
                    image: AssetImage("assets/logo_big.png"),
                  ),
                ),
                BlocBuilder(
                    bloc: BlocProvider.of<LoginBloc>(context),
                    builder: (context, state) {
                      if (state is LoginInitial) return Container();
                      if (state is UserLoggedOut)
                        return Column(children: [
                          AnimatedLoginButton(
                            animationController:preController,
                            child: LoginButton(
                                text: "Σύνδεση με Google Account",
                                image: Image.asset(
                                  "assets/google_logo.png",
                                  height: 35.0,
                                ),
                                onPressed:
                                  _googleSignIn
                                ),
                          ),
                          AnimatedLoginButton(
                            animationController:preController,
                            child: LoginButton(
                              text: "Σύνδεση με τον αριθμό σας",
                              icon: Icon(Icons.phone,
                                  color: Colors.lightGreen, size: 30),
                              onPressed: () async {
                                _phoneSignIn(context);
                              },
                            ),
                          )
                        ]);
                      return Column(
                        children: [
                          AnimatedLoginButton(
                            animationController:postController,
                            child: LoginButton(
                                twoliner: true,
                                text:
                                    'Σύνδεση στο παιχνίδι "Αίγινα 22/5/2021"',
                                icon: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.green,
                                ),
                                onPressed: ()=>Navigator.of(context).push( MaterialPageRoute(builder: (context) => GameScreen()),)),
                          ),
                          AnimatedLoginButton(
                            animationController:postController,
                            customOffset:3.6,
                            child: LoginButton(
                                text: "Αποσύνδεση",
                                icon: Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                onPressed: _googleSignOut),
                          )
                        ],
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<UserCredential> _googleSignIn() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> _phoneSignIn(BuildContext context) async {
    TextEditingController textController = TextEditingController();
    await showDialog(
        context: context,
        builder: (context) {
          Function listener;
          listener = () {
            if (textController.value.text.length >= 10) {
              Navigator.of(context).pop();
              textController.removeListener(listener);
            }
          };
          return LoginPopup(
            textController: textController,
            listener: listener,
            prompt: "Εισάγετε τον αριθμό τηλεφώνου σας",
          );
        });
    String phoneNumber = textController.text;
    if (phoneNumber.length != 10) return null;
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+30$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        return await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          //TODO error-handling
          print('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, [int resendToken]) async {
        textController = TextEditingController();
        await showDialog(
            context: context,
            builder: (context) {
              Function listener;
              listener = () {
                if (textController.value.text.length >= 6) {
                  Navigator.of(context).pop();
                  textController.removeListener(listener);
                }
              };
              return LoginPopup(
                textController: textController,
                listener: listener,
                prompt: "Εισάγετε τον 6ψήφιο κωδικό που λάβατε μέσω SMS.",
                plus30: false,
              );
            });
        String code = textController.text;
        if (code.length != 6) return null;
        PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: code);
        UserCredential userCredential =
            await _auth.signInWithCredential(phoneAuthCredential);
        return userCredential;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("this hapenned");
        //TODO error-handle
      },
    );
    //TODO error-handle
    return null;
  }

  void _googleSignOut() async {
    print(_auth.currentUser);
    await googleSignIn.signOut();
    await _auth.signOut();
    print("User Sign Out");

  }
}
