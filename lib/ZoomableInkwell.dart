import 'file:///D:/AS_Workspace/diplwmatikh_map_test/lib/Repositories/ResourceManager.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'GameKey.dart';

class ZoomableInkwell extends StatelessWidget {
  const ZoomableInkwell({
    Key key,
    @required this.child,
    @required this.imageName,
  }) : super(key: key);

  final Widget child;
  final String imageName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
          hoverColor: Colors.purple,
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: FutureBuilder(
                        future: retrieveImage(imageName),
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? Container(
                                  child: PhotoView(
                                      tightMode: true,
                                      maxScale: 2.0,
                                      initialScale: 0.4,
                                      minScale: 0.4,
                                      imageProvider: snapshot.data))
                              : Container(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        backgroundColor: Colors.purple[700]),
                                  ),
                                );
                        }),
                    backgroundColor: Colors.transparent,
                  );
                });
          },
          child: child),
    );
  }

  Future<ImageProvider> retrieveImage(String imageName) async {
    Image image = await ResourceManager().retrieveImage(imageName);
    return image.image;
  }
}
