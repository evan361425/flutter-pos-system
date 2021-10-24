import 'package:flutter/material.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/providers/currency_provider.dart';

class OrderCashierSnapshot extends StatefulWidget {
  final num totalPrice;

  final void Function(num) onPaidChanged;

  OrderCashierSnapshot({
    Key? key,
    required this.totalPrice,
    required this.onPaidChanged,
  }) : super(key: key);

  @override
  OrderCashierSnapshotState createState() => OrderCashierSnapshotState();
}

class OrderCashierSnapshotState extends State<OrderCashierSnapshot> {
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
      const SizedBox(width: 8.0),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text('找錢：$changeValue', key: Key('cashier.snapshot.change')),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    selected = widget.totalPrice;
    options.add(widget.totalPrice);

    var value = widget.totalPrice;
    var ceiledValue = CurrencyProvider.instance.ceil(value);
    while (ceiledValue != value) {
      options.add(ceiledValue);
      value = ceiledValue;
      ceiledValue = CurrencyProvider.instance.ceil(ceiledValue);
    }
  }

  void paidChanged(num? value) {
    if (value == null) {
      return _updatePaid(widget.totalPrice);
    }

    customPaid = options.contains(value) ? null : value;
    _updatePaid(value);
  }

  Widget radioBuilder(num value) {
    return Container(
      key: Key('cashier.snapshot.$value'),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: RadioText(
        groupId: 'cashier.quick_changer',
        onSelected: (bool isSelected) => _updatePaid(value),
        isSelected: selected == value,
        text: value.toString(),
        value: value.toString(),
      ),
    );
  }

  void _updatePaid(num value) {
    if (selected != value) {
      setState(() {
        selected = value;
        changeValue = value - widget.totalPrice;
        widget.onPaidChanged(selected);
      });
    }
  }
}
