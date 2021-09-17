import 'package:flutter/material.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/providers/currency_provider.dart';

class CashierQuickChanger extends StatefulWidget {
  final num totalPrice;

  CashierQuickChanger({
    Key? key,
    required this.totalPrice,
  }) : super(key: key);

  @override
  CashierQuickChangerState createState() => CashierQuickChangerState();
}

class CashierQuickChangerState extends State<CashierQuickChanger> {
  final options = <num>[];

  late num selected;

  num? customPaid;

  /// Change value
  ///
  /// changeValue = paid - [widget.totalPrice]
  num changeValue = 0;

  @override
  Widget build(BuildContext context) {
    final paidOptions = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: <Widget>[
        if (customPaid != null) radioBuilder(customPaid!),
        for (final option in options) radioBuilder(option),
      ]),
    );

    return Row(children: <Widget>[
      Expanded(child: paidOptions),
      const SizedBox(width: 16.0),
      OutlinedText(changeValue.toString()),
    ]);
  }

  @override
  void initState() {
    super.initState();
    selected = widget.totalPrice;
    options.add(widget.totalPrice);
    options.add(CurrencyProvider.instance.ceil(widget.totalPrice));
  }

  void paidChanged(num? value) {
    if (value == null) {
      return _updatePaid(widget.totalPrice);
    }

    customPaid = options.contains(value) ? null : value;
    _updatePaid(value);
  }

  Widget radioBuilder(num value) {
    return RadioText(
      groupId: 'cashier.quick_changer',
      onSelected: (bool isSelected) => _updatePaid(value),
      isSelected: selected == value,
      text: value.toString(),
      value: value.toString(),
    );
  }

  void _updatePaid(num value) {
    if (selected != value) {
      final last = options[options.length - 1];
      // if select last value, add ceil value on options
      if (last == value) {
        final ceiledValue = CurrencyProvider.instance.ceil(value);
        // avoid unlimit adding ceil value
        if (ceiledValue != last) options.add(ceiledValue);
      }
      setState(() {
        selected = value;
        changeValue = value - widget.totalPrice;
      });
    }
  }
}
