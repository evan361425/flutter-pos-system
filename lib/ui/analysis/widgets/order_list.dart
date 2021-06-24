import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'order_modal.dart';

class OrderList extends StatefulWidget {
  final Future<List<OrderObject>> Function(Map<String, Object>, int) handleLoad;

  OrderList({Key? key, required this.handleLoad}) : super(key: key);

  @override
  OrderListState createState() => OrderListState();
}

class OrderListState extends State<OrderList> {
  final _scrollController = RefreshController();

  final List<OrderObject> _data = [];
  late Map<String, Object> _params;
  bool? _isLoading;

  num totalPrice = 0;

  @override
  Widget build(BuildContext context) {
    if (_isLoading == true) {
      return CircularLoading();
    } else if (_isLoading == null) {
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
          child: SmartRefresher(
              controller: _scrollController,
              enablePullUp: true,
              enablePullDown: false,
              onLoading: () => _handleLoad(),
              footer: CustomFooter(
                height: 30,
                onClick: () => setState(() {
                  _data.clear();
                  _isLoading = true;
                }),
                builder: (BuildContext context, LoadStatus? mode) {
                  if (mode == LoadStatus.loading) {
                    return CircularLoading();
                  } else if (mode == LoadStatus.failed) {
                    Center(child: Text('糟糕！發生錯誤了'));
                  } else if (mode == LoadStatus.canLoading) {
                    return Center(child: Text('放開以讀取更多'));
                  }
                  return Container();
                },
              ),
              child: ListView.builder(
                itemBuilder: (context, index) => _itemBuilder(_data[index]),
                itemCount: _data.length,
              )),
        ),
      ],
    );
  }

  void reset(Map<String, Object> params, num totalPrice) {
    this.totalPrice = totalPrice;
    setState(() {
      _params = params;
      _data.clear();
      _isLoading = true;
    });
    _handleLoad();
  }

  Future<void> _handleLoad() async {
    final data = await widget.handleLoad(_params, _data.length);

    _data.addAll(data);
    data.isEmpty
        ? _scrollController.loadNoData()
        : _scrollController.loadComplete();

    setState(() => _isLoading = false);
  }

  Widget _itemBuilder(OrderObject order) {
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