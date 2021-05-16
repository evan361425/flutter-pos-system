import 'dart:convert';

import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/services/database.dart';

class OrderRepo {
  static final OrderRepo _instance = OrderRepo._constructor();

  static OrderRepo get instance => _instance;

  OrderRepo._constructor();

  Future<num> getStashLength() {
    return Database.instance.count(Tables.order_stash);
  }

  Future<OrderObject> pop() async {
    final encoded = await Database.instance.getLast(Tables.order);
    if (encoded == null) return null;

    final data = <String, Object>{
      'id': encoded['id'],
      'products': jsonDecode(encoded['encodedProducts']),
    };
    return OrderObject.build(data);
  }

  Future<void> push(OrderObject order) {
    final data = _parseObject(order);
    data['createdAt'] = order.createdAt.toUtc().millisecondsSinceEpoch;

    return Database.instance.push(Tables.order, data);
  }

  Future<void> update(OrderObject order) {
    return Database.instance.update(
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
      'usedProducts': Database.join(
        order.products.map<String>((e) => e.productName),
      ),
      'usedIngredients': Database.join(usedIngredients),
      'encodedProducts': jsonEncode(
        order.products.map<Map<String, Object>>((e) => e.toMap()).toList(),
      ),
    };
  }

  Future<void> stash(OrderObject order) {
    return Database.instance.push(Tables.order_stash, {
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'encodedProducts': jsonEncode(
        order.products.map<Map<String, Object>>((e) => e.toMap()).toList(),
      ),
    });
  }

  Future<OrderObject> popStash() async {
    final encoded = await Database.instance.getLast(Tables.order_stash);
    if (encoded == null) return null;

    print('pop stash ${encoded['id']}');

    final object = OrderObject.build({
      'id': encoded['id'],
      'products': jsonDecode(encoded['encodedProducts']),
    });

    await Database.instance.delete(Tables.order_stash, object.id);

    return object;
  }

  Future<void> remove(OrderObject object) {
    return Database.instance.delete(Tables.order_stash, object.id);
  }
}
