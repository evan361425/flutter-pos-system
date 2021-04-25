import 'package:possystem/models/order/order_ingredient_model.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/services/database.dart';

class OrderHistory {
  static final OrderHistory _instance = OrderHistory._constructor();

  static OrderHistory get instance => _instance;

  OrderHistory._constructor();

  _OrderMap buildOrder([num paid]) {
    return _OrderMap(
      paid: paid,
      totalPrice: CartModel.instance.totalPrice,
      totalCount: CartModel.instance.totalCount,
      products: CartModel.instance.products.map((e) => e.toMap()),
    );
  }

  void push(num paid) {
    final order = buildOrder(paid);
    Database.instance.push(Collections.order_history, order.output());
  }

  Future<_OrderMap> pop() async {
    final snapshot = await Database.instance.pop(
      Collections.order_history,
      false,
    );
    return _OrderMap.input(snapshot.data());
  }

  void stash() {
    final order = buildOrder();
    Database.instance.push(Collections.order_stash, order.output());
  }

  Future<_OrderMap> popStash() async {
    final snapshot = await Database.instance.pop(Collections.order_stash);
    return _OrderMap.input(snapshot.data());
  }
}

class _OrderMap {
  num paid;
  final num totalPrice;
  final int totalCount;
  final DateTime createdAt;
  final Iterable<ProductMap> products;

  _OrderMap({
    this.paid,
    this.totalPrice,
    this.totalCount,
    this.products,
    DateTime createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Iterable<OrderProductModel> parseToProduct() {
    return products.map<OrderProductModel>((productMap) {
      final product = MenuModel.instance.getProduct(productMap.productId);
      if (product == null) return null;

      final ingredients = <OrderIngredientModel>[];
      for (var ingredientMap in productMap.ingredients.values) {
        if (ingredientMap.quantityId == null) continue;

        final ingredient = product[ingredientMap.ingredientId];

        ingredients.add(
          OrderIngredientModel(
            ingredient: ingredient,
            quantity: ingredient[ingredientMap.quantityId],
          ),
        );
      }

      return OrderProductModel(
        product,
        count: productMap.count,
        singlePrice: productMap.singlePrice,
        ingredients: ingredients,
      );
    });
  }

  Map<String, dynamic> output() {
    return {
      'paid': paid,
      'totalPrice': totalPrice,
      'totalCount': totalCount,
      'products': products.map((e) => e.output()),
    };
  }

  factory _OrderMap.input(Map<String, dynamic> data) {
    if (data == null) return null;

    return _OrderMap(
      paid: data['paid'],
      totalPrice: data['totalPrice'],
      totalCount: data['totalCount'],
      products: data['products'].map((product) => ProductMap.input(product)),
    );
  }
}
