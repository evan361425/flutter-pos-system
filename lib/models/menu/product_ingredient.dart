import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/storage.dart';

import '../model.dart';
import '../objects/menu_object.dart';
import '../repository.dart';
import '../repository/menu.dart';
import '../repository/stock.dart';
import '../stock/ingredient.dart';
import 'product.dart';
import 'product_quantity.dart';

class ProductIngredient
    with
        Model<ProductIngredientObject>,
        SearchableModel<ProductIngredientObject>,
        Repository<ProductQuantity> {
  /// Connect to parent object
  late final Product product;

  /// Connect to stock.
  late Ingredient ingredient;

  /// Amount of ingredient per product
  num amount;

  @override
  final String logCode = 'menu.ingredient';

  @override
  final Stores storageStore = Stores.menu;

  ProductIngredient({
    String? id,
    Ingredient? ingredient,
    Product? product,
    this.amount = 0,
    Map<String, ProductQuantity>? quantities,
  }) {
    this.id = id ?? generateId();

    if (quantities != null) replaceItems(quantities);

    if (product != null) this.product = product;

    if (ingredient != null) this.ingredient = ingredient;
  }

  /// [ingredient] set by [ModelInitializer]
  factory ProductIngredient.fromObject(ProductIngredientObject object) {
    final quantities = object.quantities
        .map<ProductQuantity?>((e) {
          try {
            return ProductQuantity.fromObject(e);
          } catch (e) {
            return null;
          }
        })
        .where((e) => e != null)
        .cast<ProductQuantity>();

    if (!object.quantities.every((object) => object.isLatest)) {
      Menu.instance.versionChanged = true;
    }

    final ingredient = Stock.instance.getItem(object.ingredientId!);
    if (ingredient == null) {
      info(object.ingredientId!, 'menu.parse.error.ingredient');
      throw Error();
    }

    return ProductIngredient(
      id: object.id,
      ingredient: ingredient,
      amount: object.amount!,
      quantities: {for (var quantity in quantities) quantity.id: quantity},
    ).._prepareQuantities();
  }

  @override
  String get name => ingredient.name;

  @override
  String get prefix => '${product.prefix}.ingredients.$id';

  @override
  Future<void> addItemToStorage(ProductQuantity child) {
    return Storage.instance.set(storageStore, {
      child.prefix: child.toObject().toMap(),
    });
  }

  bool hasQuantity(String id) {
    return items.any((item) => item.quantity.id == id);
  }

  @override
  void notifyItem() {
    product.notifyItem();
  }

  @override
  void handleUpdated() {
    notifyItem();
  }

  @override
  void removeFromRepo() {
    product.removeItem(id);
    product.notifyItem();
  }

  @override
  ProductIngredientObject toObject() => ProductIngredientObject(
        id: id,
        ingredientId: ingredient.id,
        amount: amount,
        quantities: items.map((e) => e.toObject()).toList(),
      );

  void _prepareQuantities() {
    items.forEach((e) {
      e.ingredient = this;
    });
  }
}
