import 'package:flutter/material.dart';
import 'package:possystem/routes.dart';

class BackendPage extends StatelessWidget {
  final Widget child;
  const BackendPage({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // move page to menu, better UX
    return WillPopScope(
      onWillPop: () async {
        // TODO: x-axis animation
        await Navigator.of(context).pushReplacementNamed(Routes.menu);
        return false;
      },
      child: child,
    );
  }
}
