import 'package:possystem/services/storage.dart';

import '../model.dart';
import '../objects/menu_object.dart';
import '../repository.dart';
import '../repository/menu.dart';
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

  /// Only use for set up [ingredient]
  final String storageIngredientId;

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
    this.storageIngredientId = '',
    this.amount = 0,
    Map<String, ProductQuantity>? quantities,
  }) {
    this.id = id ?? generateId();

    replaceItems(quantities ?? {});

    if (product != null) this.product = product;

    if (ingredient != null) this.ingredient = ingredient;
  }

  /// [ingredient] set by [ModelInitializer]
  factory ProductIngredient.fromObject(ProductIngredientObject object) {
    final quantities = object.quantities.map(
      (e) => ProductQuantity.fromObject(e),
    );

    if (!object.quantities.every((object) => object.isLatest)) {
      Menu.instance.versionChanged = true;
    }

    return ProductIngredient(
      id: object.id,
      storageIngredientId: object.ingredientId!,
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
    product.setItem(this);
  }

  @override
  void handleUpdated() {
    notifyItem();
  }

  @override
  void removeFromRepo() => product.removeItem(id);

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
