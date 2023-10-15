import 'package:flutter/material.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class OrderCashierSnapshot extends StatefulWidget {
  final ValueNotifier<num> price;

  final ValueNotifier<num> paid;

  const OrderCashierSnapshot({
    Key? key,
    required this.price,
    required this.paid,
  }) : super(key: key);

  @override
  State<OrderCashierSnapshot> createState() => _OrderCashierSnapshotState();
}

class _OrderCashierSnapshotState extends State<OrderCashierSnapshot> {
  num? customValue;
  late num change;
  late List<num> paidOptions;

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
        child: ListView(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          children: [
            for (final option in paidOptionWithCustom)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  key: Key('cashier.snapshot.$option'),
                  selected: widget.paid.value == option,
                  onSelected: (selected) {
                    if (selected) {
                      _changePaid(option);
                    }
                  },
                  label: Text(option.toCurrency()),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(width: 8.0),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          S.orderCashierSnapshotChangeField(change),
          key: const Key('cashier.snapshot.change'),
        ),
      ),
    ]);
  }

  List<num> get paidOptionWithCustom =>
      [if (customValue != null) customValue!, ...paidOptions];

  @override
  void initState() {
    super.initState();
    _reload();
    widget.paid.addListener(_onNotify);
  }

  @override
  void dispose() {
    widget.paid.removeListener(_onNotify);
    super.dispose();
  }

  void _changePaid(num value) {
    final change = value - widget.price.value;
    if (change >= 0) {
      // this will trigger reload.
      widget.paid.value = value;
    }
  }

  void _reload() {
    final price = widget.price.value;
    final paid = widget.paid.value;
    change = paid - price;
    paidOptions = CurrencySetting.instance.ceilToMaximum(price).toList();

    if (!paidOptions.contains(paid)) {
      customValue = paid;
    }
  }

  void _onNotify() {
    setState(() => _reload());
  }
}
