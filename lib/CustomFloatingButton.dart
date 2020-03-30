import 'package:flutter/material.dart';

class CustomFloatingButton extends StatelessWidget{

  final Color color;
  final IconData icon;
  final double size;
  final Function onTap;
  final String image;

  CustomFloatingButton({this.color, this.icon,this.image, this.size,this.onTap});

  @override
  Widget build(BuildContext context){
    assert(icon!=null || image!=null);
    return Container(
        width: size,
        height: size,
        child: new RawMaterialButton(
          shape: new CircleBorder(),
          elevation: 0.0,
          fillColor: color,
          child: Center(
              child: (icon!=null)?Icon(
                icon,
                color: Colors.white,
              ):ImageIcon(AssetImage(image),color: Colors.white,)),
          onPressed: onTap,
        ));
  }

}

