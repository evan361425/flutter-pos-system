import 'package:flutter/material.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class OrderCashierSnapshot extends StatefulWidget {
  final num totalPrice;

  const OrderCashierSnapshot({
    Key? key,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<OrderCashierSnapshot> createState() => _OrderCashierSnapshotState();
}

class _OrderCashierSnapshotState extends State<OrderCashierSnapshot> {
  late num currentChange;
  late num currentPaid;
  num? customValue;
  late final List<num> paidOptions;

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
                  selected: currentPaid == option,
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
          S.orderCashierSnapshotChangeField(currentChange),
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
    currentPaid = widget.totalPrice;
    currentChange = 0;
    paidOptions = CurrencySetting.instance.ceilToMaximum(currentPaid).toList();
    Cart.instance.currentPaid.addListener(_onPaidChanged);
  }

  @override
  void dispose() {
    Cart.instance.currentPaid.removeListener(_onPaidChanged);
    super.dispose();
  }

  void _changePaid(num value) {
    final change = value - widget.totalPrice;
    if (currentPaid != value && change >= 0) {
      Cart.instance.currentPaid.value = value;
    }
  }

  void _onPaidChanged() {
    setState(() {
      final paid = Cart.instance.currentPaid.value ?? widget.totalPrice;
      currentChange = paid - widget.totalPrice;
      currentPaid = paid;
      if (!paidOptions.contains(paid)) {
        customValue = paid;
      } else if (Cart.instance.currentPaid.value == null) {
        customValue = null;
      }
    });
  }
}
