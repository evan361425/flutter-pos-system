import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

class MockBuildContext extends Mock implements BuildContext {}

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
