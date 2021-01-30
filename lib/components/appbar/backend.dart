import 'package:flutter/material.dart';

class BackendAppBar extends AppBar {
  final AppBar appBar;

  BackendAppBar(String currentPage)
      : appBar = AppBar(
          title: Text('menu'),
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
