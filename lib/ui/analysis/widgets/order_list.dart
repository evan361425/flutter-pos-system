import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/providers/currency_provider.dart';

import 'order_modal.dart';

class OrderList extends StatefulWidget {
  OrderList({Key? key, required this.handleLoad}) : super(key: key);

  final Future<List<OrderObject>> Function(Map<String, Object>, int) handleLoad;

  @override
  OrderListState createState() => OrderListState();
}

class OrderListState extends State<OrderList> {
  final List<OrderObject> _data = [];
  late Map<String, Object> _params;
  num totalPrice = 0;
  OrderListStatus _status = OrderListStatus.concealing;
  bool isFinish = false;

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

    final revenue = CurrencyProvider.instance.numToString(totalPrice);

    return Column(
      children: [
        Center(
          child: Text('總收入：$revenue', style: Theme.of(context).textTheme.muted),
        ),
        Expanded(
          child: LoadMore(
              onLoadMore: _handleLoad,
              isFinish: isFinish,
              textBuilder: (status) {
                switch (status) {
                  case LoadMoreStatus.idle:
                    return 'Loading...';
                  case LoadMoreStatus.loading:
                    return '...';
                  case LoadMoreStatus.fail:
                    return 'failed';
                  case LoadMoreStatus.nomore:
                    return 'finish';
                }
              },
              child: ListView.builder(
                itemBuilder: (context, index) => _orderTile(_data[index]),
                itemCount: _data.length,
              )),
        ),
      ],
    );
  }

  void reset(Map<String, Object> params, num totalPrice) {
    this.totalPrice = totalPrice;
    _params = params;
    _data.clear();
    status = OrderListStatus.loading;
    _handleLoad();
  }

  Future<bool> _handleLoad() async {
    try {
      final data = await widget.handleLoad(_params, _data.length);
      _data.addAll(data);

      setState(() {
        _status = OrderListStatus.revealing;
        isFinish = data.isEmpty;
      });

      return true;
    } catch (e) {
      error(e.toString(), 'analysis.load.error');
      return false;
    }
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
