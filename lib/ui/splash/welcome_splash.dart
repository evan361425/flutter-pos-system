import 'package:flutter/material.dart';

class WelcomeSplash extends StatelessWidget {
  const WelcomeSplash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('歡迎😆', style: TextStyle(fontSize: 32.0))],
        ),
      ),
    );
  }
}
