import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';

class ButtomSmallText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Local.of(context).t('app'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10),
            )
          ],
        )
      ],
    );
  }
}
