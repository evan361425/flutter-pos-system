import 'package:flutter/material.dart';

class EmptyContentWidget extends StatelessWidget {
  final String title;
  final String message;

  EmptyContentWidget(
      {Key key,
      this.title,
      this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title),
          Text(message),
        ],
      ),
    );
  }
}
