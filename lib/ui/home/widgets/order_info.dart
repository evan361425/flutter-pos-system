import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:simple_tip/simple_tip.dart';

class OrderInfo extends StatelessWidget {
  static final _metadata = GlobalKey<_OrderMetadataState>();

  const OrderInfo({Key? key}) : super(key: key);

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
            title: S.homeIcons('order'),
            message: S.homeIconTutorial('order'),
            id: 'order',
            version: 1,
            order: 99,
            child: ElevatedButton(
              key: const Key('home.order'),
              onPressed: () => Navigator.of(context).pushNamed(Routes.order),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(kSpacing5),
              ),
              child: Text(S.homeIcons('order'),
                  style: const TextStyle(fontSize: 32.0)),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderMetadata extends StatefulWidget {
  const _OrderMetadata({Key? key}) : super(key: key);

  @override
  _OrderMetadataState createState() => _OrderMetadataState();
}

class _OrderMetadataState extends State<_OrderMetadata> {
  String? count;
  String? revenue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _column(S.homeOrderInfoTodayCount, count),
        const SizedBox(width: 64.0),
        _column(S.homeOrderInfoTodayEarn, revenue),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final seller = context.watch<Seller>();
    _queryValue(seller);
  }

  Expanded _column(String title, String? value) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(title, textAlign: TextAlign.center),
          Text(
            value ?? '...',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20.0),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _queryValue(Seller seller) async {
    final result = await seller.getMetricBetween();
    setState(() {
      revenue = result['totalPrice']!.toCurrency();
      count = result['count'].toString();
    });
  }
}
