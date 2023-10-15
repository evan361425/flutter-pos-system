import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/item_loader.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';

class StashedOrderListView extends StatelessWidget {
  const StashedOrderListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemLoader<OrderObject, OrderMetrics>(
      builder: _buildTile,
      loader: (int offset) {
        return Seller.instance.getStashedOrders(offset: offset);
      },
      prototypeItem: _buildTile(
        context,
        OrderObject(createdAt: DateTime.now()),
      ),
      metricsLoader: Seller.instance.getStashedMetrics,
      metricsBuilder: (metrics) {
        return Center(child: Text(S.orderListMetaCount(metrics.count)));
      },
    );
  }

  Widget _buildTile(BuildContext context, OrderObject order) {
    final n = DateTime.now();
    final title = order.createdAt.isBefore(DateTime(n.year, n.month, n.day))
        ? DateFormat.MMMEd(S.localeName).format(order.createdAt) +
            MetaBlock.string +
            DateFormat.Hms(S.localeName).format(order.createdAt)
        : DateFormat.Hms(S.localeName).format(order.createdAt);

    final products = order.products
        .map((e) {
          final p = Menu.instance.getProduct(e.productId);
          if (p == null) return null;
          return e.count == 1 ? p.name : '${p.name} * ${e.count}';
        })
        .where((e) => e != null)
        .cast<String>();

    return ListTile(
      title: Text(title),
      subtitle: MetaBlock.withString(context, products, emptyText: '沒有任何產品'),
      trailing: TextButton(
        onPressed: () async {
          Cart.instance.restore(order);
          await Seller.instance.deleteStashedOrder(order.id ?? 0);
        },
        child: const Text('復原'),
      ),
    );
  }
}
