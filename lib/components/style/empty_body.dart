import 'package:flutter/material.dart';
import 'package:possystem/translator.dart';

class EmptyBody extends StatelessWidget {
  final VoidCallback onPressed;

  final String? title;

  EmptyBody({this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title ?? tt('empty_body'),
            style: Theme.of(context).textTheme.headline4,
          ),
          OutlinedButton(onPressed: onPressed, child: Text('立即設定')),
        ],
      ),
    );
  }
}
