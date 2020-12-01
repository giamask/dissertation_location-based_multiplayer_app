import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String text;
  final Icon icon;
  final Image image;
  final Function onPressed;
  final bool twoliner;

  LoginButton({this.text, this.icon, this.image,this.onPressed,this.twoliner=false}):assert(icon == null || image ==null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:12.0),
      child: SizedBox(height:twoliner?65:50, width: 326 ,child:
        OutlineButton(
        splashColor: Colors.blue[200],
        onPressed: onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40),),
        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              (image==null)? icon
              :image,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Center(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      )
      ),
    );
  }
}
