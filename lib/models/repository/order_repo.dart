import 'dart:convert';

import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/ui/home/home_screen.dart';

class OrderRepo {
  static final OrderRepo _instance = OrderRepo._constructor();

  static OrderRepo get instance => _instance;

  OrderRepo._constructor();

  Future<num> getStashLength() {
    return Database.instance.count(Tables.order_stash);
  }

  Future<OrderObject> pop() async {
    final row = await Database.instance.getLast(
      Tables.order,
      columns: ['id', 'encodedProducts'],
    );
    if (row == null) return null;
    print('order pop ${row['id']}');

    return OrderObject.build(<String, Object>{
      'id': row['id'],
      'products': jsonDecode(row['encodedProducts']),
    });
  }

  Future<void> push(OrderObject order) {
    print('add order ${order.totalPrice}');
    HomeScreen.orderInfo?.currentState?.reset();

    final data = _parseObject(order);
    data['createdAt'] = order.createdAt.toUtc().millisecondsSinceEpoch;
    return Database.instance.push(Tables.order, data);
  }

  Future<void> update(OrderObject order) {
    print('update order ${order.id}');
    HomeScreen.orderInfo?.currentState?.reset();

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
    final row = await Database.instance.getLast(
      Tables.order_stash,
      columns: ['id', 'encodedProducts'],
    );
    if (row == null) return null;

    print('pop stash ${row['id']}');

    final object = OrderObject.build({
      'id': row['id'],
      'products': jsonDecode(row['encodedProducts']),
    });

    await Database.instance.delete(Tables.order_stash, object.id);

    return object;
  }
}
