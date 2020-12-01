
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPopup extends StatelessWidget {
  const LoginPopup({
    Key key,
    @required this.textController,
    @required this.listener,
    @required this.prompt,
    this.plus30 = true,
  }) : super(key: key);

  final TextEditingController textController;
  final Function listener;
  final String prompt;
  final bool plus30;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white60,
      title: Text(
        prompt,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
      actions: [
        plus30?Padding(
          padding: const EdgeInsets.only(bottom: 17.0),
          child: Text("+30",
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ):Container(),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
                height: 12,
                width: 250,
                child: TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: textController..addListener(listener),
                  enabled: true,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  cursorColor: Colors.white,
                  autofocus: true,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      )),
                )))
      ],
    );
  }
}