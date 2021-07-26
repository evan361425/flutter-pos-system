import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class OrderInfo extends StatefulWidget {
  static GlobalKey orderButton = GlobalKey();

  const OrderInfo({Key? key}) : super(key: key);

  @override
  OrderInfoState createState() => OrderInfoState();
}

class OrderInfoState extends State<OrderInfo> {
  String? count;
  String? revenue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Card(
          margin: const EdgeInsets.only(bottom: 32.0),
          child: Padding(
            padding: const EdgeInsets.all(kSpacing1),
            child: Row(
              children: <Widget>[
                _column(tt('home.today_order'), count, theme),
                const SizedBox(width: 64.0),
                _column(tt('home.today_price'), revenue, theme),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: ElevatedButton(
            key: OrderInfo.orderButton,
            onPressed: () => Navigator.of(context).pushNamed(Routes.order),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: const EdgeInsets.all(kSpacing3),
            ),
            child: Text(tt('home.order'), style: TextStyle(fontSize: 32.0)),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _queryValue();
  }

  void reset() {
    setState(() {
      count = null;
      revenue = null;
      _queryValue();
    });
  }

  Expanded _column(String title, String? value, ThemeData theme) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(title, textAlign: TextAlign.center),
          Text(
            value ?? '...',
            textAlign: TextAlign.center,
            style: theme.textTheme.headline3,
          ),
        ],
      ),
    );
  }

  void _queryValue() async {
    final result = await Seller.instance.getMetricBetween();

    setState(() {
      revenue = CurrencyProvider.instance.numToString(result['totalPrice']!);
      count = (result['count'] as int?)?.toString();
    });
  }
}
