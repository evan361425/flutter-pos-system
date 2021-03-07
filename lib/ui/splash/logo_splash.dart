import 'package:flutter/material.dart';

class LogoSplash extends StatelessWidget {
  const LogoSplash({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 128, height: 128),
          ],
        ),
      ),
    );
  }
}
