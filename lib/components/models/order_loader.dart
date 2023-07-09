import 'package:flutter/material.dart';
import 'package:possystem/components/item_loader.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';

class OrderLoader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ItemLoader<OrderObject, OrderLoaderMetrics>(
      prototypeItem: builder(context, OrderObject(products: const [])),
      notifier: ranger,
      loader: _loadOrders,
      metricsLoader: _loadMetrics,
      builder: builder,
      metricsBuilder: (metrics) {
        final meta = MetaBlock.withString(context, [
          S.orderListMetaPrice(metrics.price),
          S.orderListMetaCount(metrics.count),
        ])!;
        return Row(children: [
          Expanded(child: Center(child: meta)),
          trailingBuilder != null
              ? trailingBuilder!.call(context, metrics)
              : trailing!,
          const SizedBox(width: 8.0),
        ]);
      },
      emptyChild: HintText(S.orderListEmpty),
    );
  }

  Future<OrderLoaderMetrics> _loadMetrics() async {
    final result = await Seller.instance.getMetricBetween(
      ranger.value.start,
      ranger.value.end,
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
      ranger.value.start,
      ranger.value.end,
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
