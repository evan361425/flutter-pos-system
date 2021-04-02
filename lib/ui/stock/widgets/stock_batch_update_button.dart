import 'package:flutter/material.dart';

class StockUpdateMultipleButton extends StatelessWidget {
  const StockUpdateMultipleButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Spacer(),
        ElevatedButton.icon(
          onPressed: () => print('hi'),
          icon: Icon(Icons.add_circle_outline_sharp),
          label: Text('批量設定'),
        ),
      ],
    );
  }
}
