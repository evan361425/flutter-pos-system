import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OrderLoader extends StatefulWidget {
  final DateTimeRange range;

  final Widget Function(OrderObject) formatOrder;

  const OrderLoader({
    Key? key,
    required this.range,
    required this.formatOrder,
  }) : super(key: key);

  @override
  State<OrderLoader> createState() => OrderLoaderState();

  static String formatCreatedAt(OrderObject order) {
    return '${DateFormat.yMMMd(S.localeName).format(order.createdAt)}'
        ' '
        '${DateFormat.Hm(S.localeName).format(order.createdAt)}';
  }

  static String formatHeader(OrderObject order) {
    return [
      '${order.totalCount} 份餐點',
      '共 ${order.totalPrice.toCurrency()} 元',
    ].join(MetaBlock.string);
  }
}

class OrderLoaderState extends State<OrderLoader> {
  late final RefreshController _scrollController;

  final List<OrderObject> orders = [];

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _scrollController,
      enablePullUp: true,
      enablePullDown: false,
      onLoading: _loadData,
      footer: _buildFooter(),
      child: ListView.builder(
        itemBuilder: (context, index) => _buildOrder(orders[index], index),
        itemCount: orders.length,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollController = RefreshController();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final future = Seller.instance
        .getOrderBetween(
      widget.range.start,
      widget.range.end,
      offset: orders.length,
      desc: false,
    )
        .then((data) {
      if (data.length != 10) {
        _scrollController.loadNoData();
      } else {
        _scrollController.loadComplete();
      }
      setState(() {
        orders.addAll(data);
      });
    });
    showSnackbarWhenFailed(future, context, 'export_load_order');
  }

  Widget? _buildOrder(OrderObject order, int index) {
    return ExpansionTile(
      leading: CircleAvatar(child: Text((index + 1).toString())),
      title: Text(OrderLoader.formatCreatedAt(order)),
      subtitle: Text(OrderLoader.formatHeader(order)),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.formatOrder(order),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return CustomFooter(
      height: 30,
      builder: (BuildContext context, LoadStatus? mode) {
        switch (mode) {
          case LoadStatus.idle:
            return const Center(child: Text('下拉以載入更多'));
          case LoadStatus.canLoading:
          case LoadStatus.loading:
            return const CircularLoading();
          case LoadStatus.noMore:
            return const Center(child: Text('讀取完畢'));
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
