import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'Analysis',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
