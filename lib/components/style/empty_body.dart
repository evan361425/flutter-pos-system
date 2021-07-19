import 'package:flutter/material.dart';
import 'package:possystem/translator.dart';

class EmptyBody extends StatelessWidget {
  final Widget body;

  final String? title;

  EmptyBody({required this.body, this.title});

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
          body,
        ],
      ),
    );
  }
}
