import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/translator.dart';
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
  int totalCount = 0;

  @override
  Widget build(BuildContext context) {
    if (_isLoading == true) {
      return CircularLoading();
    } else if (_isLoading == null) {
      return Text(
        tt('analysis.unset'),
        style: Theme.of(context).textTheme.muted,
      );
    } else if (_data.isEmpty) {
      return Text(
        tt('analysis.empty'),
        style: Theme.of(context).textTheme.muted,
      );
    }

    final totalPrice = CurrencyProvider.instance.numToString(this.totalPrice);

    return Column(
      children: [
        Center(
          child: MetaBlock.withString(
            context,
            [
              tt('home.total_price', {'price': totalPrice}),
              tt('home.total_order', {'count': totalCount}),
            ],
          ),
        ),
        Expanded(
          child: SmartRefresher(
              controller: _scrollController,
              enablePullUp: true,
              enablePullDown: false,
              onLoading: () => _handleLoad(),
              footer: _footerBuilder(),
              child: ListView.builder(
                itemBuilder: (context, index) => _itemBuilder(_data[index]),
                itemCount: _data.length,
              )),
        ),
      ],
    );
  }

  void reset(
    Map<String, Object> params, {
    required num totalPrice,
    required int totalCount,
  }) =>
      setState(() {
        this.totalPrice = totalPrice;
        this.totalCount = totalCount;
        _params = params;
        _data.clear();
        _isLoading = true;
        _handleLoad();
      });

  CustomFooter _footerBuilder() {
    return CustomFooter(
      height: 30,
      onClick: () => setState(() {
        _data.clear();
        _isLoading = true;
        _handleLoad();
      }),
      builder: (BuildContext context, LoadStatus? mode) {
        switch (mode) {
          case LoadStatus.canLoading:
          case LoadStatus.loading:
            return CircularLoading();
          case LoadStatus.failed:
            return Center(child: Text(tt('unknown_error')));
          case LoadStatus.noMore:
            return Center(child: Text(tt('analysis.allLoaded')));
          default:
            return Container();
        }
      },
    );
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
        tt('price', {'analysis.price': CurrencyProvider.n2s(order.totalPrice)}),
        tt('paid', {'analysis.paid': CurrencyProvider.n2s(order.paid!)}),
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
