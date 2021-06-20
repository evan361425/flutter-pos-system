import 'package:flutter/material.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/providers/currency_provider.dart';

import 'order_modal.dart';

class OrderList extends StatefulWidget {
  OrderList({Key? key}) : super(key: key);

  @override
  OrderListState createState() => OrderListState();
}

class OrderListState extends State<OrderList> {
  late List<OrderObject> _data;
  late OrderListStatus _status = OrderListStatus.concealing;

  set status(OrderListStatus status) => setState(() => _status = status);

  @override
  Widget build(BuildContext context) {
    if (_status == OrderListStatus.loading) {
      return CircularLoading();
    } else if (_status == OrderListStatus.concealing) {
      return Text('點擊日期來查看紀錄', style: Theme.of(context).textTheme.muted);
    } else if (_data.isEmpty) {
      return Text('本日無點餐紀錄', style: Theme.of(context).textTheme.muted);
    }

    return ListView.builder(
      itemBuilder: (context, index) => _orderTile(_data[index]),
      itemCount: _data.length,
    );
  }

  Future<void> load(Future<List<OrderObject>> loader) {
    status = OrderListStatus.loading;

    return loader.then((data) => setState(() {
          _status = OrderListStatus.revealing;
          _data = data;
        }));
  }

  void hide() => status = OrderListStatus.concealing;

  Widget _orderTile(OrderObject order) {
    final title = order.products.map<String>((e) {
      final count = e.count > 1 ? ' * ${e.count}' : '';
      return '${e.productName}$count';
    }).join('、');
    final hour = order.createdAt.hour.toString().padLeft(2, '0');
    final minute = order.createdAt.minute.toString().padLeft(2, '0');

    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(top: kSpacing1),
        child: Text('$hour:$minute'),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: MetaBlock.withString(context, [
        '總價：${CurrencyProvider.instance.numToString(order.totalPrice)}',
        '付額：${CurrencyProvider.instance.numToString(order.paid!)}',
      ]),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderModal(order: order)),
      ),
    );
  }
}

enum OrderListStatus {
  loading,
  concealing,
  revealing,
}
