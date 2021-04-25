import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/cart_model.dart';

class CalculatorDialog extends StatelessWidget {
  const CalculatorDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = CartModel.instance;
    final headline4 = Theme.of(context).textTheme.headline4;

    return SimpleDialog(
      contentPadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.all(kPadding / 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                cart.totalPrice.toString(),
                textAlign: TextAlign.right,
                style: headline4,
              ),
              Divider(),
              TextField(
                readOnly: true,
                style: headline4,
                decoration: InputDecoration(
                  hintText: cart.totalPrice.toString(),
                ),
              )
            ],
          ),
        ),
        GridView.count(
          crossAxisCount: 4,
          semanticChildCount: 16,
          padding: const EdgeInsets.all(kPadding / 4),
          children: _buildCalculator(),
        ),
      ],
    );
  }

  List<Text> _buildCalculator() => List.generate(16, (i) => Text(i.toString()));
}
