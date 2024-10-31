import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

const _operators = ['+', '-', 'x'];

class CheckoutCashierCalculator extends StatefulWidget {
  final VoidCallback onSubmit;

  final ValueNotifier<num> price;

  final ValueNotifier<num> paid;

  const CheckoutCashierCalculator({
    super.key,
    required this.onSubmit,
    required this.price,
    required this.paid,
  });

  @override
  State<CheckoutCashierCalculator> createState() => _CheckoutCashierCalculatorState();
}

class _CheckoutCashierCalculatorState extends State<CheckoutCashierCalculator> {
  final paidState = GlobalKey<_SingleFieldState>();
  final changeState = GlobalKey<_SingleFieldState>();

  bool isOperating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(children: [
      // avoid rounded border of accessor and causing overlapping.
      const SizedBox(height: 8.0),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(children: [
          _SingleField(
            key: paidState,
            id: 'cashier.calculator.paid',
            prefix: S.orderCheckoutDetailsCalculatorLabelPaid,
            defaultText: widget.price.value.toCurrency(),
            errorText: '',
          ),
          const Divider(),
          _SingleField(
            key: changeState,
            id: 'cashier.calculator.change',
            prefix: S.orderCheckoutDetailsCalculatorLabelChange,
            defaultText: '0',
            errorText: S.orderCheckoutSnackbarPaidFailed,
          ),
          const Divider(),
        ]),
      ),
      Expanded(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: kFABSpacing),
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
                    child: const Icon(Icons.add_outlined, size: 24),
                  ),
                  _CalculatorAction(
                    key: const Key('cashier.calculator.minus'),
                    action: () => _addOperator('-'),
                    color: theme.colorScheme.secondary,
                    child: const Icon(Icons.remove_outlined, size: 24),
                  ),
                  _CalculatorAction(
                    key: const Key('cashier.calculator.times'),
                    action: () => _addOperator('x'),
                    color: theme.colorScheme.secondary,
                    child: const Icon(Icons.clear_outlined, size: 24),
                  ),
                  _CalculatorAction(
                    key: const Key('cashier.calculator.ceil'),
                    action: _execCeil,
                    color: theme.colorScheme.secondary,
                    child: const Icon(Icons.merge_type_rounded, size: 24),
                  ),
                ]),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  _CalculatorAction(
                    key: const Key('cashier.calculator.back'),
                    action: _execBack,
                    color: theme.colorScheme.error,
                    child: const Icon(Icons.arrow_back_rounded, size: 24),
                  ),
                  _CalculatorAction(
                    key: const Key('cashier.calculator.clear'),
                    action: _execClear,
                    color: theme.colorScheme.error,
                    child: const Icon(Icons.refresh_outlined, size: 24),
                  ),
                  _CalculatorAction(
                    key: const Key('cashier.calculator.submit'),
                    action: _execSubmit,
                    height: 124,
                    child: isOperating ? const Text('=') : const Icon(Icons.check_outlined, size: 24),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    widget.paid.addListener(_onNotify);
  }

  @override
  void dispose() {
    widget.paid.removeListener(_onNotify);
    super.dispose();
  }

  String get text => paidState.currentState?.text ?? '';

  set text(String value) {
    String? changeText = '';

    if (value.isNotEmpty) {
      final paid = _calc(value);
      final change = paid - widget.price.value;

      changeText = change >= 0 ? change.toCurrencyLong() : null;
      widget.paid.value = paid;
    } else {
      widget.paid.value = widget.price.value;
    }

    paidState.currentState?.text = value;
    changeState.currentState?.text = changeText;
  }

  void _addOperator(String operator) {
    if (text.isNotEmpty) {
      text = _calc(text).toCurrencyLong() + operator;
      setState(() {
        isOperating = true;
      });
    }
  }

  void _execCeil() {
    final price = _calc(text, widget.price.value.toInt());
    final ceilPrice = CurrencySetting.instance.ceil(price);
    text = ceilPrice.toCurrencyLong();
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
      text = _calc(text).toCurrencyLong();
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

  _onNotify() {
    text = _calc(widget.paid.value.toCurrencyLong()).toCurrencyLong();
  }
}

class _CalculatorAction extends StatelessWidget {
  final VoidCallback action;

  final double height;

  final Color? color;

  final Widget child;

  const _CalculatorAction({
    super.key,
    required this.action,
    required this.child,
    this.height = 60,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        width: 60,
        height: height,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            padding: EdgeInsets.zero,
          ),
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
    super.key,
    required this.id,
    required this.prefix,
    required this.defaultText,
    required this.errorText,
  });

  @override
  State<_SingleField> createState() => _SingleFieldState();
}

class _SingleFieldState extends State<_SingleField> {
  String? _text = '';

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(widget.prefix),
      const Spacer(),
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
