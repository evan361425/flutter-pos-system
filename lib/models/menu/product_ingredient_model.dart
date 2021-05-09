import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/services/database.dart';

import 'product_model.dart';

class ProductIngredientModel {
  final Map<String, ProductQuantityModel> quantities;

  ProductModel product;

  String id;

  num amount;

  num cost;

  IngredientModel ingredient;

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
    id ??= ingredient?.id;
  }

  factory ProductIngredientModel.fromObject(ProductIngredientObject object) =>
      ProductIngredientModel(
        id: object.id,
        amount: object.amount,
        cost: object.cost,
        quantities: {
          for (var quantity in object.quantities)
            quantity.id: ProductQuantityModel.fromObject(quantity)
        },
      );

  bool get isNotReady => id == null;

  bool get isReady => id != null;

  String get prefix => '${product.prefix}.ingredients.$id';

  String get prefixQuantities => '$prefix.quantities';

  ProductQuantityModel operator [](String id) => quantities[id];

  void changeIngredient(String id) {
    product.removeIngredient(this);

    this.id = id;
    ingredient = StockModel.instance[id];
    print('change ingredient to $id');
  }

  bool has(String id) => quantities.containsKey(id);

  Future<void> removeQuantity(ProductQuantityModel quantity) {
    print('remove quantity $id');
    quantities.remove(quantity.id);

    final updateData = {'$prefixQuantities.${quantity.id}': null};

    product.updateIngredient(this);

    return Document.instance.update(Collections.menu, updateData);
  }

  ProductIngredientObject toObject() => ProductIngredientObject(
        id: id,
        cost: cost,
        amount: amount,
        quantities: quantities.values.map((e) => e.toObject()),
      );

  Future<void> update(ProductIngredientObject ingredient) {
    final updateData = ingredient.diff(this);

    if (updateData.isEmpty) return Future.value();

    product.updateIngredient(this);

    return Document.instance.update(Collections.menu, updateData);
  }

  void updateQuantity(ProductQuantityModel quantity) {
    if (!quantities.containsKey(quantity.id)) {
      quantities[quantity.id] = quantity;

      final updateData = {
        '$prefixQuantities.${quantity.id}': quantity.toObject().toMap(),
      };

      Document.instance.update(Collections.menu, updateData);
    }

    product.updateIngredient(this);
  }
}
