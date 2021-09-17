import 'package:flutter/material.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/providers/currency_provider.dart';

class CashierCalculator extends StatefulWidget {
  final void Function(String) onTextChanged;

  final VoidCallback onSubmit;

  const CashierCalculator({
    Key? key,
    required this.onTextChanged,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<CashierCalculator> createState() => _CashierCalculatorState();
}

class _CalculatorAction extends StatelessWidget {
  final VoidCallback action;

  final Widget child;

  const _CalculatorAction({required this.action, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: OutlinedButton(
          onPressed: action,
          child: child,
        ),
      ),
    );
  }
}

class _CalculatorPostfixAction extends StatelessWidget {
  final void Function(String) action;

  final String text;

  const _CalculatorPostfixAction({required this.action, required this.text});

  @override
  Widget build(BuildContext context) {
    return _CalculatorAction(
      action: () => action(text),
      child: Text(text),
    );
  }
}

class _CashierCalculatorState extends State<CashierCalculator> {
  String _text = '';

  String get text => _text;

  set text(String value) {
    _text = value;
    widget.onTextChanged(_text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        _CalculatorPostfixAction(action: execPostfix, text: '1'),
        _CalculatorPostfixAction(action: execPostfix, text: '2'),
        _CalculatorPostfixAction(action: execPostfix, text: '3'),
        _CalculatorAction(action: execClear, child: Icon(Icons.clear_sharp)),
      ]),
      Row(children: [
        _CalculatorPostfixAction(action: execPostfix, text: '4'),
        _CalculatorPostfixAction(action: execPostfix, text: '5'),
        _CalculatorPostfixAction(action: execPostfix, text: '6'),
        _CalculatorAction(
            action: execBack, child: Icon(Icons.arrow_back_rounded)),
      ]),
      Row(children: [
        _CalculatorPostfixAction(action: execPostfix, text: '7'),
        _CalculatorPostfixAction(action: execPostfix, text: '8'),
        _CalculatorPostfixAction(action: execPostfix, text: '9'),
        _CalculatorAction(
            action: execCeil, child: Icon(Icons.merge_type_rounded)),
      ]),
      Row(children: [
        Spacer(),
        _CalculatorPostfixAction(action: execPostfix, text: '0'),
        CurrencyProvider.instance.isInt
            ? Spacer()
            : _CalculatorAction(action: execDot, child: Text('.')),
        _CalculatorAction(
            action: widget.onSubmit, child: Icon(Icons.done_rounded)),
      ]),
    ]);
  }

  void execBack() {
    if (text.isNotEmpty) {
      text = text.substring(0, text.length - 1);
    }
  }

  void execCeil() {
    final price = num.tryParse(text) ?? Cart.instance.totalPrice;
    final ceilPrice = CurrencyProvider.instance.ceil(price);
    text = CurrencyProvider.instance.numToString(ceilPrice);
  }

  void execClear() {
    if (text.isNotEmpty) {
      text = '';
    }
  }

  void execDot() {
    if (text.isNotEmpty) {
      if (!text.contains('.')) {
        text = text + '.';
      }
    } else {
      text = '0.';
    }
  }

  void execPostfix(String postfix) {
    text = text + postfix;
  }
}
