import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/providers/currency_provider.dart';

class CalculatorDialog extends StatefulWidget {
  const CalculatorDialog({Key? key}) : super(key: key);

  @override
  _CalculatorDialogState createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  final paidController = TextEditingController();
  String? errorMessage;
  bool isUpdating = false;

  String get paid => paidController.text;

  Future<void> handlePressed(_ButtonTypes type) async {
    if (isUpdating) return;

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
        final ceilPrice = CurrencyProvider.instance.ceil(price);
        updatePaid(ceilPrice?.toString() ?? '');
        return;
      case _ButtonTypes.done:
        isUpdating = true;

        if (!await showHistoryConfirm(context)) {
          isUpdating = false;
          return;
        }

        try {
          await CartModel.instance.paid(num.tryParse(paid));
          Navigator.of(context).pop();
        } catch (e, stack) {
          isUpdating = false;
          if (e == 'too low') {
            setState(() => errorMessage = '糟糕，付額小於總價唷');
          } else {
            print(e);
            print(stack);
            setState(() => errorMessage = e.toString());
          }
        }
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
          padding: const EdgeInsets.all(kSpacing2),
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
          padding: const EdgeInsets.all(kSpacing0),
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
                CurrencyProvider.instance.isInt
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
          padding: const EdgeInsets.only(right: kSpacing2),
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
          onPressed: () async => await handlePressed(type),
          child: Icon(icon),
        ),
      ),
    );
  }

  Widget numberWidget(String text, [void Function()? onPressed]) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: OutlinedButton(
          onPressed: () {
            if (isUpdating) return;
            onPressed == null ? onPressed!() : updatePaid(paid + text);
          },
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

  static Future<bool> showHistoryConfirm(BuildContext context) async {
    if (!CartModel.instance.isHistoryMode) return true;

    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(title: '確定要要變更上次的點餐紀錄嗎？'),
    );

    return result ?? false;
  }
}

enum _ButtonTypes {
  back,
  clear,
  ceil,
  done,
  select,
}
