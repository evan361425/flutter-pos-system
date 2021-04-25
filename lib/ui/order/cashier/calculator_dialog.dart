import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:provider/provider.dart';

class CalculatorDialog extends StatefulWidget {
  const CalculatorDialog({Key key}) : super(key: key);

  @override
  _CalculatorDialogState createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  final paidController = TextEditingController();

  void handlePressed(_ButtonTypes type) {
    switch (type) {
      case _ButtonTypes.back:
        if (paidController.text.isEmpty) return;
        final value = paidController.text;
        paidController.text = value.substring(0, value.length - 1);
        return;
      case _ButtonTypes.clear:
        paidController.text = '';
        return;
      case _ButtonTypes.ceil:
        final value = paidController.text;
        final paid =
            value.isEmpty ? CartModel.instance.totalPrice : num.tryParse(value);
        final ceilPaid = context.read<CurrencyProvider>().ceil(paid);
        paidController.text = ceilPaid?.toString() ?? '';
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headline4 = Theme.of(context).textTheme.headline4;

    return SimpleDialog(
      contentPadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.all(kPadding / 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              moneyWidget(
                '總價',
                Text(
                  CartModel.instance.totalPrice.toString(),
                  textAlign: TextAlign.right,
                  style: headline4,
                ),
              ),
              moneyWidget(
                '付額',
                TextField(
                  readOnly: true,
                  style: headline4,
                  controller: paidController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintText: CartModel.instance.totalPrice.toString(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(kPadding / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                numberWidget('1'),
                numberWidget('2'),
                numberWidget('3'),
                buttonWidget(KIcons.clear, _ButtonTypes.clear),
              ]),
              Row(children: [
                numberWidget('4'),
                numberWidget('5'),
                numberWidget('6'),
                buttonWidget(Icons.arrow_back_rounded, _ButtonTypes.back),
              ]),
              Row(children: [
                numberWidget('7'),
                numberWidget('8'),
                numberWidget('9'),
                buttonWidget(Icons.merge_type_rounded, _ButtonTypes.ceil),
              ]),
              Row(children: [
                buttonWidget(Icons.select_all_rounded, _ButtonTypes.select),
                numberWidget('0'),
                numberWidget('.', () {
                  if (int.tryParse(paidController.text) != null) {
                    paidController.text += '.';
                  }
                }),
                buttonWidget(Icons.done_rounded, _ButtonTypes.done),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget moneyWidget(String title, Widget child) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: kPadding / 2),
          child: Text(title),
        ),
        Expanded(
          child: child,
        ),
      ],
    );
  }

  Widget buttonWidget(IconData icon, _ButtonTypes type) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => handlePressed(type),
        child: Icon(icon),
      ),
    );
  }

  Widget numberWidget(String text, [void Function() onPressed]) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed ?? () => paidController.text += text,
        child: Text(text),
      ),
    );
  }
}

enum _ButtonTypes {
  back,
  clear,
  ceil,
  done,
  select,
}
