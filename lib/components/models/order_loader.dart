import 'package:flutter/material.dart';
import 'package:possystem/components/item_loader.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';

class OrderLoader extends StatelessWidget {
  final DateTimeRange Function() ranger;

  final Widget Function(OrderObject) builder;

  final GlobalKey<ItemLoaderState<OrderObject, OrderLoaderMetrics>> loaderKey;

  const OrderLoader({
    Key? key,
    required this.ranger,
    required this.builder,
    required this.loaderKey,
  }) : super(key: key);

  static GlobalKey<ItemLoaderState<OrderObject, OrderLoaderMetrics>>
      createKey() =>
          GlobalKey<ItemLoaderState<OrderObject, OrderLoaderMetrics>>();

  @override
  Widget build(BuildContext context) {
    return ItemLoader<OrderObject, OrderLoaderMetrics>(
      key: loaderKey,
      prototypeItem: builder(OrderObject(products: const [])),
      loader: _loadOrders,
      metricsLoader: _loadMetrics,
      builder: builder,
      metricsBuilder: (metrics) => MetaBlock.withString(context, [
        S.orderListMetaPrice(metrics.price),
        S.orderListMetaCount(metrics.count),
      ])!,
      emptyChild: HintText(S.orderListEmpty),
    );
  }

  Future<OrderLoaderMetrics> _loadMetrics() async {
    final range = ranger();
    final result = await Seller.instance.getMetricBetween(
      range.start,
      range.end,
    );

    return OrderLoaderMetrics(
      price: result['totalPrice'] as num,
      count: result['count'] as int,
    );
  }

  Future<List<OrderObject>> _loadOrders() {
    final range = ranger();
    return Seller.instance.getOrderBetween(
      range.start,
      range.end,
      offset: loaderKey.currentState?.length ?? 0,
    );
  }
}

class OrderLoaderMetrics {
  final num price;

  final int count;

  const OrderLoaderMetrics({required this.price, required this.count});
}
