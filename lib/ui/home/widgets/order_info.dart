import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:simple_tip/simple_tip.dart';

class OrderInfo extends StatelessWidget {
  const OrderInfo({Key? key}) : super(key: key);

  static final _metadata = GlobalKey<_OrderMetadataState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Card(
          margin: const EdgeInsets.only(bottom: 32.0),
          child: Padding(
            padding: const EdgeInsets.all(kSpacing1),
            child: _OrderMetadata(key: _metadata),
          ),
        ),
        Positioned(
          bottom: 0,
          child: OrderedTip(
            groupId: 'home',
            title: tt('home.order'),
            message: tt('home.tutorial.order'),
            id: 'order',
            version: 1,
            order: 99,
            child: ElevatedButton(
              key: Key('home.order'),
              onPressed: () => Navigator.of(context).pushNamed(Routes.order),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: const EdgeInsets.all(kSpacing5),
              ),
              child: Text(tt('home.order'), style: TextStyle(fontSize: 32.0)),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderMetadata extends StatefulWidget {
  _OrderMetadata({Key? key}) : super(key: key);

  @override
  _OrderMetadataState createState() => _OrderMetadataState();
}

class _OrderMetadataState extends State<_OrderMetadata> {
  String? count;
  String? revenue;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline3;
    return Row(
      children: <Widget>[
        _column(tt('home.today_order'), count, textStyle),
        const SizedBox(width: 64.0),
        _column(tt('home.today_price'), revenue, textStyle),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final seller = context.watch<Seller>();
    _queryValue(seller);
  }

  Expanded _column(String title, String? value, TextStyle? textStyle) {
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

  void _queryValue(Seller seller) async {
    final result = await seller.getMetricBetween();
    setState(() {
      revenue = CurrencyProvider.n2s(result['totalPrice']!);
      count = result['count'].toString();
    });
  }
}
