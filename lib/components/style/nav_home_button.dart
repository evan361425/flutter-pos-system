import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';

class NavHomeButton extends StatelessWidget {
  const NavHomeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
      icon: Icon(KIcons.clear),
    );
  }
}
