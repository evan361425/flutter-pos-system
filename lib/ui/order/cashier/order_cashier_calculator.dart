import 'package:flutter/material.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

const _operators = ['+', '-', 'x'];

class OrderCashierCalculator extends StatefulWidget {
  final VoidCallback onSubmit;

  final num totalPrice;

  const OrderCashierCalculator({
    Key? key,
    required this.onSubmit,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<OrderCashierCalculator> createState() => _OrderCashierCalculatorState();
}

class _OrderCashierCalculatorState extends State<OrderCashierCalculator> {
  final paidState = GlobalKey<_SingleFieldState>();
  final changeState = GlobalKey<_SingleFieldState>();

  bool isOperating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(children: [
      Column(children: [
        _SingleField(
          key: paidState,
          id: 'cashier.calculator.paid',
          prefix: S.orderCashierPaidLabel,
          defaultText: widget.totalPrice.toCurrency(),
          errorText: '',
        ),
        const Divider(),
        _SingleField(
          key: changeState,
          id: 'cashier.calculator.change',
          prefix: S.orderCashierChangeLabel,
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
                _CalculatorPostfixAction(action: _execPostfix, text: '1'),
                _CalculatorPostfixAction(action: _execPostfix, text: '4'),
                _CalculatorPostfixAction(action: _execPostfix, text: '7'),
                _CalculatorPostfixAction(action: _execPostfix, text: '00'),
              ]),
              Column(mainAxisSize: MainAxisSize.min, children: [
                _CalculatorPostfixAction(action: _execPostfix, text: '2'),
                _CalculatorPostfixAction(action: _execPostfix, text: '5'),
                _CalculatorPostfixAction(action: _execPostfix, text: '8'),
                _CalculatorPostfixAction(action: _execPostfix, text: '0'),
              ]),
              Column(mainAxisSize: MainAxisSize.min, children: [
                _CalculatorPostfixAction(action: _execPostfix, text: '3'),
                _CalculatorPostfixAction(action: _execPostfix, text: '6'),
                _CalculatorPostfixAction(action: _execPostfix, text: '9'),
                _CalculatorAction(
                  key: const Key('cashier.calculator.dot'),
                  action: _execDot,
                  child: const Text('.'),
                ),
              ]),
              Column(mainAxisSize: MainAxisSize.min, children: [
                _CalculatorAction(
                  key: const Key('cashier.calculator.plus'),
                  action: () => _addOperator('+'),
                  color: theme.colorScheme.secondary,
                  child: const Icon(Icons.add_sharp),
                ),
                _CalculatorAction(
                  key: const Key('cashier.calculator.minus'),
                  action: () => _addOperator('-'),
                  color: theme.colorScheme.secondary,
                  child: const Icon(Icons.remove_sharp),
                ),
                _CalculatorAction(
                  key: const Key('cashier.calculator.times'),
                  action: () => _addOperator('x'),
                  color: theme.colorScheme.secondary,
                  child: const Icon(Icons.clear_sharp),
                ),
                _CalculatorAction(
                  key: const Key('cashier.calculator.ceil'),
                  action: _execCeil,
                  color: theme.colorScheme.secondary,
                  child: const Icon(Icons.merge_type_rounded),
                ),
              ]),
              Column(mainAxisSize: MainAxisSize.min, children: [
                _CalculatorAction(
                  key: const Key('cashier.calculator.back'),
                  action: _execBack,
                  color: theme.colorScheme.error,
                  child: const Icon(Icons.arrow_back_rounded),
                ),
                _CalculatorAction(
                  key: const Key('cashier.calculator.clear'),
                  action: _execClear,
                  color: theme.colorScheme.error,
                  child: const Icon(Icons.refresh_sharp),
                ),
                _CalculatorAction(
                  key: const Key('cashier.calculator.submit'),
                  action: _execSubmit,
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

  @override
  void initState() {
    super.initState();
    Cart.instance.currentPaid.addListener(_onPaidChanged);
  }

  @override
  void dispose() {
    Cart.instance.currentPaid.removeListener(_onPaidChanged);
    super.dispose();
  }

  String get text => paidState.currentState?.text ?? '';

  set text(String value) {
    String? changeText = '';

    if (value.isNotEmpty) {
      final paid = _calc(value);
      final change = paid - widget.totalPrice;

      changeText = change >= 0 ? change.toCurrency() : null;
      Cart.instance.currentPaid.value = paid;
    } else {
      Cart.instance.currentPaid.value = null;
    }

    paidState.currentState?.text = value;
    changeState.currentState?.text = changeText;
  }

  void _addOperator(String operator) {
    if (text.isNotEmpty) {
      text = _calc(text).toCurrency() + operator;
      setState(() {
        isOperating = true;
      });
    }
  }

  void _execCeil() {
    final price = _calc(text, widget.totalPrice.toInt());
    final ceilPrice = CurrencySetting.instance.ceil(price);
    text = ceilPrice.toCurrency();
  }

  void _execBack() {
    if (text.isNotEmpty) {
      text = text.substring(0, text.length - 1);
      setState(() {
        isOperating = _operators.any((o) => text.contains(o));
      });
    }
  }

  void _execClear() {
    text = '';
    setState(() {
      isOperating = false;
    });
  }

  void _execSubmit() {
    if (isOperating) {
      setState(() {
        isOperating = false;
      });
      text = _calc(text).toCurrency();
    } else {
      widget.onSubmit();
    }
  }

  void _execDot() {
    if (text.isEmpty) {
      text = '0.';
      return;
    }

    if (!text.contains('.')) {
      text = '$text.';
    }
  }

  void _execPostfix(String postfix) {
    text = text + postfix;
  }

  num _calc(String val, [num other = 0]) {
    final fallback = num.tryParse(val) ?? other;
    try {
      final operator = _operators.firstWhere((o) => val.contains(o));
      final parts = val.split(operator).map((e) => num.tryParse(e)).toList();

      switch (operator) {
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

  _onPaidChanged() {
    final paid = Cart.instance.currentPaid.value;
    paidState.currentState?.text = paid?.toCurrency() ?? '';
    changeState.currentState?.text =
        paid == null ? '' : (paid - widget.totalPrice).toCurrency();
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

  final String id;

  const _SingleField({
    Key? key,
    required this.id,
    required this.prefix,
    required this.defaultText,
    required this.errorText,
  }) : super(key: key);

  @override
  State<_SingleField> createState() => _SingleFieldState();
}

class _SingleFieldState extends State<_SingleField> {
  String? _text = '';

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(widget.prefix),
      _text == null
          ? Text(widget.errorText, key: Key('${widget.id}.error'))
          : _text!.isEmpty
              ? Text(widget.defaultText, key: Key('${widget.id}.hint'))
              : Text(_text!, key: Key(widget.id)),
    ]);
  }

  String? get text => _text;

  set text(String? value) {
    setState(() => _text = value);
  }
}
