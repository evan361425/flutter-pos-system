import 'dart:math';

import 'package:possystem/services/storage.dart';

import '../model.dart';
import '../objects/menu_object.dart';
import '../repository.dart';
import '../repository/menu.dart';
import 'catalog.dart';
import 'product_ingredient.dart';

class Product extends NotifyModel<ProductObject>
    with
        OrderableModel<ProductObject>,
        Repository<ProductIngredient>,
        SearchableModel<ProductObject>,
        NotifyRepository<ProductIngredient> {
  /// Connect to parent object
  late final Catalog catalog;

  /// Help to calculate daily earn
  num cost;

  /// Money show to customer/order
  num price;

  /// The time added to catalog
  final DateTime createdAt;

  /// The time it has been selected in searching
  DateTime? searchedAt;

  @override
  final String logCode = 'menu.product';

  @override
  final Stores storageStore = Stores.menu;

  Product({
    String? id,
    String name = 'product',
    int index = 1,
    this.cost = 0,
    this.price = 0,
    DateTime? createdAt,
    this.searchedAt,
    Catalog? catalog,
    Map<String, ProductIngredient>? ingredients,
  })  : createdAt = createdAt ?? DateTime.now(),
        super(id) {
    this.name = name;
    this.index = index;

    replaceItems(ingredients ?? {});

    if (catalog != null) this.catalog = catalog;
  }

  factory Product.fromObject(ProductObject object) {
    final ingredients = object.ingredients.map(
      (e) => ProductIngredient.fromObject(e),
    );

    if (!object.ingredients.every((object) => object.isLatest)) {
      Menu.instance.versionChanged = true;
    }

    return Product(
      id: object.id,
      name: object.name!,
      index: object.index!,
      price: object.price!,
      cost: object.cost!,
      createdAt: object.createdAt,
      searchedAt: object.searchedAt,
      ingredients: {
        for (var ingredient in ingredients) ingredient.id: ingredient
      },
    ).._prepareIngredients();
  }

  /// help to decide wheather showing ingredient panel in cart
  Iterable<ProductIngredient> get ingredientsWithQuantity =>
      items.where((e) => e.isNotEmpty);

  @override
  String get prefix => '${catalog.prefix}.products.$id';

  @override
  Future<void> addItemToStorage(ProductIngredient child) {
    return Storage.instance.set(storageStore, {
      child.prefix: child.toObject().toMap(),
    });
  }

  int getItemsSimilarity(String pattern) {
    var maxScore = 0;
    for (final ingredient in items) {
      maxScore = max(ingredient.getSimilarity(pattern), maxScore);
      for (final quantity in ingredient.items) {
        maxScore = max(quantity.getSimilarity(pattern), maxScore);
      }
    }
    return maxScore;
  }

  bool hasIngredient(String id) {
    return items.any((item) => item.ingredient.id == id);
  }

  @override
  void notifyItem() {
    // catalog screen will also shows ingredients
    catalog.notifyListeners();

    notifyListeners();
  }

  @override
  void removeFromRepo() => catalog.removeItem(id);

  Future<void> searched() {
    return update(ProductObject(searchedAt: DateTime.now()), event: 'search');
  }

  @override
  ProductObject toObject() => ProductObject(
        id: id,
        name: name,
        index: index,
        price: price,
        cost: cost,
        createdAt: createdAt,
        ingredients: items.map((e) => e.toObject()).toList(),
      );

  void _prepareIngredients() => items.forEach((e) => e.product = this);
}
