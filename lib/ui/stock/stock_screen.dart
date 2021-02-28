import 'package:flutter/material.dart';

class StockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'Stock',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
