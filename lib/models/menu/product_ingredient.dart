import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/storage.dart';

import '../model.dart';
import '../objects/menu_object.dart';
import '../repository.dart';
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
    replaceItems(quantities ?? {});

    if (id != null) this.id = id;

    if (product != null) this.product = product;

    if (ingredient != null) setIngredient(ingredient);
  }

  factory ProductIngredient.fromObject(ProductIngredientObject object) =>
      ProductIngredient(
        id: object.id,
        amount: object.amount!,
        quantities: {
          for (var quantity in object.quantities)
            quantity.id!: ProductQuantity.fromObject(quantity)
        },
      ).._prepareQuantities();

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

  /// change stock ingredient
  Future<void> changeIngredient(String newId) async {
    await remove();

    setIngredient(Stock.instance.getItem(newId)!);

    await product.setItem(this);
  }

  @override
  void notifyItem() {
    product.setItem(this);
  }

  @override
  void removeFromRepo() => product.removeItem(id);

  void setIngredient(Ingredient model) {
    ingredient = model;
    id = model.id;
  }

  @override
  ProductIngredientObject toObject() => ProductIngredientObject(
        id: id,
        amount: amount,
        quantities: items.map((e) => e.toObject()),
      );

  @override
  Future<bool> update(
    ProductIngredientObject ingredient, {
    String event = 'update',
  }) async {
    final updateData = ingredient.diff(this);

    if (updateData['id'] != null) {
      await (updateData['id'] as Future<void>);
      return true;
    }

    if (updateData.isEmpty) return false;

    info(toString(), '$logCode.$event');
    await product.setItem(this);

    await Storage.instance.set(storageStore, updateData);

    return true;
  }

  void _prepareQuantities() {
    items.forEach((e) {
      e.ingredient = this;
    });
  }
}
