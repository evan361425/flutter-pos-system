import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/services/storage.dart';

import 'product_model.dart';

class ProductIngredientModel {
  late String id;

  /// connect to parent object
  late final ProductModel product;

  /// connect to stock.
  /// When it set, [MenuModel.stockMode] must be true
  late IngredientModel ingredient;

  /// ingredient per product
  num amount;

  final Map<String, ProductQuantityModel> quantities;

  ProductIngredientModel({
    String? id,
    IngredientModel? ingredient,
    ProductModel? product,
    num? amount,
    num? cost,
    Map<String, ProductQuantityModel>? quantities,
  })  : quantities = quantities ?? {},
        amount = amount ?? 0 {
    if (id != null) this.id = id;

    if (ingredient != null) {
      this.id = ingredient.id;
      this.ingredient = ingredient;
    }
    if (product != null) this.product = product;
  }

  factory ProductIngredientModel.fromObject(ProductIngredientObject object) =>
      ProductIngredientModel(
        id: object.id,
        amount: object.amount,
        quantities: {
          for (var quantity in object.quantities)
            quantity.id!: ProductQuantityModel.fromObject(quantity)
        },
      ).._prepareQuantities();

  String get prefix => '${product.prefix}.ingredients.$id';

  /// change stock ingredient
  Future<void> changeIngredient(String newId) async {
    await remove();

    setIngredient(StockModel.instance.getIngredient(newId)!);
    await product.setIngredient(this);
    print('change ingredient to ${ingredient.name}');
  }

  bool exist(String? id) => quantities.containsKey(id);

  ProductQuantityModel? getQuantity(String? id) =>
      exist(id) ? quantities[id] : null;

  Future<void> remove() async {
    print('remove product ingredient ${ingredient.name}');
    await Storage.instance.set(Stores.menu, {prefix: null});

    product.removeIngredient(id);
  }

  void removeQuantity(String? id) {
    quantities.remove(id);

    product.setIngredient(this);
  }

  void setIngredient(IngredientModel model) {
    ingredient = model;
    id = model.id;
  }

  ProductIngredientObject toObject() => ProductIngredientObject(
        id: id,
        amount: amount,
        quantities: quantities.values.map((e) => e.toObject()),
      );

  Future<void> update(ProductIngredientObject ingredient) {
    final updateData = ingredient.diff(this);

    if (updateData.isEmpty) return Future.value();

    product.setIngredient(this);

    return Storage.instance.set(Stores.menu, updateData);
  }

  Future<void> setQuantity(ProductQuantityModel quantity) async {
    if (!exist(quantity.id)) {
      quantities[quantity.id] = quantity;

      final updateData = {'${quantity.prefix}': quantity.toObject().toMap()};

      await Storage.instance.set(Stores.menu, updateData);
    }

    await product.setIngredient(this);
  }

  void _prepareQuantities() {
    quantities.values.forEach((e) {
      e.ingredient = this;
    });
  }
}
