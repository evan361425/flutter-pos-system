import 'package:flutter/material.dart';

Widget bindWithNavigator(Widget widget) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Navigator(
      onPopPage: (route, result) => route.didPop(result),
      pages: [
        MaterialPage(child: Container()),
        MaterialPage(child: widget),
      ],
    ),
  );
}
