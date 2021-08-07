import 'dart:math';

import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';

import 'catalog.dart';
import 'product_ingredient.dart';

class Product extends NotifyModel<ProductObject>
    with
        OrderableModel<ProductObject>,
        Repository<ProductIngredient>,
        SearchableModel<ProductObject>,
        NotifyRepository<ProductIngredient> {
  /// connect to parent object
  late final Catalog catalog;

  /// product's name
  @override
  String name;

  /// help to calculate daily earn
  num cost;

  /// money show to customer/order
  num price;

  /// when it has been added to catalog
  final DateTime createdAt;

  /// when it has beed search
  DateTime? searchedAt;

  Product({
    String? id,
    required this.name,
    int index = 1,
    this.cost = 0,
    this.price = 0,
    DateTime? createdAt,
    this.searchedAt,
    Catalog? catalog,
    Map<String, ProductIngredient>? ingredients,
  })  : createdAt = createdAt ?? DateTime.now(),
        super(id) {
    replaceItems(ingredients ?? {});

    this.index = index;

    if (catalog != null) this.catalog = catalog;
  }

  factory Product.fromObject(ProductObject object) => Product(
        id: object.id,
        name: object.name!,
        index: object.index!,
        price: object.price!,
        cost: object.cost!,
        createdAt: object.createdAt,
        searchedAt: object.searchedAt,
        ingredients: {
          for (var ingredient in object.ingredients)
            ingredient.id!: ProductIngredient.fromObject(ingredient)
        },
      ).._prepareIngredients();

  @override
  String get code => 'menu.product';

  /// help to decide wheather showing ingredient panel in cart
  Iterable<ProductIngredient> get ingredientsWithQuantity =>
      items.where((e) => e.isNotEmpty);

  @override
  String get itemCode => 'menu.ingredient';

  @override
  String get prefix => '${catalog.prefix}.products.$id';

  @override
  Stores get storageStore => Stores.menu;

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
        ingredients: items.map((e) => e.toObject()),
      );

  @override
  String toString() => '$catalog.$name';

  void _prepareIngredients() => items.forEach((e) => e.product = this);
}
