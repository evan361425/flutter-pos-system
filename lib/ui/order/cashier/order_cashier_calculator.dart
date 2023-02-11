import 'package:flutter/material.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

const _operators = ['+', '-', 'x'];

class OrderCashierCalculator extends StatefulWidget {
  final void Function(num?) onTextChanged;

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

  bool isOperating = false;

  String get text => paidState.currentState?.text ?? '';

  set text(String value) {
    paidState.currentState?.setText(value);

    if (value.isEmpty) {
      changeState.currentState?.setText('');
      widget.onTextChanged(null);
    } else {
      final parsed = calc(value);
      final change = parsed - widget.totalPrice;
      widget.onTextChanged(parsed);
      changeState.currentState
          ?.setText(change < 0 ? null : change.toCurrency());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(children: [
      Column(children: [
        _SingleField(
          key: paidState,
          keyPrefix: 'cashier.calculator.paid',
          prefix: S.orderCashierCalculatorPaidLabel,
          defaultText: widget.totalPrice.toCurrency(),
        ),
        const Divider(),
        _SingleField(
          key: changeState,
          keyPrefix: 'cashier.calculator.change',
          prefix: S.orderCashierCalculatorChangeLabel,
          defaultText: '0',
          errorText: S.orderCashierCalculatorChangeNotEnough,
        ),
        const Divider(),
      ]),
      Expanded(
        child: Center(
          child: SingleChildScrollView(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Column(mainAxisSize: MainAxisSize.min, children: [
                _CalculatorPostfixAction(action: execPostfix, text: '1'),
                _CalculatorPostfixAction(action: execPostfix, text: '4'),
                _CalculatorPostfixAction(action: execPostfix, text: '7'),
                _CalculatorPostfixAction(action: execPostfix, text: '00'),
              ]),
              Column(mainAxisSize: MainAxisSize.min, children: [
                _CalculatorPostfixAction(action: execPostfix, text: '2'),
                _CalculatorPostfixAction(action: execPostfix, text: '5'),
                _CalculatorPostfixAction(action: execPostfix, text: '8'),
                _CalculatorPostfixAction(action: execPostfix, text: '0'),
              ]),
              Column(mainAxisSize: MainAxisSize.min, children: [
                _CalculatorPostfixAction(action: execPostfix, text: '3'),
                _CalculatorPostfixAction(action: execPostfix, text: '6'),
                _CalculatorPostfixAction(action: execPostfix, text: '9'),
                _CalculatorAction(
                  key: const Key('cashier.calculator.dot'),
                  action: execDot,
                  child: const Text('.'),
                ),
              ]),
              Column(mainAxisSize: MainAxisSize.min, children: [
                _CalculatorAction(
                  key: const Key('cashier.calculator.plus'),
                  action: () => addOperator('+'),
                  color: theme.colorScheme.secondary,
                  child: const Icon(Icons.add_sharp),
                ),
                _CalculatorAction(
                  key: const Key('cashier.calculator.minus'),
                  action: () => addOperator('-'),
                  color: theme.colorScheme.secondary,
                  child: const Icon(Icons.remove_sharp),
                ),
                _CalculatorAction(
                  key: const Key('cashier.calculator.times'),
                  action: () => addOperator('x'),
                  color: theme.colorScheme.secondary,
                  child: const Icon(Icons.clear_sharp),
                ),
                _CalculatorAction(
                  key: const Key('cashier.calculator.ceil'),
                  action: execCeil,
                  color: theme.colorScheme.secondary,
                  child: const Icon(Icons.merge_type_rounded),
                ),
              ]),
              Column(mainAxisSize: MainAxisSize.min, children: [
                _CalculatorAction(
                  key: const Key('cashier.calculator.back'),
                  action: execBack,
                  color: theme.colorScheme.error,
                  child: const Icon(Icons.arrow_back_rounded),
                ),
                _CalculatorAction(
                  key: const Key('cashier.calculator.clear'),
                  action: execClear,
                  color: theme.colorScheme.error,
                  child: const Icon(Icons.refresh_sharp),
                ),
                _CalculatorAction(
                  key: const Key('cashier.calculator.submit'),
                  action: execSubmit,
                  height: 124,
                  child: isOperating
                      ? const Text('=')
                      : const Icon(Icons.check_sharp),
                ),
              ]),
            ]),
          ),
        ),
      ),
    ]);
  }

  void addOperator(String operator) {
    if (text.isNotEmpty) {
      text = calc(text).toCurrency() + operator;
      setState(() {
        isOperating = true;
      });
    }
  }

  void execCeil() {
    final price = calc(text, widget.totalPrice.toInt());
    final ceilPrice = CurrencySetting.instance.ceil(price);
    text = ceilPrice.toCurrency();
  }

  void execBack() {
    if (text.isNotEmpty) {
      text = text.substring(0, text.length - 1);
      setState(() {
        isOperating = _operators.any((o) => text.contains(o));
      });
    }
  }

  void execClear() {
    if (text.isNotEmpty) {
      text = '';
      setState(() {
        isOperating = false;
      });
    }
  }

  void execSubmit() {
    if (isOperating) {
      setState(() {
        isOperating = false;
      });
      text = calc(text).toCurrency();
    } else {
      widget.onSubmit();
    }
  }

  void execDot() {
    if (text.isNotEmpty) {
      if (!text.contains('.')) {
        text = '$text.';
      }
    } else {
      text = '0.';
    }
  }

  void execPostfix(String postfix) {
    text = text + postfix;
  }

  num calc(String val, [num other = 0]) {
    final fallback = num.tryParse(val) ?? other;
    try {
      final deli = _operators.firstWhere((o) => val.contains(o));
      final parts = val.split(deli).map((e) => num.tryParse(e)).toList();

      switch (deli) {
        case '+':
          return parts[0]! + (parts[1] ?? 0);
        case '-':
          return parts[0]! - (parts[1] ?? 0);
        case 'x':
        default:
          return parts[0]! * (parts[1] ?? 1);
      }
    } on StateError {
      return fallback;
    }
  }
}

class _CalculatorAction extends StatelessWidget {
  final VoidCallback action;

  final double height;

  final Color? color;

  final Widget child;

  const _CalculatorAction({
    Key? key,
    required this.action,
    required this.child,
    this.height = 60,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      width: 60,
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(foregroundColor: color),
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

  const _SingleField({
    Key? key,
    required this.keyPrefix,
    required this.prefix,
    required this.defaultText,
    this.errorText = '',
  }) : super(key: key);

  @override
  State<_SingleField> createState() => _SingleFieldState();
}

class _SingleFieldState extends State<_SingleField> {
  String? text = '';

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(widget.prefix),
      text == null
          ? Text(widget.errorText, key: Key('${widget.keyPrefix}.error'))
          : text!.isEmpty
              ? Text(widget.defaultText, key: Key('${widget.keyPrefix}.hint'))
              : Text(text!, key: Key(widget.keyPrefix)),
    ]);
  }

  void setText(String? value) {
    setState(() => text = value);
  }
}
