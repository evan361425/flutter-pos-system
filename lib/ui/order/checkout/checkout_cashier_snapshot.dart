import 'package:flutter/material.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class CheckoutCashierSnapshot extends StatefulWidget {
  final ValueNotifier<num> price;

  final ValueNotifier<num> paid;

  const CheckoutCashierSnapshot({
    super.key,
    required this.price,
    required this.paid,
  });

  @override
  State<CheckoutCashierSnapshot> createState() => _CheckoutCashierSnapshotState();
}

class _CheckoutCashierSnapshotState extends State<CheckoutCashierSnapshot> {
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
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 8.0, 0),
        child: SizedBox(
          height: double.infinity,
          child: Center(
            child: Text(S.orderCheckoutCashierSnapshotLabelChange(change.toCurrency())),
          ),
        ),
      ),
    ]);
  }

  List<num> get paidOptionWithCustom => [if (customValue != null) customValue!, ...paidOptions];

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
