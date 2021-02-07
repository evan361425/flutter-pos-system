import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';

class EmptyBody extends StatelessWidget {
  final String text;
  EmptyBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Card(
      // background color follow by image
      color: Color(0xFFFFF9EF),
      child: Center(
        // ignore overflow when keyboard open
        child: OverflowBox(
          maxHeight: 300,
          child: _center(context),
        ),
      ),
    );
  }

  Widget _center(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/empty_body.png',
          width: 128,
          height: 128,
        ),
        Text(
          Local.of(context).t(text),
          style: Theme.of(context).textTheme.headline5.copyWith(
                color: Colors.black87,
              ),
        ),
      ],
    );
  }
}
