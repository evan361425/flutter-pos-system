import 'dart:convert';

import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/services/database.dart';

class OrderRepo {
  static final OrderRepo _instance = OrderRepo._constructor();

  static OrderRepo get instance => _instance;

  OrderRepo._constructor();

  Future<num> getStashLength() {
    return Storage.instance.count(Tables.order_stash);
  }

  Future<OrderObject> pop() async {
    final data = await Storage.instance.getLast(Tables.order);
    data['products'] = jsonDecode(data['encodedProducts']);
    return OrderObject.build(data);
  }

  Future<void> push(OrderObject order) {
    final data = _parseObject(order);
    data['createdAt'] = order.createdAt.toUtc().millisecondsSinceEpoch;

    return Storage.instance.push(Tables.order, data);
  }

  Future<void> update(OrderObject order) {
    return Storage.instance.update(
      Tables.order,
      order.id,
      _parseObject(order),
    );
  }

  Map<String, Object> _parseObject(OrderObject order) {
    final usedIngredients = <String>[];

    order.products.forEach(
      (product) => product.ingredients.values.forEach(
        (ingredient) => usedIngredients.add(ingredient.name),
      ),
    );

    return {
      'paid': order.paid,
      'totalPrice': order.totalPrice,
      'totalCount': order.totalCount,
      'usedProducts': order.products.map((e) => e.productName).join(','),
      'usedIngredients': usedIngredients.join(','),
      'encodedProducts': jsonEncode(order.products.map((e) => e.toMap())),
    };
  }

  Future<void> stash(OrderObject order) {
    return Storage.instance.push(Tables.order_stash, {
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'encodedProducts': jsonEncode(order.products.map((e) => e.toMap())),
    });
  }

  Future<OrderObject> popStash() async {
    final data = await Storage.instance.getLast(Tables.order_stash);
    data['products'] = jsonDecode(data['encodedProducts']);
    return OrderObject.build(data);
  }
}
