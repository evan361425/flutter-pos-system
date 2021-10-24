import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/providers/currency_provider.dart';

class OrderCashierCalculator extends StatefulWidget {
  final void Function(String) onTextChanged;

  final VoidCallback onSubmit;

  final num totalPrice;

  const OrderCashierCalculator({
    Key? key,
    required this.onTextChanged,
    required this.onSubmit,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<OrderCashierCalculator> createState() => OrderCashierCalculatorState();
}

class OrderCashierCalculatorState extends State<OrderCashierCalculator> {
  final paidState = GlobalKey<_SingleFieldState>();
  final changeState = GlobalKey<_SingleFieldState>();

  String get text => paidState.currentState?.text ?? '';

  set text(String value) {
    widget.onTextChanged(value);
    paidState.currentState?.setText(value);

    if (value.isEmpty) {
      changeState.currentState?.setText('');
    } else {
      final change = (num.tryParse(value) ?? 0) - widget.totalPrice;
      changeState.currentState?.setText(change < 0 ? null : change.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Column(children: [
        _SingleField(
          key: paidState,
          keyPrefix: 'cashier.calculator.paid',
          prefix: '付額',
          defaultText: widget.totalPrice.toString(),
        ),
        Divider(),
        _SingleField(
          key: changeState,
          keyPrefix: 'cashier.calculator.change',
          prefix: '找錢',
          defaultText: '0',
          errorText: '必須大於付額',
        ),
        Divider(),
      ]),
      Column(children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          _CalculatorPostfixAction(action: execPostfix, text: '1'),
          _CalculatorPostfixAction(action: execPostfix, text: '2'),
          _CalculatorPostfixAction(action: execPostfix, text: '3'),
          _CalculatorAction(
            key: Key('cashier.calculator.clear'),
            action: execClear,
            child: Icon(Icons.clear_sharp),
          ),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          _CalculatorPostfixAction(action: execPostfix, text: '4'),
          _CalculatorPostfixAction(action: execPostfix, text: '5'),
          _CalculatorPostfixAction(action: execPostfix, text: '6'),
          _CalculatorAction(
            key: Key('cashier.calculator.back'),
            action: execBack,
            child: Icon(Icons.arrow_back_rounded),
          ),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          _CalculatorPostfixAction(action: execPostfix, text: '7'),
          _CalculatorPostfixAction(action: execPostfix, text: '8'),
          _CalculatorPostfixAction(action: execPostfix, text: '9'),
          _CalculatorAction(
            key: Key('cashier.calculator.ceil'),
            action: execCeil,
            child: Icon(Icons.merge_type_rounded),
          ),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 64, height: 64),
          _CalculatorPostfixAction(action: execPostfix, text: '0'),
          CurrencyProvider.instance.isInt
              ? SizedBox(width: 64, height: 64)
              : _CalculatorAction(
                  key: Key('cashier.calculator.dot'),
                  action: execDot,
                  child: Text('.'),
                ),
          _CalculatorAction(
            key: Key('cashier.calculator.submit'),
            action: widget.onSubmit,
            child: Icon(Icons.done_rounded),
          ),
        ]),
      ]),
    ]);
  }

  void execBack() {
    if (text.isNotEmpty) {
      text = text.substring(0, text.length - 1);
    }
  }

  void execCeil() {
    final price = num.tryParse(text) ?? widget.totalPrice;
    final ceilPrice = CurrencyProvider.instance.ceil(price);
    text = CurrencyProvider.n2s(ceilPrice);
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

class _CalculatorAction extends StatelessWidget {
  final VoidCallback action;

  final Widget child;

  const _CalculatorAction({Key? key, required this.action, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: OutlinedButton(
        onPressed: action,
        child: child,
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
      key: Key('cashier.calculator.$text'),
      action: () => action(text),
      child: Text(text),
    );
  }
}

class _SingleField extends StatefulWidget {
  final String prefix;

  final String defaultText;

  final String errorText;

  final String keyPrefix;

  _SingleField({
    Key? key,
    required this.keyPrefix,
    required this.prefix,
    required this.defaultText,
    this.errorText = '',
  }) : super(key: key);

  @override
  _SingleFieldState createState() => _SingleFieldState();
}

class _SingleFieldState extends State<_SingleField> {
  String? text = '';

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(widget.prefix),
      text == null
          ? HintText(widget.errorText, key: Key('${widget.keyPrefix}.error'))
          : text!.isEmpty
              ? HintText(
                  widget.defaultText,
                  key: Key('${widget.keyPrefix}.hint'),
                )
              : Text(
                  text!,
                  key: Key(widget.keyPrefix),
                  style: Theme.of(context).textTheme.headline6,
                ),
    ]);
  }

  void setText(String? value) {
    setState(() => text = value);
  }
}
