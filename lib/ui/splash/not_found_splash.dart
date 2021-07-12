import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';

class NotFoundSplash extends StatelessWidget {
  const NotFoundSplash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('找不到頁面'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Text('找不到頁面'),
        ),
      ),
    );
  }
}
