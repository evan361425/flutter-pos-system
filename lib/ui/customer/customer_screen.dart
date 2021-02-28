import 'package:flutter/material.dart';

class CustomerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'Customer',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
