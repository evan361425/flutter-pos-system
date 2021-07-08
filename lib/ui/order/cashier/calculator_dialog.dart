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

enum _ButtonTypes {
  back,
  clear,
  ceil,
  done,
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  static final paidController = TextEditingController();
  static final changeController = TextEditingController(text: '0');
  final totalPrice = CartModel.instance.totalPrice;

  String? errorMessage;
  bool _isUpdating = false;

  num? get paid => num.tryParse(paidController.text);

  /// money pay to customer when paid is more then price
  num get change => paid == null ? 0 : paid! - totalPrice;

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
                  totalPrice.toString(),
                  textAlign: TextAlign.right,
                  style: headline4,
                ),
              ),
              moneyWidget(
                '找額',
                TextField(
                  readOnly: true,
                  style: headline4,
                  controller: changeController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
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
                    hintText: totalPrice.toString(),
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
                Spacer(),
                numberWidget('0'),
                CurrencyProvider.instance.isInt
                    ? Spacer()
                    : numberWidget('.', () {
                        if (paidController.text.isNotEmpty &&
                            !paidController.text.contains('.')) {
                          updatePaid(paidController.text + '.');
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

  @override
  void dispose() {
    changeController.dispose();
    paidController.dispose();
    super.dispose();
  }

  Future<void> handlePressed(_ButtonTypes type) async {
    if (_isUpdating) return;

    final paidText = paidController.text;

    switch (type) {
      case _ButtonTypes.back:
        if (paidText.isEmpty) return;
        updatePaid(paidText.substring(0, paidText.length - 1));
        return;
      case _ButtonTypes.clear:
        updatePaid('');
        return;
      case _ButtonTypes.ceil:
        final ceilPrice = CurrencyProvider.instance.ceil(paid ?? totalPrice);
        updatePaid(ceilPrice?.toString() ?? '');
        return;
      case _ButtonTypes.done:
        if (!await confirmChangeHistory(context)) {
          return;
        }

        _isUpdating = true;
        try {
          await CartModel.instance.paid(paid);
          Navigator.of(context).pop();
        } catch (e) {
          _isUpdating = false;
          if (e == 'too low') {
            setState(() => errorMessage = '糟糕，付額小於總價唷');
          } else {
            setState(() => errorMessage = e.toString());
          }
        }
        return;
      default:
        return;
    }
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

  @override
  void initState() {
    super.initState();
    paidController.addListener(() {
      changeController.text =
          change <= 0 ? '0' : CurrencyProvider.instance.numToString(change);
    });
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

  Widget numberWidget(String text, [VoidCallback? onPressed]) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: OutlinedButton(
          onPressed: () {
            if (_isUpdating) return;
            onPressed == null
                ? updatePaid(paidController.text + text)
                : onPressed();
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

  static Future<bool> confirmChangeHistory(BuildContext context) async {
    if (!CartModel.instance.isHistoryMode) return true;

    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(title: '確定要要變更上次的點餐紀錄嗎？'),
    );

    return result ?? false;
  }
}
