import 'package:flutter/material.dart';

class BackendAppBar {
  final AppBar appBar;

  BackendAppBar(title, BuildContext context)
      : appBar = AppBar(
          title: Center(
            child: Text(title, style: Theme.of(context).textTheme.headline4),
          ),
          leading: IconButton(
            padding: EdgeInsets.only(left: 30.0),
            onPressed: () => print('Menu'),
            icon: Icon(Icons.menu),
            iconSize: 30.0,
          ),
          actions: <Widget>[
            IconButton(
              padding: EdgeInsets.only(right: 30.0),
              onPressed: () => print('Search'),
              icon: Icon(Icons.search),
              iconSize: 30.0,
            ),
          ],
        );
}
