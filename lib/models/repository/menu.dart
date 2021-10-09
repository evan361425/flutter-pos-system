import 'package:flutter/widgets.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';

class Menu extends ChangeNotifier
    with
        Repository<Catalog>,
        NotifyRepository<Catalog>,
        OrderablRepository<Catalog>,
        InitilizableRepository<Catalog> {
  static late Menu instance;

  @override
  final Stores storageStore = Stores.menu;

  @override
  final String repositoryName = 'menu';

  Menu() {
    instance = this;
  }

  List<Catalog> get notEmptyItems =>
      itemList.where((e) => e.isNotEmpty).toList();

  @override
  Catalog buildModel(String id, Map<String, Object?> value) {
    return Catalog.fromObject(
      CatalogObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  List<ProductIngredient> getIngredients(String ingredientId) {
    final result = <ProductIngredient>[];

    items.forEach((catalog) {
      catalog.items.forEach((product) {
        final ingredient = product.getItem(ingredientId);
        if (ingredient != null) {
          result.add(ingredient);
        }
      });
    });

    return result;
  }

  Product? getProduct(String productId) {
    for (var catalog in items) {
      final product = catalog.getItem(productId);
      if (product != null) {
        return product;
      }
    }
    return null;
  }

  List<ProductQuantity> getQuantities(String quantityId) {
    final result = <ProductQuantity>[];

    items.forEach((catalog) {
      catalog.items.forEach((product) {
        product.items.forEach((ingredient) {
          final quantity = ingredient.getItem(quantityId);
          if (quantity != null) {
            result.add(quantity);
          }
        });
      });
    });

    return result;
  }

  bool hasProductByName(String name) {
    return items.any((catalog) => catalog.hasName(name));
  }

  Future<void> removeIngredients(String id) {
    final ingredients = getIngredients(id);

    return _remove(ingredients.map((e) => e.product), ingredients);
  }

  Future<void> removeQuantities(String id) {
    final quantities = getQuantities(id);

    return _remove(quantities.map((e) => e.ingredient), quantities);
  }

  /// Search products by [text].
  ///
  /// If text not provided, it will get latest searched products and sorted products
  ///
  /// [limit] will fire list.take.
  Iterable<Product> searchProducts({int limit = 10, String? text}) {
    final products = text == null || text.isEmpty
        ? _getSortedSearchedHistory()
        : _getSortedSimilarities(text);
    return products.take(limit);
  }

  Iterable<MapEntry<Product, double>> _getProductSimilarities(
      String pattern) sync* {
    for (final catalog in items) {
      for (final entry in catalog.getItemsSimilarity(pattern)) {
        yield entry;
      }
    }
  }

  /// Get desc history of searching
  ///
  /// If not enough, return by product asc index
  Iterable<Product> _getSortedSearchedHistory() sync* {
    // products have been searched
    yield* items
        .expand((catalog) =>
            catalog.items.where((product) => product.searchedAt != null))
        .toList()
      ..sort((item1, item2) => item2.searchedAt!.compareTo(item1.searchedAt!));

    // products have not been searched
    yield* itemList.expand((catalog) =>
        catalog.itemList.where((product) => product.searchedAt == null));
  }

  /// Get desc similarity value of products
  Iterable<Product> _getSortedSimilarities(String pattern) {
    final sorted = _getProductSimilarities(pattern)
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((ent1, ent2) => ent2.value.compareTo(ent1.value));

    return sorted.map<Product>((e) => e.key);
  }

  Future<void> _remove(Iterable<Repository> repos, List<Model> items) {
    if (items.isEmpty) return Future.value();

    final updateData = {for (var item in items) item.prefix: null};

    final id = items.first.id;
    repos.forEach((repo) => repo.removeItem(id));

    notifyListeners();

    return Storage.instance.set(Stores.menu, updateData);
  }
}
