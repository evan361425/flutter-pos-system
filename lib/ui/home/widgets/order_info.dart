import 'package:flutter/material.dart';
import 'package:possystem/components/tip_radio.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class OrderInfo extends StatelessWidget {
  const OrderInfo({Key? key}) : super(key: key);

  static final _metadata = GlobalKey<_OrderMetadataState>();

  static void resetMetadata() {
    _metadata.currentState?.reset();
  }

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
        TipRadio(
          groupId: 'home',
          title: tt('home.order'),
          message: tt('home.tutorial.order'),
          id: 'order',
          version: 1,
          order: 99,
          child: Positioned(
            bottom: 0,
            child: ElevatedButton(
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

  void _queryValue() async {
    final result = await Seller.instance.getMetricBetween();

    setState(() {
      revenue = CurrencyProvider.instance.numToString(result['totalPrice']!);
      count = (result['count'] as int?)?.toString();
    });
  }
}
