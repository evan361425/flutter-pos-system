import 'package:flutter/material.dart';
import 'package:possystem/components/item_loader.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class OrderLoader extends StatefulWidget {
  final ValueNotifier<DateTimeRange> ranger;

  final Widget Function(BuildContext, OrderObject) builder;

  final Widget Function(BuildContext, OrderMetrics)? trailingBuilder;

  final bool countingAll;

  const OrderLoader({
    super.key,
    required this.ranger,
    required this.builder,
    this.trailingBuilder,
    this.countingAll = false,
  });

  @override
  State<OrderLoader> createState() => _OrderLoaderState();
}

class _OrderLoaderState extends State<OrderLoader> {
  @override
  Widget build(BuildContext context) {
    return ItemLoader<OrderObject, OrderMetrics>(
      prototypeItem: widget.builder(
        context,
        OrderObject(createdAt: DateTime.now()),
      ),
      notifier: widget.ranger,
      loader: _loadOrders,
      metricsLoader: _loadMetrics,
      builder: widget.builder,
      metricsBuilder: (metrics) {
        final meta = MetaBlock.withString(context, [
          S.orderLoaderMetaTotalPrice(metrics.price.toCurrency()),
          '總成本：${metrics.cost.toCurrency()}',
          S.orderLoaderMetaTotalCount(metrics.count),
        ])!;
        return Row(children: [
          Expanded(child: Center(child: meta)),
          if (widget.trailingBuilder != null) buildTrailing(metrics),
        ]);
      },
      emptyChild: HintText(S.orderLoaderEmpty),
    );
  }

  @override
  void initState() {
    super.initState();
    Seller.instance.addListener(_reloadOrders);
  }

  @override
  void dispose() {
    Seller.instance.removeListener(_reloadOrders);
    super.dispose();
  }

  Widget buildTrailing(OrderMetrics metrics) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: widget.trailingBuilder!(context, metrics),
    );
  }

  void _reloadOrders() {
    final start = widget.ranger.value.start;
    widget.ranger.value = DateTimeRange(
      // add/minus one second, 00:00:00 -> 00:00:01; 00:00:59 -> 00:00:58
      start: start.add(Duration(seconds: 1 - (start.second % 2) * 2)),
      end: widget.ranger.value.end,
    );
  }

  Future<OrderMetrics> _loadMetrics() {
    return Seller.instance.getMetrics(
      widget.ranger.value.start,
      widget.ranger.value.end,
      countingAll: widget.countingAll,
    );
  }

  Future<List<OrderObject>> _loadOrders(int offset) {
    return Seller.instance.getOrders(
      widget.ranger.value.start,
      widget.ranger.value.end,
      offset: offset,
    );
  }
}
