import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';

import 'GameKey.dart';
import 'KeyListTile.dart';
import 'bloc/AnimatorBloc.dart';
import 'bloc/AnimatorState.dart';
import 'bloc/KeyManagerBloc.dart';
import 'bloc/KeyManagerState.dart';

class KeyListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<KeyManagerBloc>(context),
      builder: (context,state) {
        if (state is KeyManagerUninitialized) return Container(
          child: Center(
            child: CircularProgressIndicator(
              backgroundColor:
              Colors.purple[800],
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.purple[600]),
            ),
          ),

        );
        return AnimatedList(itemBuilder: (context,index,animation){
          return SlideTransition(
          position: Tween(begin: Offset(-1,0),end: Offset(0,0)).animate(CurvedAnimation(parent: animation,curve: Curves.easeOut),),
              child: KeyListTile(BlocProvider.of<KeyManagerBloc>(context).keyList[index]));
        },
        scrollDirection: Axis.horizontal,
        initialItemCount: BlocProvider.of<KeyManagerBloc>(context).keyList.length,
          key: BlocProvider.of<KeyManagerBloc>(context).animatedListKey,
        );
      }
    );
  }





  }




