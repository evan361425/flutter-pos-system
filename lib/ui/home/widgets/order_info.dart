import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/order_repo.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/routes.dart';

class OrderInfo extends StatefulWidget {
  const OrderInfo({Key? key}) : super(key: key);

  @override
  OrderInfoState createState() => OrderInfoState();
}

class OrderInfoState extends State<OrderInfo> {
  int? count;
  String? revenue;

  void reset() {
    setState(() {
      count = null;
      revenue = null;
      _queryValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle =
        theme.textTheme.headline3!.copyWith(color: theme.primaryColor);

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Card(
          margin: const EdgeInsets.only(bottom: 32.0),
          child: Padding(
            padding: const EdgeInsets.all(kSpacing1),
            child: Row(
              children: <Widget>[
                _column('今日單量', count?.toString(), textStyle),
                const SizedBox(width: 64.0),
                _column('今日營收', revenue?.toString(), textStyle),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(Routes.order),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: const EdgeInsets.all(kSpacing3),
            ),
            child: Text('點餐', style: theme.textTheme.headline4),
          ),
        ),
      ],
    );
  }

  void _queryValue() async {
    final result = await OrderRepo.instance.getMetricBetween();

    setState(() {
      revenue = CurrencyProvider.instance.numToString(result['totalPrice']!);
      count = result['count'] as int?;
    });
  }

  Expanded _column(String title, String? value, TextStyle textStyle) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(title, textAlign: TextAlign.center),
          Text(
            value ?? '...',
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _queryValue();
  }
}
