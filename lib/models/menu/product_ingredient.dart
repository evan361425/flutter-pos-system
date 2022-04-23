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
  final RepositoryStorageType repoType = RepositoryStorageType.repoModel;

  @override
  final Stores storageStore = Stores.menu;

  ProductIngredient({
    String? id,
    ModelStatus? status,
    Ingredient? ingredient,
    this.amount = 0,
    Map<String, ProductQuantity>? quantities,
  }) : super(id, status) {
    if (quantities != null) replaceItems(quantities);

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

  factory ProductIngredient.fromColumns(
    ProductIngredient? ori,
    List<String> columns,
  ) {
    final status = ori == null ? ModelStatus.staged : ModelStatus.updated;
    final ingredient = Ingredient(
      id: ori?.ingredient.id,
      name: columns[0],
      status: status,
    );
    Stock.instance.addItem(ingredient);

    return ProductIngredient(
      id: ori?.id,
      ingredient: ingredient,
      amount: num.parse(columns[1]),
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
    // 當產品是新的，代表產品成份一定也是新的，這樣就只需要輸出是否為「新的庫存成分」
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
        ingredientId: ingredient.id,
        amount: amount,
        quantities: items.map((e) => e.toObject()).toList(),
      );
}
