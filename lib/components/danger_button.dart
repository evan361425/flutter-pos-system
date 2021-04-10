import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class DangerButton extends StatelessWidget {
  const DangerButton({Key key, this.onPressed, this.child}) : super(key: key);

  final void Function() onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: kNegativeColor,
        onPrimary: Colors.white,
      ),
      child: child,
    );
  }
}
