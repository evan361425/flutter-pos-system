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

class ProductIngredient extends Model<ProductIngredientObject>
    with
        ModelStorage<ProductIngredientObject>,
        ModelSearchable<ProductIngredientObject>,
        Repository<ProductQuantity>,
        RepositoryStorage<ProductQuantity> {
  /// Connect to parent object
  late final Product product;

  /// Connect to stock.
  late Ingredient ingredient;

  /// Amount of ingredient per product
  num amount;

  @override
  final RepositoryStorageType repoType = RepositoryStorageType.RepoModel;

  @override
  final Stores storageStore = Stores.menu;

  ProductIngredient({
    String? id,
    Ingredient? ingredient,
    Product? product,
    this.amount = 0,
    Map<String, ProductQuantity>? quantities,
  }) : super(id) {
    if (quantities != null) replaceItems(quantities);

    if (product != null) this.product = product;

    if (ingredient != null) this.ingredient = ingredient;
  }

  /// [ingredient] set by [ModelInitializer]
  factory ProductIngredient.fromObject(ProductIngredientObject object) {
    final ingredient = Stock.instance.getItem(object.ingredientId!);
    if (ingredient == null) {
      info(object.ingredientId!, 'menu.parse.error.ingredient');
      throw Error();
    }

    final quantities = object.quantities.map<ProductQuantity?>((e) {
      try {
        return ProductQuantity.fromObject(e);
      } catch (e) {
        // not finding quantity
        return null;
      }
    }).where((e) => e != null);

    if (!object.quantities.every((object) => object.isLatest)) {
      Menu.instance.versionChanged = true;
    }

    return ProductIngredient(
      id: object.id,
      ingredient: ingredient,
      amount: object.amount!,
      quantities: {for (var quantity in quantities) quantity!.id: quantity},
    )..prepareItem();
  }

  @override
  String get name => ingredient.name;

  @override
  String get prefix => '${product.prefix}.ingredients.$id';

  @override
  Product get repository => product;

  @override
  set repository(Repository repo) => product = repo as Product;

  @override
  ProductQuantity buildItem(String id, Map<String, Object?> value) {
    throw UnimplementedError();
  }

  bool hasQuantity(String id) {
    return items.any((item) => item.quantity.id == id);
  }

  @override
  void notifyItems() {
    notifyListeners();
    product.notifyItems();
  }

  @override
  ProductIngredientObject toObject() => ProductIngredientObject(
        id: id,
        ingredientId: ingredient.id,
        amount: amount,
        quantities: items.map((e) => e.toObject()).toList(),
      );
}
