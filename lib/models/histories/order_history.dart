import 'dart:convert';

import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/services/database.dart';

class OrderHistory {
  static final OrderHistory _instance = OrderHistory._constructor();

  static OrderHistory get instance => _instance;

  OrderHistory._constructor();

  Future<num> getStashLength() {
    return SQLite.instance.count(Tables.order_stash);
  }

  Future<OrderObject> pop([remove = false]) async {
    final snapshot = await Document.instance.pop(
      Collections.order_history,
      remove,
    );
    return OrderObject.build(snapshot.data());
  }

  Future<OrderObject> popStash() async {
    final snapshot = await Document.instance.pop(Collections.order_stash);
    return OrderObject.build(snapshot.data());
  }

  Future<void> push(OrderObject order) {
    final usedIngredients = <String>[];

    order.products.forEach(
      (product) => product.ingredients.values.forEach(
        (ingredient) => usedIngredients.add(ingredient.name),
      ),
    );

    return SQLite.instance.push(Tables.order, {
      'createdAt': order.createdAt.toUtc().millisecondsSinceEpoch,
      'paid': order.paid,
      'totalPrice': order.totalPrice,
      'totalCount': order.totalCount,
      'usedProducts': order.products.map((e) => e.productName).join(','),
      'usedIngredients': usedIngredients.join(','),
      'products': jsonEncode(order.products.map((e) => e.toMap())),
    });
  }

  Future<void> stash(OrderObject order) {
    return SQLite.instance.push(Tables.order_stash, {
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'products': jsonEncode(order.products.map((e) => e.toMap())),
    });
  }
}
