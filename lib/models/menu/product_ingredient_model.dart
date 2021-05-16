import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/services/storage.dart';

import 'product_model.dart';

class ProductIngredientModel {
  String id;

  /// connect to parent object
  ProductModel product;

  /// connect to stock.
  /// When it set, [MenuModel.stockMode] must be true
  IngredientModel ingredient;

  /// ingredient per product
  num amount;

  /// cost per product
  num cost;

  final Map<String, ProductQuantityModel> quantities;

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
      ).._prepareQuantities();

  String get prefix => '${product.prefix}.ingredients.$id';

  /// change stock ingredient
  Future<void> changeIngredient(String newId) async {
    await remove();

    id = newId;
    ingredient = StockModel.instance.getIngredient(id);
    print('change ingredient to ${ingredient.name}');

    return Storage.instance.set(Stores.menu, {prefix: toObject().toMap()});
  }

  bool exist(String id) => quantities.containsKey(id);

  ProductQuantityModel getQuantity(String id) =>
      exist(id) ? quantities[id] : null;

  Future<void> remove() async {
    print('remove product ingredient ${ingredient.name}');
    await Storage.instance.set(Stores.menu, {prefix: null});

    product.removeIngredient(id);
  }

  void removeQuantity(String id) {
    quantities.remove(id);

    product.updateIngredient(this);
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

    return Storage.instance.set(Stores.menu, updateData);
  }

  void updateQuantity(ProductQuantityModel quantity) {
    if (!exist(quantity.id)) {
      quantities[quantity.id] = quantity;

      final updateData = {'${quantity.prefix}': quantity.toObject().toMap()};

      Storage.instance.set(Stores.menu, updateData);
    }

    product.updateIngredient(this);
  }

  void _prepareQuantities() {
    quantities.values.forEach((e) {
      e.ingredient = this;
    });
  }
}
