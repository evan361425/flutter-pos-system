import 'dart:math' as math;

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

  final bool calculateMemory;

  final GlobalKey<ItemLoaderState<OrderObject, OrderLoaderMetrics>> loaderKey;

  final Widget? trailing;

  const OrderLoader({
    Key? key,
    required this.ranger,
    required this.builder,
    required this.loaderKey,
    this.calculateMemory = false,
    this.trailing,
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
      metricsBuilder: (metrics) {
        final meta = MetaBlock.withString(context, [
          if (calculateMemory) '約佔 ${metrics.memorySize}',
          S.orderListMetaPrice(metrics.price),
          S.orderListMetaCount(metrics.count),
        ])!;
        if (trailing != null) {
          return Row(children: [
            Expanded(child: Center(child: meta)),
            trailing!,
          ]);
        }
        return meta;
      },
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
      productSize: result['productSize'] as int,
      attrSize: result['attrSize'] as int,
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

  final int productSize;

  final int attrSize;

  const OrderLoaderMetrics({
    required this.price,
    required this.count,
    required this.productSize,
    required this.attrSize,
  });

  /// 因為匯出時過大的資訊量會導致服務崩潰，所以先盡可能的計算大小。
  ///
  /// 這裡是一些實測的大小對應值：
  /// | productSize | attrSize | count | bytes |
  /// | - | - | - | - |
  /// | 13195 | 34 | 17 | 6439 | 6.1 |
  /// | 39672 | 92 | 46 | 18758 | 18 |
  /// | 61751 | 142 | 71 | 29043 | 28 |
  /// | 83775 | 200 | 100 | 39771 | 38 |
  String get memorySize {
    final size = productSize * 0.435 + attrSize * 0.8 + 30 * count;
    var depth = (math.log(size) / math.log(1024)).floor();

    String unit = 'MB';
    switch (depth) {
      case 0:
        return '<1KB';
      case 1:
        unit = 'KB';
        break;
      default:
        depth = 2;
        break;
    }
    final part = size / math.pow(1024, depth);
    return (part > 10 ? part.toInt().toString() : part.toStringAsFixed(1)) +
        unit;
  }
}
