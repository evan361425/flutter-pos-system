import 'package:flutter/material.dart';
import 'package:possystem/components/item_loader.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';

class OrderLoader extends StatefulWidget {
  final ValueNotifier<DateTimeRange> ranger;

  final Widget Function(BuildContext, OrderObject) builder;

  final Widget? trailing;

  final Widget Function(BuildContext, OrderLoaderMetrics)? trailingBuilder;

  const OrderLoader({
    Key? key,
    required this.ranger,
    required this.builder,
    this.trailing,
    this.trailingBuilder,
  })  : assert(trailing != null || trailingBuilder != null,
            "trailing is required"),
        super(key: key);

  @override
  State<OrderLoader> createState() => _OrderLoaderState();
}

class _OrderLoaderState extends State<OrderLoader> {
  @override
  Widget build(BuildContext context) {
    return ItemLoader<OrderObject, OrderLoaderMetrics>(
      prototypeItem: widget.builder(context, OrderObject(products: const [])),
      notifier: widget.ranger,
      loader: _loadOrders,
      metricsLoader: _loadMetrics,
      builder: widget.builder,
      metricsBuilder: (metrics) {
        final meta = MetaBlock.withString(context, [
          S.orderListMetaPrice(metrics.price),
          S.orderListMetaCount(metrics.count),
        ])!;
        return Row(children: [
          Expanded(child: Center(child: meta)),
          widget.trailingBuilder != null
              ? widget.trailingBuilder!.call(context, metrics)
              : widget.trailing!,
          const SizedBox(width: 8.0),
        ]);
      },
      emptyChild: HintText(S.orderListEmpty),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Seller.instance.addListener(_reloadOrders);
  }

  @override
  void dispose() {
    Seller.instance.removeListener(_reloadOrders);
    super.dispose();
  }

  void _reloadOrders() {
    Log.ger("reload", "order_loader");
    final start = widget.ranger.value.start;
    widget.ranger.value = DateTimeRange(
      // add/minus one second, 00:00:00 -> 00:00:01; 00:00:59 -> 00:00:58
      start: start.add(Duration(seconds: 1 - (start.second % 2) * 2)),
      end: widget.ranger.value.end,
    );
  }

  Future<OrderLoaderMetrics> _loadMetrics() async {
    final result = await Seller.instance.getMetricBetween(
      widget.ranger.value.start,
      widget.ranger.value.end,
    );

    return OrderLoaderMetrics(
      price: result['totalPrice'] as num,
      count: result['count'] as int,
      productSize: result['productSize'] as int,
      attrSize: result['attrSize'] as int,
    );
  }

  Future<List<OrderObject>> _loadOrders(int offset) {
    return Seller.instance.getOrderBetween(
      widget.ranger.value.start,
      widget.ranger.value.end,
      offset: offset,
    );
  }
}

class OrderLoaderMetrics {
  final num price;

  final int count;

  final int productSize;

  final int attrSize;

  const OrderLoaderMetrics({
    required this.price,
    required this.count,
    required this.productSize,
    required this.attrSize,
  });
}
