import 'package:flutter/material.dart';

class StockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('庫存'),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              primary: Theme.of(context).textTheme.headline1.color,
            ),
            onPressed: () => print('hi'),
            child: Text('份量'),
          )
        ],
      ),
      body: Text('hi'),
    );
  }
}
