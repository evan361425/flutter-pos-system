import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/services/storage.dart';

import 'catalog_model.dart';
import 'product_ingredient_model.dart';

class ProductModel extends Model<ProductObject> with OrderableModel {
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

  final Map<String, ProductIngredientModel> ingredients;

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
        ingredients = ingredients ?? {},
        super(id) {
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

  /// help to decide wheather showing ingredient panel in cart
  Iterable<ProductIngredientModel> get ingredientsWithQuantity =>
      ingredients.values.where((e) => e.quantities.isNotEmpty);

  @override
  String get prefix => '${catalog.id}.products.$id';

  bool exist(String id) => ingredients.containsKey(id);

  ProductIngredientModel? getIngredient(String id) => ingredients[id];

  void removeIngredient(String id) {
    ingredients.remove(id);

    notifyListeners();
  }

  Future<void> setIngredient(ProductIngredientModel ingredient) async {
    if (!exist(ingredient.id)) {
      info(ingredient.toString(), 'menu.ingredient.add');
      ingredients[ingredient.id] = ingredient;

      final updateData = {ingredient.prefix: ingredient.toObject().toMap()};

      await Storage.instance.set(Stores.menu, updateData);
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
        ingredients: ingredients.values.map((e) => e.toObject()),
      );

  @override
  String toString() => '$catalog.$name';

  void _prepareIngredients() {
    ingredients.values.forEach((e) {
      e.product = this;
    });
  }

  @override
  String get code => 'menu.product';

  @override
  void removeFromRepo() => catalog.removeChild(id);

  @override
  Stores get storageStore => Stores.menu;
}
