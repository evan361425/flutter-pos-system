import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

class MockBuildContext extends Mock implements BuildContext {}

Widget bindWithNavigator<T>(Widget widget, [Function(T?)? callback]) {
  return MaterialApp(
    home: Navigator(
      onPopPage: (route, result) {
        if (callback != null) {
          callback(result);
        }
        return route.didPop(result);
      },
      pages: [
        MaterialPage(child: Container()),
        MaterialPage(child: widget),
      ],
    ),
  );
}
