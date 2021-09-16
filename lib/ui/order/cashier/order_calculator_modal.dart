import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/translator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'order_final_list.dart';

class OrderCalculatorModal extends StatefulWidget {
  const OrderCalculatorModal({Key? key}) : super(key: key);

  @override
  _OrderCalculatorModalState createState() => _OrderCalculatorModalState();
}

class _CalculatorAction extends StatelessWidget {
  final VoidCallback action;

  final Widget child;

  const _CalculatorAction({required this.action, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: OutlinedButton(
          onPressed: action,
          child: child,
        ),
      ),
    );
  }
}

class _CalculatorPostfixAction extends StatelessWidget {
  final String text;
  final void Function(String) action;
  const _CalculatorPostfixAction({required this.text, required this.action});

  @override
  Widget build(BuildContext context) {
    return _CalculatorAction(
      action: () => action(text),
      child: Text(text),
    );
  }
}

class _MoneyInfo extends StatefulWidget {
  final num totalPrice;

  _MoneyInfo({Key? key, required this.totalPrice}) : super(key: key);

  @override
  _MoneyInfoState createState() => _MoneyInfoState();
}

class _MoneyInfoState extends State<_MoneyInfo> {
  String? errorMessage;

  late TextEditingController paidController;
  late TextEditingController changeController;

  /// money pay to customer when paid is more then price
  num get change {
    final paid = paidNum;
    return paid == null ? 0 : paid - widget.totalPrice;
  }

  num? get paidNum => num.tryParse(paidText);

  String get paidText => paidController.text;

  set paidText(String text) {
    paidController.text = text;
    if (errorMessage != null) {
      setState(() => errorMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headline4 = Theme.of(context).textTheme.headline4;

    return Container(
      padding: const EdgeInsets.all(kSpacing2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SingleField(
            title: tt('order.cashier.price'),
            child: Text(
              widget.totalPrice.toString(),
              textAlign: TextAlign.right,
              style: headline4,
            ),
          ),
          _SingleField(
            title: tt('order.cashier.change'),
            child: TextField(
              readOnly: true,
              style: headline4,
              controller: changeController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          _SingleField(
            title: tt('order.cashier.paid'),
            child: TextField(
              readOnly: true,
              style: headline4,
              controller: paidController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintText: widget.totalPrice.toString(),
                errorText: errorMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    paidController.dispose();
    changeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    paidController = TextEditingController();
    changeController = TextEditingController(text: '0');

    paidController.addListener(() {
      changeController.text =
          change <= 0 ? '0' : CurrencyProvider.instance.numToString(change);
    });
  }

  void setupError(String message) => setState(() => errorMessage = message);
}

class _OrderCalculatorModalState extends State<OrderCalculatorModal> {
  final infoState = GlobalKey<_MoneyInfoState>();

  @override
  Widget build(BuildContext context) {
    final panel = Padding(
      padding: const EdgeInsets.fromLTRB(kSpacing0, 80, kSpacing0, kSpacing0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            _CalculatorPostfixAction(action: execPostfix, text: '1'),
            _CalculatorPostfixAction(action: execPostfix, text: '2'),
            _CalculatorPostfixAction(action: execPostfix, text: '3'),
            _CalculatorAction(action: execClear, child: Icon(KIcons.clear)),
          ]),
          Row(children: [
            _CalculatorPostfixAction(action: execPostfix, text: '4'),
            _CalculatorPostfixAction(action: execPostfix, text: '5'),
            _CalculatorPostfixAction(action: execPostfix, text: '6'),
            _CalculatorAction(
                action: execBack, child: Icon(Icons.arrow_back_rounded)),
          ]),
          Row(children: [
            _CalculatorPostfixAction(action: execPostfix, text: '7'),
            _CalculatorPostfixAction(action: execPostfix, text: '8'),
            _CalculatorPostfixAction(action: execPostfix, text: '9'),
            _CalculatorAction(
                action: execCeil, child: Icon(Icons.merge_type_rounded)),
          ]),
          Row(children: [
            Spacer(),
            _CalculatorPostfixAction(action: execPostfix, text: '0'),
            CurrencyProvider.instance.isInt
                ? Spacer()
                : _CalculatorAction(action: execDot, child: Text('0')),
            _CalculatorAction(action: paid, child: Icon(Icons.done_rounded)),
          ]),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: PopButton(),
        title: Text('計算機'),
        actions: [
          TextButton(onPressed: () {}, child: Text('結帳')),
        ],
      ),
      body: SlidingUpPanel(
        body: OrderFinalList(),
        panel: panel,
        collapsed: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Placeholder()),
            Text('找額'),
          ],
        ),
      ),
    );
  }

  /// Confirm leaving history mode
  Future<bool> confirmChangeHistory() async {
    if (!Cart.instance.isHistoryMode) return true;

    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: tt('order.cashier.confirm.leave_history'),
      ),
    );

    return result ?? false;
  }

  void execBack() {
    final paid = infoState.currentState?.paidText;
    if (paid?.isNotEmpty == true) {
      infoState.currentState?.paidText = paid!.substring(0, paid.length - 1);
    }
  }

  void execCeil() {
    final paid = infoState.currentState?.paidNum ?? Cart.instance.totalPrice;
    final ceilPrice = CurrencyProvider.instance.ceil(paid);
    infoState.currentState?.paidText =
        CurrencyProvider.instance.numToString(ceilPrice);
  }

  void execClear() {
    infoState.currentState?.paidText = '';
  }

  void execDot() {
    final paid = infoState.currentState?.paidText;

    if (paid?.isNotEmpty == true) {
      if (!paid!.contains('.')) {
        infoState.currentState?.paidText = paid + '.';
      }
    } else {
      infoState.currentState?.paidText = '0.';
    }
  }

  void execPostfix(String postfix) {
    final paid = infoState.currentState?.paidText ?? '';
    infoState.currentState?.paidText = paid + postfix;
  }

  void paid() async {
    if (!await confirmChangeHistory()) {
      return;
    }

    try {
      await Cart.instance.paid(infoState.currentState?.paidNum);
      // send success message
      Navigator.of(context).pop(true);
    } catch (e) {
      if (e == 'too low') {
        infoState.currentState?.setupError(tt('order.cashier.error.low_paid'));
      } else {
        infoState.currentState?.setupError(e.toString());
      }
    }
  }
}

class _SingleField extends StatelessWidget {
  final String title;

  final Widget child;

  const _SingleField({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: kSpacing2),
          child: Text(title),
        ),
        Expanded(
          child: child,
        ),
      ],
    );
  }
}
