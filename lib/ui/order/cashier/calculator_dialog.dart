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
  String errorMessage;

  String get paid => paidController.text;

  void handlePressed(_ButtonTypes type) {
    switch (type) {
      case _ButtonTypes.back:
        if (paid.isEmpty) return;
        updatePaid(paid.substring(0, paid.length - 1));
        return;
      case _ButtonTypes.clear:
        updatePaid('');
        return;
      case _ButtonTypes.ceil:
        final price =
            paid.isEmpty ? CartModel.instance.totalPrice : num.tryParse(paid);
        final ceilPrice = context.read<CurrencyProvider>().ceil(price);
        updatePaid(ceilPrice?.toString() ?? '');
        return;
      case _ButtonTypes.done:
        final error = CartModel.instance.paid(num.tryParse(paid));
        if (error == 'too low') {
          return setState(() => errorMessage = '糟糕，付額小於總價唷');
        }
        Navigator.of(context).pop();
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
                    errorText: errorMessage,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(kPadding / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                numberWidget('1'),
                numberWidget('2'),
                numberWidget('3'),
                iconWidget(KIcons.clear, _ButtonTypes.clear),
              ]),
              Row(children: [
                numberWidget('4'),
                numberWidget('5'),
                numberWidget('6'),
                iconWidget(Icons.arrow_back_rounded, _ButtonTypes.back),
              ]),
              Row(children: [
                numberWidget('7'),
                numberWidget('8'),
                numberWidget('9'),
                iconWidget(Icons.merge_type_rounded, _ButtonTypes.ceil),
              ]),
              Row(children: [
                iconWidget(Icons.select_all_rounded, _ButtonTypes.select),
                numberWidget('0'),
                context.read<CurrencyProvider>().isInt
                    ? Spacer()
                    : numberWidget('.', () {
                        if (int.tryParse(paid) != null) {
                          updatePaid(paid + '.');
                        }
                      }),
                iconWidget(Icons.done_rounded, _ButtonTypes.done),
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

  Widget iconWidget(IconData icon, _ButtonTypes type) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: OutlinedButton(
          onPressed: () => handlePressed(type),
          child: Icon(icon),
        ),
      ),
    );
  }

  Widget numberWidget(String text, [void Function() onPressed]) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: OutlinedButton(
          onPressed: onPressed ?? () => updatePaid(paid + text),
          child: Text(text),
        ),
      ),
    );
  }

  void updatePaid(String text) {
    paidController.text = text;
    if (errorMessage != null) {
      setState(() => errorMessage = null);
    }
  }
}

enum _ButtonTypes {
  back,
  clear,
  ceil,
  done,
  select,
}
