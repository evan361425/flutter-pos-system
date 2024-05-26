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
        ModelOrderable<ProductIngredientObject>,
        Repository<ProductQuantity>,
        RepositoryStorage<ProductQuantity> {
  /// Connect to parent object
  late final Product product;

  /// Connect to stock.
  late Ingredient ingredient;

  /// Amount of ingredient per product
  num amount;

  @override
  final RepositoryStorageType repoType = RepositoryStorageType.repoModel;

  @override
  final Stores storageStore = Stores.menu;

  ProductIngredient({
    super.id,
    super.status = ModelStatus.normal,
    int index = 0,
    super.name = '',
    Ingredient? ingredient,
    this.amount = 0,
    Map<String, ProductQuantity>? quantities,
  }) {
    this.index = index;
    if (quantities != null) replaceItems(quantities);

    if (ingredient != null) this.ingredient = ingredient;
  }

  /// [ingredient] set by [ModelInitializer]
  factory ProductIngredient.fromObject(ProductIngredientObject object) {
    final ingredient = Stock.instance.getItem(object.ingredientId!);
    if (ingredient == null) {
      throw Exception(object.ingredientId);
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
      index: object.index!,
      ingredient: ingredient,
      amount: object.amount!,
      quantities: {for (var quantity in quantities) quantity!.id: quantity},
    )..prepareItem();
  }

  factory ProductIngredient.fromRow(
    ProductIngredient? ori,
    List<String> row,
  ) {
    var ingredient = ori?.ingredient ?? Stock.instance.getItemByName(row[0]) ?? Stock.instance.getStagedByName(row[0]);
    if (ingredient == null) {
      ingredient = Ingredient(
        name: row[0],
        status: ModelStatus.staged,
      );
      Stock.instance.addStaged(ingredient);
    }

    final amount = row.length > 1 ? num.tryParse(row[1]) ?? 0 : 0;
    final status = ori == null ? ModelStatus.staged : (amount == ori.amount ? ModelStatus.normal : ModelStatus.updated);

    return ProductIngredient(
      id: ori?.id,
      index: ori?.index ?? 0,
      ingredient: ingredient,
      amount: amount,
      status: status,
    );
  }

  @override
  String get name => ingredient.name;

  @override
  String get prefix => '${product.prefix}.ingredients.$id';

  @override
  Product get repository => product;

  @override
  String get statusName {
    // When the product is new, it means that the product
    // ingredient must also be new, so only need to output
    // whether it is a "new inventory ingredient"
    if (product.status == ModelStatus.staged) {
      return ingredient.status == ModelStatus.staged ? 'stagedIng' : 'normal';
    }

    return super.statusName;
  }

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
        index: index,
        ingredientId: ingredient.id,
        amount: amount,
        quantities: items.map((e) => e.toObject()).toList(),
      );
}
