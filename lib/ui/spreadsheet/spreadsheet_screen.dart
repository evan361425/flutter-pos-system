import 'package:flutter/material.dart';

class SpreadsheetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'Spreadsheet',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
