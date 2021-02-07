import 'package:flutter/material.dart';
import 'package:possystem/routes.dart';

class BackendAppBar extends AppBar {
  BackendAppBar(BuildContext context, String title)
      : super(
          title: Center(child: Text(title)),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pushNamed(Routes.setting),
            icon: Icon(Icons.settings),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => print('Search'),
              icon: Icon(Icons.search),
            ),
          ],
        );
}
