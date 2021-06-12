import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';

import 'catalog_model.dart';
import 'product_ingredient_model.dart';

class ProductModel extends NotifyModel<ProductObject>
    with OrderableModel, Repository<ProductIngredientModel> {
  /// connect to parent object
  late final CatalogModel catalog;

  /// product's name
  String name;

  /// help to calculate daily earn
  num cost;

  /// money show to customer/order
  num price;

  /// when it has been added to catalog
  final DateTime createdAt;

  ProductModel({
    required int index,
    required this.name,
    CatalogModel? catalog,
    this.cost = 0,
    this.price = 0,
    DateTime? createdAt,
    String? id,
    Map<String, ProductIngredientModel>? ingredients,
  })  : createdAt = createdAt ?? DateTime.now(),
        super(id) {
    replaceChilds(ingredients ?? {});
    this.index = index;
    if (catalog != null) this.catalog = catalog;
  }

  factory ProductModel.fromObject(ProductObject object) => ProductModel(
        id: object.id,
        name: object.name!,
        index: object.index!,
        price: object.price!,
        cost: object.cost!,
        createdAt: object.createdAt,
        ingredients: {
          for (var ingredient in object.ingredients)
            ingredient.id!: ProductIngredientModel.fromObject(ingredient)
        },
      ).._prepareIngredients();

  @override
  String get childCode => 'menu.ingredient';

  @override
  String get code => 'menu.product';

  /// help to decide wheather showing ingredient panel in cart
  Iterable<ProductIngredientModel> get ingredientsWithQuantity =>
      childs.where((e) => e.quantities.isNotEmpty);

  @override
  String get prefix => '${catalog.id}.products.$id';

  @override
  Stores get storageStore => Stores.menu;

  @override
  void removeFromRepo() => catalog.removeChild(id);

  @override
  Future<void> setChild(ProductIngredientModel child) async {
    if (!existChild(child.id)) {
      info(child.toString(), '$childCode.add');

      addChild(child);

      await Storage.instance.set(storageStore, {
        child.prefix: child.toObject().toMap(),
      });
    }

    // catalog screen will also shows ingredients
    catalog.notifyListeners();

    notifyListeners();
  }

  @override
  ProductObject toObject() => ProductObject(
        id: id,
        name: name,
        index: index,
        price: price,
        cost: cost,
        createdAt: createdAt,
        ingredients: childs.map((e) => e.toObject()),
      );

  @override
  String toString() => '$catalog.$name';

  void _prepareIngredients() => childs.forEach((e) => e.product = this);
}
