import 'package:flutter/material.dart';
import 'package:possystem/components/style/radio_text.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class OrderCashierSnapshot extends StatelessWidget {
  final num totalPrice;

  final void Function(num) onPaidChanged;

  final selector = GlobalKey<_PaidMoneySelectorState>();

  final changeShower = GlobalKey<_ChangeShowerState>();

  OrderCashierSnapshot({
    Key? key,
    required this.totalPrice,
    required this.onPaidChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final options = <num>[totalPrice];

    var value = totalPrice;
    var ceiledValue = CurrencySetting.instance.ceil(value);
    while (ceiledValue != value) {
      options.add(ceiledValue);
      value = ceiledValue;
      ceiledValue = CurrencySetting.instance.ceil(ceiledValue);
    }

    return Row(children: <Widget>[
      Expanded(
        child: _PaidMoneySelector(
          key: selector,
          onChanged: _updatePaid,
          options: options,
        ),
      ),
      const SizedBox(width: 8.0),
      _ChangeShower(
        key: changeShower,
        value: 0,
      ),
    ]);
  }

  void paidChanged(num? value) {
    value = value ?? totalPrice;
    if (selector.currentState?.selected != value) {
      selector.currentState?.select(value);
      final change = value - totalPrice;

      if (change >= 0) {
        selector.currentState?.setAttributeCost(value);
        changeShower.currentState?.change(change);
      }
    }
  }

  void _updatePaid(num value) {
    changeShower.currentState?.change(value - totalPrice);
    onPaidChanged(value);
  }
}

class _ChangeShower extends StatefulWidget {
  final num value;

  const _ChangeShower({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  _ChangeShowerState createState() => _ChangeShowerState();
}

class _ChangeShowerState extends State<_ChangeShower> {
  late num value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        S.orderCashierSnapshotChangeField(value),
        key: const Key('cashier.snapshot.change'),
      ),
    );
  }

  void change(num value) {
    setState(() => this.value = value);
  }

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }
}

class _PaidMoneySelector extends StatefulWidget {
  final List<num> options;

  final void Function(num) onChanged;

  const _PaidMoneySelector({
    Key? key,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  _PaidMoneySelectorState createState() => _PaidMoneySelectorState();
}

class _PaidMoneySelectorState extends State<_PaidMoneySelector> {
  late num selected;

  num? attributeCost;

  @override
  Widget build(BuildContext context) {
    final data = <num>[
      if (attributeCost != null) attributeCost!,
      ...widget.options,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: <Widget>[
        for (final option in data)
          Container(
            key: Key('cashier.snapshot.$option'),
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: RadioText(
              onChanged: (_) {
                select(option);
                widget.onChanged(option);
              },
              isSelected: selected == option,
              text: option.toCurrency(),
            ),
          ),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
    selected = widget.options.first;
  }

  void select(num select) {
    setState(() => selected = select);
  }

  void setAttributeCost(num attributeCost) {
    widget.options.contains(attributeCost)
        ? setState(() => this.attributeCost = null)
        : setState(() => this.attributeCost = attributeCost);
  }
}
