import 'package:flutter/material.dart';

class EmptyBody extends StatelessWidget {
  final String text;
  EmptyBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('哎呀！這裡還是空的', style: Theme.of(context).textTheme.headline4),
          Text(text),
        ],
      ),
    );
  }
}
