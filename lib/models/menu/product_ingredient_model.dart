import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/services/database.dart';

import 'product_model.dart';

class ProductIngredientModel {
  ProductIngredientModel({
    this.id,
    this.ingredient,
    this.product,
    num amount,
    num cost,
    Map<String, ProductQuantityModel> quantities,
  })  : quantities = quantities ?? {},
        amount = amount ?? 0,
        cost = cost ?? 0 {
    id ??= ingredient.id;
  }

  final Map<String, ProductQuantityModel> quantities;
  ProductModel product;
  String id;
  num amount;
  num cost;
  IngredientModel ingredient;

  factory ProductIngredientModel.fromMap(ProductIngredientObject map) {
    return ProductIngredientModel(
      id: map.id,
      amount: map.amount,
      cost: map.cost,
      quantities: {
        for (var quantity in map.quantities)
          quantity.id: ProductQuantityModel.fromMap(quantity)
      },
    );
  }

  ProductIngredientObject toMap() {
    return ProductIngredientObject(
      id: id,
      cost: cost,
      amount: amount,
      quantities: quantities.values.map((e) => e.toMap()),
    );
  }

  // STATE CHANGE

  void updateQuantity(ProductQuantityModel quantity) {
    print('update quantity ${quantity.id}');
    if (!quantities.containsKey(quantity.id)) {
      quantities[quantity.id] = quantity;

      final updateData = {
        '$prefixQuantities.${quantity.id}': quantity.toMap().output(),
      };
      Database.instance.update(Collections.menu, updateData);
    }

    // product.ingredientChanged();
  }

  void removeQuantity(ProductQuantityModel quantity) {
    print('remove quantity $id');
    quantities.remove(quantity.id);

    final updateData = {'$prefixQuantities.${quantity.id}': null};
    Database.instance.update(Collections.menu, updateData);

    // product.ingredientChanged();
  }

  Future<void> update(ProductIngredientObject ingredient) {
    final updateData = ingredient.diff(this);

    if (updateData.isEmpty) return Future.value();

    // notify

    return Database.instance.update(Collections.menu, updateData);
  }

  void changeIngredient(String id) {
    this.id = id;
    ingredient = StockModel.instance[id];
  }

  // HELPER

  bool has(String id) => quantities.containsKey(id);
  ProductQuantityModel operator [](String id) => quantities[id];

  // GETTER

  bool get isReady => id != null;
  bool get isNotReady => id == null;
  String get prefix => '${product.prefix}.ingredients.$id';
  String get prefixQuantities => '$prefix.quantities';
}
